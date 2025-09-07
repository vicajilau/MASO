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

/// Execution time service for the Time Limit scheduling algorithm.
///
/// Each process is given a maximum execution time (`timeLimit`) per turn.
/// If it doesn't finish in that time, it is re-added to the queue with the remaining time.
/// Context switches and idle times are handled accordingly.
class TimeLimitExecutionTimeService extends BaseExecutionTimeService {
  TimeLimitExecutionTimeService(super.processes, super.executionSetup);

  @override
  Machine calculateMachineWithRegularProcesses() {
    final queue = processes.whereType<RegularProcess>().toList()
      ..sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));

    final numberOfCPUs = executionSetup.settings.cpuCount;
    final contextSwitchTime = executionSetup.settings.contextSwitchTime;
    final timeLimit = executionSetup.settings.timeLimit;

    final cpus = List.generate(numberOfCPUs, (_) => CoreProcessor.empty());
    final cpuTimes = List.filled(numberOfCPUs, 0);
    final remainingTimes = Map.fromEntries(
      queue.map((p) => MapEntry(p.id, p.serviceTime)),
    );

    final readyQueue = <RegularProcess>[];
    int currentTime = 0;

    while (queue.isNotEmpty || readyQueue.isNotEmpty) {
      // Move arrived processes to ready queue
      queue.removeWhere((p) {
        if (p.arrivalTime <= currentTime) {
          readyQueue.add(p);
          return true;
        }
        return false;
      });

      if (readyQueue.isEmpty) {
        currentTime++;
        continue;
      }

      for (int cpu = 0; cpu < numberOfCPUs; cpu++) {
        if (readyQueue.isEmpty) break;

        final core = cpus[cpu].core;
        final cpuTime = cpuTimes[cpu];
        if (cpuTime > currentTime) continue;

        final selected = readyQueue.removeAt(0);
        final remaining = remainingTimes[selected.id]!;
        final slice = remaining <= timeLimit ? remaining : timeLimit;
        final startTime =
            cpuTime < selected.arrivalTime ? selected.arrivalTime : cpuTime;

        // Idle time if CPU is waiting
        if (startTime > cpuTime) {
          final idle = RegularProcess(
            id: ExecutionTimeConstants.freeProcessId,
            arrivalTime: cpuTime,
            serviceTime: startTime - cpuTime,
            enabled: true,
          );
          core.add(HardwareComponent(HardwareState.free, idle));
        }

        // Process execution slice
        final scheduled = selected.copy();
        scheduled.arrivalTime = startTime;
        scheduled.serviceTime = slice;
        core.add(HardwareComponent(HardwareState.busy, scheduled));

        cpuTimes[cpu] = startTime + slice;
        currentTime = cpuTimes[cpu];

        final remainingAfter = remaining - slice;
        if (remainingAfter > 0) {
          remainingTimes[selected.id] = remainingAfter;
          // Re-enqueue with updated arrival time
          readyQueue.add(selected.copy());
        }

        // Context switch
        if (contextSwitchTime > 0 &&
            (remainingAfter > 0 || readyQueue.isNotEmpty || queue.isNotEmpty)) {
          final switching = RegularProcess(
            id: ExecutionTimeConstants.switchContextProcessId,
            arrivalTime: cpuTimes[cpu],
            serviceTime: contextSwitchTime,
            enabled: true,
          );
          core.add(
            HardwareComponent(HardwareState.switchingContext, switching),
          );
          cpuTimes[cpu] += contextSwitchTime;
          currentTime = cpuTimes[cpu];
        }
      }
    }

    return Machine(cpus: cpus, ioChannels: []);
  }

  /// Calculates machine execution using burst-based processes with Time Limit scheduling.
  ///
  /// For burst processes with Time Limit:
  /// - Each thread in a process executes its bursts sequentially
  /// - CPU bursts are limited by timeLimit per execution turn
  /// - I/O bursts run to completion (no time limit)
  /// - If CPU burst exceeds time limit, it's re-queued with remaining time
  /// - Threads can run concurrently within the same process
  /// - FIFO ordering within the ready queue
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
    final timeLimit = executionSetup.settings.timeLimit;

    // Create CPUs and I/O channels
    final cpus = List.generate(numberOfCPUs, (_) => CoreProcessor.empty());
    final ioChannels =
        List.generate(numberOfIOChannels, (_) => CoreProcessor.empty());

    // Track current time for each CPU and I/O channel
    final cpuTimes = List.filled(numberOfCPUs, 0.0);
    final ioTimes = List.filled(numberOfIOChannels, 0.0);

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

    // Ready queues for CPU and I/O (FIFO order)
    final cpuReadyQueue = <_ThreadExecution>[];
    final ioReadyQueue = <_ThreadExecution>[];
    final completedThreads = <_ThreadExecution>[];

    double currentTime = 0.0;

    while (allThreads.isNotEmpty ||
        cpuReadyQueue.isNotEmpty ||
        ioReadyQueue.isNotEmpty) {
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

      bool anyProgress = false;

      // Schedule CPU bursts with time limit
      for (int cpu = 0; cpu < numberOfCPUs; cpu++) {
        if (cpuReadyQueue.isNotEmpty && cpuTimes[cpu] <= currentTime) {
          final thread = cpuReadyQueue.removeAt(0);

          // Calculate execution time (limited by timeLimit)
          final executeTime = (thread.remainingTime <= timeLimit)
              ? thread.remainingTime
              : timeLimit.toDouble();

          // Create process representation for this burst
          final burstProcess = RegularProcess(
            id: '${thread.processId}.${thread.threadId}',
            arrivalTime: currentTime.toInt(),
            serviceTime: executeTime.toInt(),
            enabled: true,
          );

          cpus[cpu]
              .core
              .add(HardwareComponent(HardwareState.busy, burstProcess));
          cpuTimes[cpu] = currentTime + executeTime;
          thread.remainingTime -= executeTime;

          // Check if burst is complete
          if (thread.remainingTime <= 0) {
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
          } else {
            // Time limit exceeded, re-queue with remaining time
            thread.arrivalTime = cpuTimes[cpu];
            cpuReadyQueue.add(thread);
          }

          // Add context switch if needed
          if (contextSwitchTime > 0 &&
              (cpuReadyQueue.isNotEmpty ||
                  allThreads.any((t) =>
                      t.arrivalTime <= cpuTimes[cpu] &&
                      t.currentBurst?.type == BurstType.cpu))) {
            final switchProcess = RegularProcess(
              id: ExecutionTimeConstants.switchContextProcessId,
              arrivalTime: cpuTimes[cpu].toInt(),
              serviceTime: contextSwitchTime,
              enabled: true,
            );
            cpus[cpu].core.add(HardwareComponent(
                HardwareState.switchingContext, switchProcess));
            cpuTimes[cpu] += contextSwitchTime;
          }

          anyProgress = true;
        }
      }

      // Schedule I/O bursts (no time limit - run to completion)
      for (int ioChannel = 0; ioChannel < numberOfIOChannels; ioChannel++) {
        if (ioReadyQueue.isNotEmpty && ioTimes[ioChannel] <= currentTime) {
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

      // Advance time if no progress was made
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

/// Helper class to track thread execution state for Time Limit scheduling
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
