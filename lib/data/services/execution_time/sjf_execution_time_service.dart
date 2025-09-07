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

/// Execution time service for the Shortest Job First (SJF) scheduling algorithm.
///
/// This class implements the `BaseExecutionTimeService` interface,
/// supporting only regular (non-burst) processes.
/// It assigns processes to CPUs based on the shortest service time,
/// considering only those that have arrived at the current time.
/// Idle times and context switches are handled if configured.
class SjfExecutionTimeService extends BaseExecutionTimeService {
  SjfExecutionTimeService(super.processes, super.executionSetup);

  @override
  Machine calculateMachineWithRegularProcesses() {
    final readyQueue = processes.whereType<RegularProcess>().toList();

    final numberOfCPUs = executionSetup.settings.cpuCount;
    final contextSwitchTime = executionSetup.settings.contextSwitchTime;

    final cpus = List.generate(numberOfCPUs, (_) => CoreProcessor.empty());
    final cpuTimes = List.filled(numberOfCPUs, 0);

    int currentTime = 0;

    while (readyQueue.isNotEmpty) {
      // Process filter for processes that have arrived
      final available =
          readyQueue.where((p) => p.arrivalTime <= currentTime).toList();

      // If there are no available processes, advance the time to the next arrival
      if (available.isEmpty) {
        final nextArrival = readyQueue
            .map((p) => p.arrivalTime)
            .reduce((a, b) => a < b ? a : b);
        currentTime = nextArrival;
        continue;
      }

      // Sort by service time
      available.sort((a, b) => a.serviceTime.compareTo(b.serviceTime));
      final selected = available.first;
      readyQueue.remove(selected);

      // Choose CPU with the shortest time on the CPU (the one that will be free before)
      int selectedCpu = 0;
      for (int i = 1; i < numberOfCPUs; i++) {
        if (cpuTimes[i] < cpuTimes[selectedCpu]) {
          selectedCpu = i;
        }
      }

      final core = cpus[selectedCpu].core;
      final cpuTime = cpuTimes[selectedCpu];
      final startTime =
          cpuTime < selected.arrivalTime ? selected.arrivalTime : cpuTime;

      // Insert idle time if necessary
      if (startTime > cpuTime) {
        final idle = RegularProcess(
          id: ExecutionTimeConstants.freeProcessId,
          arrivalTime: cpuTime,
          serviceTime: startTime - cpuTime,
          enabled: true,
        );
        core.add(HardwareComponent(HardwareState.free, idle));
      }

      // Clone process with adjusted arrival time
      final scheduled = selected.copy();
      scheduled.arrivalTime = startTime;
      core.add(HardwareComponent(HardwareState.busy, scheduled));

      cpuTimes[selectedCpu] = startTime + selected.serviceTime;
      currentTime = cpuTimes[selectedCpu];

      // Add context switch if there are more processes
      if (contextSwitchTime > 0 && readyQueue.isNotEmpty) {
        final switching = RegularProcess(
          id: ExecutionTimeConstants.switchContextProcessId,
          arrivalTime: cpuTimes[selectedCpu],
          serviceTime: contextSwitchTime,
          enabled: true,
        );
        core.add(HardwareComponent(HardwareState.switchingContext, switching));
        cpuTimes[selectedCpu] += contextSwitchTime;
        currentTime = cpuTimes[selectedCpu];
      }
    }

    return Machine(cpus: cpus, ioChannels: []);
  }

  /// Calculates machine execution using burst-based processes with SJF scheduling.
  ///
  /// For burst processes with SJF:
  /// - Each thread in a process executes its bursts sequentially
  /// - CPU bursts are scheduled on CPUs using SJF (shortest CPU burst first)
  /// - I/O bursts are scheduled on I/O channels using SJF (shortest I/O burst first)
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

      // Sort ready queues by burst duration (SJF)
      cpuReadyQueue.sort((a, b) => (a.currentBurst?.duration ?? 0)
          .compareTo(b.currentBurst?.duration ?? 0));
      ioReadyQueue.sort((a, b) => (a.currentBurst?.duration ?? 0)
          .compareTo(b.currentBurst?.duration ?? 0));

      bool anyProgress = false;

      // Schedule CPU bursts
      for (int cpu = 0; cpu < numberOfCPUs; cpu++) {
        if (cpuReadyQueue.isNotEmpty && cpuTimes[cpu] <= currentTime) {
          final thread = cpuReadyQueue.removeAt(0);
          final burst = thread.currentBurst!;

          // Create process representation for this burst
          final burstProcess = RegularProcess(
            id: '${thread.processId}.${thread.threadId}',
            arrivalTime: currentTime.toInt(),
            serviceTime: burst.duration,
            enabled: true,
          );

          cpus[cpu]
              .core
              .add(HardwareComponent(HardwareState.busy, burstProcess));
          cpuTimes[cpu] = currentTime + burst.duration;

          // Move to next burst
          thread.currentBurstIndex++;
          if (thread.currentBurstIndex < thread.bursts.length) {
            thread.arrivalTime =
                cpuTimes[cpu]; // Available after this burst completes
            allThreads.add(thread);
          } else {
            completedThreads.add(thread);
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

      // Schedule I/O bursts
      for (int ioChannel = 0; ioChannel < numberOfIOChannels; ioChannel++) {
        if (ioReadyQueue.isNotEmpty && ioTimes[ioChannel] <= currentTime) {
          final thread = ioReadyQueue.removeAt(0);
          final burst = thread.currentBurst!;

          // Create process representation for this I/O burst
          final burstProcess = RegularProcess(
            id: '${thread.processId}.${thread.threadId}',
            arrivalTime: currentTime.toInt(),
            serviceTime: burst.duration,
            enabled: true,
          );

          ioChannels[ioChannel]
              .core
              .add(HardwareComponent(HardwareState.busy, burstProcess));
          ioTimes[ioChannel] = currentTime + burst.duration;

          // Move to next burst
          thread.currentBurstIndex++;
          if (thread.currentBurstIndex < thread.bursts.length) {
            thread.arrivalTime =
                ioTimes[ioChannel]; // Available after this I/O completes
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

/// Helper class to track thread execution state for SJF
class _ThreadExecution {
  final String processId;
  final String threadId;
  double arrivalTime;
  final List<Burst> bursts;
  int currentBurstIndex;

  _ThreadExecution({
    required this.processId,
    required this.threadId,
    required this.arrivalTime,
    required this.bursts,
    required this.currentBurstIndex,
  });

  Burst? get currentBurst =>
      currentBurstIndex < bursts.length ? bursts[currentBurstIndex] : null;
}
