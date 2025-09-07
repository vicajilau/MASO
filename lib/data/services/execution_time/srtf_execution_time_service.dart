import 'package:maso/core/constants/execution_time_constants.dart';
import 'package:maso/data/services/execution_time/base_execution_time_service.dart';
import 'package:maso/domain/models/machine.dart';

import '../../../domain/models/core_processor.dart';
import '../../../domain/models/hardware_component.dart';
import '../../../domain/models/hardware_state.dart';
import '../../../domain/models/maso/regular_process.dart';
import '../../../domain/models/maso/burst_process.dart';
import '../../../domain/models/maso/burst.dart';
import '../../../domain/models/maso/burst_type.dart';

/// Execution time service for the Shortest Remaining Time First (SRTF) scheduling algorithm.
///
/// This algorithm is a preemptive version of SJF. At each unit of time,
/// the process with the shortest remaining time among the arrived ones
/// is selected and may preempt the currently running process.
class SrtfExecutionTimeService extends BaseExecutionTimeService {
  SrtfExecutionTimeService(super.processes, super.executionSetup);

  @override
  Machine calculateMachineWithRegularProcesses() {
    final readyQueue = processes
        .whereType<RegularProcess>()
        .map((p) => p.copy()) // Copy to modify remainingTime
        .toList();

    final numberOfCPUs = executionSetup.settings.cpuCount;
    final contextSwitchTime = executionSetup.settings.contextSwitchTime;

    final cpus = List.generate(numberOfCPUs, (_) => CoreProcessor.empty());
    final List<RegularProcess?> cpuStates = List.filled(numberOfCPUs, null);
    final cpuTimes = List.filled(numberOfCPUs, 0);

    final remainingTimes = <String, int>{
      for (var p in readyQueue) p.id: p.serviceTime,
    };

    int currentTime = 0;

    allDone() => readyQueue.isEmpty && cpuStates.every((p) => p == null);

    while (!allDone()) {
      // Get processes that have arrived
      final available =
          readyQueue.where((p) => p.arrivalTime <= currentTime).toList();

      for (int i = 0; i < numberOfCPUs; i++) {
        final current = cpuStates[i];
        final core = cpus[i].core;

        // See if there is a better candidate for preemption
        final preemptCandidate = available.where((p) {
          return current == null ||
              remainingTimes[p.id]! < remainingTimes[current.id]!;
        }).toList()
          ..sort(
              (a, b) => remainingTimes[a.id]!.compareTo(remainingTimes[b.id]!));

        // If there is a candidate, preempt if better or start new process
        if (preemptCandidate.isNotEmpty) {
          final next = preemptCandidate.first;

          // If preempt or first process
          if (current == null || current.id != next.id) {
            // Context switch
            if (current != null && contextSwitchTime > 0) {
              final switching = RegularProcess(
                id: ExecutionTimeConstants.switchContextProcessId,
                arrivalTime: currentTime,
                serviceTime: contextSwitchTime,
                enabled: true,
              );
              core.add(
                  HardwareComponent(HardwareState.switchingContext, switching));
              currentTime += contextSwitchTime;
              cpuTimes[i] = currentTime;
            }

            if (current != null) {
              readyQueue.add(current);
            }

            // Execute a `next` tick
            final running = next.copy();
            running.arrivalTime = currentTime;
            running.serviceTime = 1;

            core.add(HardwareComponent(HardwareState.busy, running));
            remainingTimes[next.id] = remainingTimes[next.id]! - 1;

            cpuStates[i] = remainingTimes[next.id] == 0 ? null : next;

            if (remainingTimes[next.id] == 0) {
              readyQueue.removeWhere((p) => p.id == next.id);
            }

            cpuTimes[i] = currentTime + 1;
          }
        } else if (current != null) {
          // Continue the current process 1 more unit
          final running = current.copy();
          running.arrivalTime = currentTime;
          running.serviceTime = 1;

          core.add(HardwareComponent(HardwareState.busy, running));
          remainingTimes[current.id] = remainingTimes[current.id]! - 1;

          if (remainingTimes[current.id] == 0) {
            cpuStates[i] = null;
            readyQueue.removeWhere((p) => p.id == current.id);
          }

          cpuTimes[i] = currentTime + 1;
        } else {
          // CPU is idle
          final idle = RegularProcess(
            id: ExecutionTimeConstants.freeProcessId,
            arrivalTime: currentTime,
            serviceTime: 1,
            enabled: true,
          );
          core.add(HardwareComponent(HardwareState.free, idle));
          cpuTimes[i] = currentTime + 1;
        }
      }

      currentTime++;
    }

    return Machine(cpus: cpus, ioChannels: []);
  }

  /// Calculates machine execution using burst-based processes with SRTF scheduling.
  ///
  /// For burst processes with SRTF:
  /// - Each thread in a process executes its bursts sequentially
  /// - CPU bursts use preemptive SRTF (shortest remaining CPU burst time first)
  /// - I/O bursts use SRTF (shortest remaining I/O burst time first)
  /// - Preemption occurs when a shorter burst arrives
  /// - Threads can run concurrently within the same process
  @override
  Machine calculateMachineWithBurstProcesses() {
    // Filter and sort burst processes by arrival time
    final burstProcesses = processes
        .whereType<BurstProcess>()
        .where((p) => p.enabled)
        .toList()
      ..sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));

    final numberOfCPUs = executionSetup.settings.cpuCount;
    final numberOfIOChannels = executionSetup.settings.ioChannels;
    final contextSwitchTime = executionSetup.settings.contextSwitchTime;

    // Create CPUs and I/O channels
    final cpus = List.generate(numberOfCPUs, (_) => CoreProcessor.empty());
    final ioChannels =
        List.generate(numberOfIOChannels, (_) => CoreProcessor.empty());

    // Track current time and running threads for each CPU and I/O channel
    final cpuTimes = List.filled(numberOfCPUs, 0.0);
    final ioTimes = List.filled(numberOfIOChannels, 0.0);
    final cpuRunningThreads =
        List.filled(numberOfCPUs, null as _ThreadExecution?);
    final ioRunningThreads =
        List.filled(numberOfIOChannels, null as _ThreadExecution?);

    // Create a list of all enabled threads from all processes
    final allThreads = <_ThreadExecution>[];
    for (final process in burstProcesses) {
      for (final thread in process.threads.where((t) => t.enabled)) {
        allThreads.add(_ThreadExecution(
          processId: process.id,
          threadId: thread.id,
          arrivalTime: process.arrivalTime.toDouble(),
          bursts: List.from(thread.bursts),
          currentBurstIndex: 0,
          remainingTime: thread.bursts.isNotEmpty
              ? thread.bursts[0].duration.toDouble()
              : 0.0,
        ));
      }
    }

    // Ready queues for CPU and I/O
    final cpuReadyQueue = <_ThreadExecution>[];
    final ioReadyQueue = <_ThreadExecution>[];
    final completedThreads = <_ThreadExecution>[];

    double currentTime = 0.0;

    while (allThreads.isNotEmpty ||
        cpuReadyQueue.isNotEmpty ||
        ioReadyQueue.isNotEmpty ||
        cpuRunningThreads.any((t) => t != null) ||
        ioRunningThreads.any((t) => t != null)) {
      // Add newly arrived threads to appropriate queues
      allThreads.removeWhere((thread) {
        if (thread.arrivalTime <= currentTime) {
          if (thread.currentBurst?.type == BurstType.cpu) {
            cpuReadyQueue.add(thread);
          } else if (thread.currentBurst?.type == BurstType.io) {
            ioReadyQueue.add(thread);
          }
          return true;
        }
        return false;
      });

      // Sort ready queues by remaining time (SRTF)
      cpuReadyQueue.sort((a, b) => a.remainingTime.compareTo(b.remainingTime));
      ioReadyQueue.sort((a, b) => a.remainingTime.compareTo(b.remainingTime));

      // Check for preemption on CPUs
      for (int cpu = 0; cpu < numberOfCPUs; cpu++) {
        if (cpuRunningThreads[cpu] != null && cpuReadyQueue.isNotEmpty) {
          final runningThread = cpuRunningThreads[cpu]!;
          final newThread = cpuReadyQueue.first;

          // Preempt if new thread has shorter remaining time
          if (newThread.remainingTime < runningThread.remainingTime) {
            // Add context switch for preemption
            if (contextSwitchTime > 0) {
              final switchProcess = RegularProcess(
                id: ExecutionTimeConstants.switchContextProcessId,
                arrivalTime: currentTime.toInt(),
                serviceTime: contextSwitchTime,
                enabled: true,
              );
              cpus[cpu].core.add(HardwareComponent(
                  HardwareState.switchingContext, switchProcess));
              cpuTimes[cpu] = currentTime + contextSwitchTime;
            }

            // Move running thread back to ready queue
            cpuReadyQueue.add(runningThread);
            cpuRunningThreads[cpu] = null;

            // Sort ready queue again after adding preempted thread
            cpuReadyQueue
                .sort((a, b) => a.remainingTime.compareTo(b.remainingTime));
          }
        }
      }

      // Check for preemption on I/O channels
      for (int ioChannel = 0; ioChannel < numberOfIOChannels; ioChannel++) {
        if (ioRunningThreads[ioChannel] != null && ioReadyQueue.isNotEmpty) {
          final runningThread = ioRunningThreads[ioChannel]!;
          final newThread = ioReadyQueue.first;

          // Preempt if new thread has shorter remaining time
          if (newThread.remainingTime < runningThread.remainingTime) {
            // Move running thread back to ready queue
            ioReadyQueue.add(runningThread);
            ioRunningThreads[ioChannel] = null;

            // Sort ready queue again after adding preempted thread
            ioReadyQueue
                .sort((a, b) => a.remainingTime.compareTo(b.remainingTime));
          }
        }
      }

      bool anyProgress = false;

      // Schedule CPU bursts
      for (int cpu = 0; cpu < numberOfCPUs; cpu++) {
        if (cpuRunningThreads[cpu] == null &&
            cpuReadyQueue.isNotEmpty &&
            cpuTimes[cpu] <= currentTime) {
          final thread = cpuReadyQueue.removeAt(0);

          // Create process representation for this burst
          final burstProcess = RegularProcess(
            id: '${thread.processId}.${thread.threadId}',
            arrivalTime: currentTime.toInt(),
            serviceTime: thread.remainingTime.toInt(),
            enabled: true,
          );

          cpus[cpu]
              .core
              .add(HardwareComponent(HardwareState.busy, burstProcess));
          cpuTimes[cpu] = currentTime + thread.remainingTime;
          cpuRunningThreads[cpu] = thread;

          anyProgress = true;
        }
      }

      // Schedule I/O bursts
      for (int ioChannel = 0; ioChannel < numberOfIOChannels; ioChannel++) {
        if (ioRunningThreads[ioChannel] == null &&
            ioReadyQueue.isNotEmpty &&
            ioTimes[ioChannel] <= currentTime) {
          final thread = ioReadyQueue.removeAt(0);

          // Create process representation for this I/O burst
          final burstProcess = RegularProcess(
            id: '${thread.processId}.${thread.threadId}',
            arrivalTime: currentTime.toInt(),
            serviceTime: thread.remainingTime.toInt(),
            enabled: true,
          );

          ioChannels[ioChannel]
              .core
              .add(HardwareComponent(HardwareState.busy, burstProcess));
          ioTimes[ioChannel] = currentTime + thread.remainingTime;
          ioRunningThreads[ioChannel] = thread;

          anyProgress = true;
        }
      }

      // Check for completed bursts
      for (int cpu = 0; cpu < numberOfCPUs; cpu++) {
        if (cpuRunningThreads[cpu] != null &&
            cpuTimes[cpu] <= currentTime + 1) {
          final thread = cpuRunningThreads[cpu]!;
          cpuRunningThreads[cpu] = null;

          // Move to next burst
          thread.currentBurstIndex++;
          if (thread.currentBurstIndex < thread.bursts.length) {
            thread.arrivalTime =
                cpuTimes[cpu]; // Available after this burst completes
            thread.remainingTime =
                thread.bursts[thread.currentBurstIndex].duration.toDouble();
            allThreads.add(thread);
          } else {
            completedThreads.add(thread);
          }

          anyProgress = true;
        }
      }

      for (int ioChannel = 0; ioChannel < numberOfIOChannels; ioChannel++) {
        if (ioRunningThreads[ioChannel] != null &&
            ioTimes[ioChannel] <= currentTime + 1) {
          final thread = ioRunningThreads[ioChannel]!;
          ioRunningThreads[ioChannel] = null;

          // Move to next burst
          thread.currentBurstIndex++;
          if (thread.currentBurstIndex < thread.bursts.length) {
            thread.arrivalTime =
                ioTimes[ioChannel]; // Available after this I/O completes
            thread.remainingTime =
                thread.bursts[thread.currentBurstIndex].duration.toDouble();
            allThreads.add(thread);
          } else {
            completedThreads.add(thread);
          }

          anyProgress = true;
        }
      }

      // Update remaining time for running threads
      for (int cpu = 0; cpu < numberOfCPUs; cpu++) {
        if (cpuRunningThreads[cpu] != null) {
          cpuRunningThreads[cpu]!.remainingTime -= 1.0;
        }
      }

      for (int ioChannel = 0; ioChannel < numberOfIOChannels; ioChannel++) {
        if (ioRunningThreads[ioChannel] != null) {
          ioRunningThreads[ioChannel]!.remainingTime -= 1.0;
        }
      }

      // Advance time
      if (!anyProgress) {
        if (allThreads.isNotEmpty) {
          currentTime = allThreads
              .map((t) => t.arrivalTime)
              .reduce((a, b) => a < b ? a : b);
        } else {
          currentTime++;
        }
      } else {
        currentTime++;
      }
    }

    return Machine(cpus: cpus, ioChannels: ioChannels);
  }
}

/// Helper class to track thread execution state for SRTF
class _ThreadExecution {
  final String processId;
  final String threadId;
  double arrivalTime;
  final List<Burst> bursts;
  int currentBurstIndex;
  double remainingTime;

  _ThreadExecution({
    required this.processId,
    required this.threadId,
    required this.arrivalTime,
    required this.bursts,
    required this.currentBurstIndex,
    required this.remainingTime,
  });

  Burst? get currentBurst =>
      currentBurstIndex < bursts.length ? bursts[currentBurstIndex] : null;
}
