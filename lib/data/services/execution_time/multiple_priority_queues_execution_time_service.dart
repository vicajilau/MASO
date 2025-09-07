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

/// Execution time service implementing the Multiple Priority Queues scheduling algorithm.
///
/// This algorithm organizes processes into multiple priority queues,
/// where each queue corresponds to a priority level.
/// Processes in higher priority queues (lower numeric value) are executed first,
/// and within each queue processes are scheduled in FIFO order.
/// Processes are assigned to CPUs in a round-robin fashion.
/// Idle times and context switches are handled appropriately.
/// Supports only regular (non-burst) processes.
class MultiplePriorityQueuesExecutionTimeService
    extends BaseExecutionTimeService {
  /// Constructs the service with the provided list of processes and execution setup.
  MultiplePriorityQueuesExecutionTimeService(
      super.processes, super.executionSetup);

  /// Calculates the machine execution timeline for regular processes using
  /// the Multiple Priority Queues scheduling algorithm.
  ///
  /// - Processes are grouped by their `priority` value.
  /// - Each queue is sorted by `arrivalTime` ascending.
  /// - Queues are processed from highest priority (lowest number) to lowest.
  /// - Processes are assigned to CPUs in round-robin order.
  /// - Idle times and context switch times are added as needed.
  /// - Returns a `Machine` object representing the schedule.
  @override
  Machine calculateMachineWithRegularProcesses() {
    final allProcesses = processes.whereType<RegularProcess>().toList();
    final numberOfCPUs = executionSetup.settings.cpuCount;
    final contextSwitchTime = executionSetup.settings.contextSwitchTime;

    // Group processes by priority level
    final Map<int, List<RegularProcess>> priorityQueues = {};
    for (var process in allProcesses) {
      if (!process.enabled) continue;
      priorityQueues.putIfAbsent(process.priority, () => []).add(process);
    }

    // Sort priorities ascending (higher priority first)
    final sortedPriorities = priorityQueues.keys.toList()..sort();

    // Initialize empty CPU cores
    final List<CoreProcessor> cpus = List.generate(
      numberOfCPUs,
      (_) => CoreProcessor.empty(),
    );
    final List<int> cpuTimes = List.filled(numberOfCPUs, 0);
    int currentCPU = 0;

    // Process each priority queue in order
    for (final priority in sortedPriorities) {
      final queue = priorityQueues[priority]!
        ..sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));

      for (var i = 0; i < queue.length; i++) {
        final process = queue[i];
        final core = cpus[currentCPU].core;
        final currentCpuTime = cpuTimes[currentCPU];

        // Determine the actual start time for the process on this CPU
        final startTime = currentCpuTime < process.arrivalTime
            ? process.arrivalTime
            : currentCpuTime;

        // Add idle time if CPU is free before this process starts
        if (startTime > currentCpuTime) {
          final idleProcess = RegularProcess(
            id: ExecutionTimeConstants.freeProcessId,
            arrivalTime: currentCpuTime,
            serviceTime: startTime - currentCpuTime,
            enabled: true,
          );
          core.add(HardwareComponent(HardwareState.free, idleProcess));
        }

        // Copy the process and adjust its arrival time for scheduling
        final processCopied = process.copy();
        processCopied.arrivalTime = startTime;

        // Add the process as a busy component in the CPU core timeline
        core.add(HardwareComponent(HardwareState.busy, processCopied));
        cpuTimes[currentCPU] = startTime + process.serviceTime;

        // Determine if a context switch should be added after this process
        // Conditions:
        // - There are more processes in the current queue after this one, OR
        // - There are lower priority queues to process afterward
        final willBeUsedAgain = i + numberOfCPUs < queue.length ||
            sortedPriorities.indexOf(priority) < sortedPriorities.length - 1;

        if (contextSwitchTime > 0 && willBeUsedAgain) {
          final switchProcess = RegularProcess(
            id: ExecutionTimeConstants.switchContextProcessId,
            arrivalTime: cpuTimes[currentCPU],
            serviceTime: contextSwitchTime,
            enabled: true,
          );
          core.add(
              HardwareComponent(HardwareState.switchingContext, switchProcess));
          cpuTimes[currentCPU] += contextSwitchTime;
        }

        // Move to the next CPU for round-robin assignment
        currentCPU = (currentCPU + 1) % numberOfCPUs;
      }
    }

    return Machine(cpus: cpus, ioChannels: []);
  }

  /// Burst processes are not supported in this scheduling algorithm.
  /// Calculates machine execution using burst-based processes with Multiple Priority Queues.
  ///
  /// For burst processes with Multiple Priority Queues:
  /// - Each thread in a process executes its bursts sequentially
  /// - Since BurstProcess doesn't have priority, uses FIFO order by arrival time
  /// - CPU bursts are scheduled by arrival time within queues
  /// - I/O bursts are scheduled by arrival time within queues
  /// - Threads can run concurrently within the same process
  /// - Non-preemptive scheduling (bursts run to completion)
  @override
  Machine calculateMachineWithBurstProcesses() {
    // Filter and sort burst processes by arrival time (since no priority available)
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

    // Create multiple priority queues - since no priority, use single queue per resource type
    final cpuQueues = <List<_ThreadExecution>>[];
    final ioQueues = <List<_ThreadExecution>>[];

    // Initialize single priority queue (priority 0) for each resource type
    cpuQueues.add(<_ThreadExecution>[]);
    ioQueues.add(<_ThreadExecution>[]);

    // Create a list of all enabled threads from all processes
    final allThreads = <_ThreadExecution>[];
    for (final process in burstProcesses) {
      for (final thread in process.threads.where((t) => t.enabled)) {
        allThreads.add(_ThreadExecution(
          processId: process.id,
          threadId: thread.id,
          priority:
              0, // Default priority since BurstProcess doesn't have priority
          arrivalTime: process.arrivalTime.toDouble(),
          bursts: List.from(thread.bursts),
          currentBurstIndex: 0,
        ));
      }
    }

    final completedThreads = <_ThreadExecution>[];
    double currentTime = 0.0;

    while (allThreads.isNotEmpty ||
        _hasThreadsInQueues(cpuQueues) ||
        _hasThreadsInQueues(ioQueues)) {
      // Add newly arrived threads to appropriate priority queues
      allThreads.removeWhere((thread) {
        if (thread.arrivalTime <= currentTime) {
          if (thread.currentBurst?.type == BurstType.cpu) {
            cpuQueues[thread.priority].add(thread);
          } else if (thread.currentBurst?.type == BurstType.io) {
            ioQueues[thread.priority].add(thread);
          }
          return true;
        }
        return false;
      });

      bool anyProgress = false;

      // Schedule CPU bursts from highest priority queues first
      for (int cpu = 0; cpu < numberOfCPUs; cpu++) {
        if (cpuTimes[cpu] <= currentTime) {
          final thread = _getNextThreadFromQueues(cpuQueues);
          if (thread != null) {
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
                (_hasThreadsInQueues(cpuQueues) ||
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
      }

      // Schedule I/O bursts from highest priority queues first
      for (int ioChannel = 0; ioChannel < numberOfIOChannels; ioChannel++) {
        if (ioTimes[ioChannel] <= currentTime) {
          final thread = _getNextThreadFromQueues(ioQueues);
          if (thread != null) {
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

  /// Helper method to check if any priority queue has threads
  bool _hasThreadsInQueues(List<List<_ThreadExecution>> queues) {
    return queues.any((queue) => queue.isNotEmpty);
  }

  /// Helper method to get next thread from highest priority non-empty queue
  _ThreadExecution? _getNextThreadFromQueues(
      List<List<_ThreadExecution>> queues) {
    for (final queue in queues) {
      if (queue.isNotEmpty) {
        return queue.removeAt(0);
      }
    }
    return null;
  }
}

/// Helper class to track thread execution state for Multiple Priority Queues
class _ThreadExecution {
  final String processId;
  final String threadId;
  final int priority;
  double arrivalTime;
  final List<Burst> bursts;
  int currentBurstIndex;

  _ThreadExecution({
    required this.processId,
    required this.threadId,
    required this.priority,
    required this.arrivalTime,
    required this.bursts,
    required this.currentBurstIndex,
  });

  Burst? get currentBurst =>
      currentBurstIndex < bursts.length ? bursts[currentBurstIndex] : null;
}
