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

/// Execution time service implementing the Multiple Priority Queues with Feedback scheduling algorithm.
///
/// This algorithm starts all processes in the highest priority queue (priority level 0),
/// and demotes processes to lower priority queues if they consume their entire time quantum without finishing.
/// Each priority queue has its own time quantum, and processes are scheduled in a round-robin manner among CPUs.
/// The scheduling continues until all processes are completed.
/// Supports only regular (non-burst) processes.
class MultiplePriorityQueuesWithFeedbackExecutionTimeService
    extends BaseExecutionTimeService {
  /// Constructs the service with the given list of processes and execution setup.
  MultiplePriorityQueuesWithFeedbackExecutionTimeService(
      super.processes, super.executionSetup);

  /// Calculates the machine execution timeline for regular processes using
  /// the Multiple Priority Queues with Feedback scheduling algorithm.
  ///
  /// - Processes are initially placed in the highest priority queue.
  /// - Each queue has an associated time quantum.
  /// - If a process does not finish within its quantum, it is moved to the next lower priority queue.
  /// - CPUs are assigned in round-robin fashion.
  /// - Idle times and context switching are accounted for.
  /// - Returns a `Machine` instance representing the schedule.
  @override
  Machine calculateMachineWithRegularProcesses() {
    final allProcesses = processes.whereType<RegularProcess>().toList();
    final numberOfCPUs = executionSetup.settings.cpuCount;
    final contextSwitchTime = executionSetup.settings.contextSwitchTime;

    // Time quantum per priority level; can be configured or adjusted
    final List<int> timeQuanta = [4, 6, 8];

    // Initialize the priority queues; one queue per priority level
    final List<List<RegularProcess>> queues =
        List.generate(timeQuanta.length, (_) => []);

    // All processes start in the highest priority queue (level 0),
    // sorted by arrival time
    final processQueue = [...allProcesses]
      ..sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));
    queues[0].addAll(processQueue);

    // Initialize CPUs and their current times
    final cpus = List.generate(numberOfCPUs, (_) => CoreProcessor.empty());
    final cpuTimes = List.filled(numberOfCPUs, 0);
    int currentCPU = 0;

    // While there are processes in any queue
    while (queues.any((q) => q.isNotEmpty)) {
      for (int level = 0; level < queues.length; level++) {
        final queue = queues[level];

        int index = 0;
        // Iterate through all processes in this priority queue
        while (index < queue.length) {
          final process = queue[index];

          final cpuTime = cpuTimes[currentCPU];
          final startTime =
              cpuTime < process.arrivalTime ? process.arrivalTime : cpuTime;

          final core = cpus[currentCPU].core;

          // Add idle time if CPU is free before process starts
          if (startTime > cpuTime) {
            final idle = RegularProcess(
              id: ExecutionTimeConstants.freeProcessId,
              arrivalTime: cpuTime,
              serviceTime: startTime - cpuTime,
              enabled: true,
            );
            core.add(HardwareComponent(HardwareState.free, idle));
          }

          // Determine quantum and execution time for this process slice
          final quantum = timeQuanta[level];
          final remaining = process.serviceTime;
          final executedTime = remaining > quantum ? quantum : remaining;

          // Create a copy of the process with updated arrival time and service time
          final running = process.copy()
            ..arrivalTime = startTime
            ..serviceTime = executedTime;

          // Mark CPU as busy executing this process slice
          core.add(HardwareComponent(HardwareState.busy, running));
          cpuTimes[currentCPU] = startTime + executedTime;

          // Add context switching time if configured
          if (contextSwitchTime > 0) {
            final switching = RegularProcess(
              id: ExecutionTimeConstants.switchContextProcessId,
              arrivalTime: cpuTimes[currentCPU],
              serviceTime: contextSwitchTime,
              enabled: true,
            );
            core.add(
                HardwareComponent(HardwareState.switchingContext, switching));
            cpuTimes[currentCPU] += contextSwitchTime;
          }

          // If process did not finish, move leftover to next lower priority queue
          if (remaining > quantum && level + 1 < queues.length) {
            final leftover = process.copy()
              ..arrivalTime = cpuTimes[currentCPU]
              ..serviceTime = remaining - quantum;

            queues[level + 1].add(leftover);
          }

          // Remove the process from the current queue
          queue.removeAt(index);

          // Round-robin CPU assignment
          currentCPU = (currentCPU + 1) % numberOfCPUs;
        }
      }
    }

    return Machine(cpus: cpus, ioChannels: []);
  }

  /// Calculates machine execution using burst-based processes with Multiple Priority Queues with Feedback.
  ///
  /// For burst processes with MPQ Feedback:
  /// - Each thread in a process executes its bursts sequentially
  /// - CPU bursts use multiple priority queues with feedback (demotion on quantum expiry)
  /// - I/O bursts are non-preemptive and use FIFO scheduling
  /// - Threads start in highest priority queue and can be demoted
  /// - Threads can run concurrently within the same process
  /// - Quantum-based time slicing for CPU bursts only
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
    final quantum = executionSetup.settings.quantum;

    // Create CPUs and I/O channels
    final cpus = List.generate(numberOfCPUs, (_) => CoreProcessor.empty());
    final ioChannels =
        List.generate(numberOfIOChannels, (_) => CoreProcessor.empty());

    // Track current time for each CPU and I/O channel
    final cpuTimes = List.filled(numberOfCPUs, 0.0);
    final ioTimes = List.filled(numberOfIOChannels, 0.0);

    // Create multiple priority queues for CPU (3 levels with increasing quantum)
    final cpuQueues = <List<_ThreadExecution>>[];
    for (int i = 0; i < 3; i++) {
      cpuQueues.add(<_ThreadExecution>[]);
    }

    // Single queue for I/O (non-preemptive)
    final ioQueue = <_ThreadExecution>[];

    // Create a list of all enabled threads from all processes
    final allThreads = <_ThreadExecution>[];
    for (final process in burstProcesses) {
      for (final thread in process.threads.where((t) => t.enabled)) {
        allThreads.add(_ThreadExecution(
          processId: process.id,
          threadId: thread.id,
          priority: 0, // Start in highest priority queue
          arrivalTime: process.arrivalTime.toDouble(),
          bursts: List.from(thread.bursts),
          currentBurstIndex: 0,
          remainingTime: thread.bursts.isNotEmpty
              ? thread.bursts[0].duration.toDouble()
              : 0.0,
        ));
      }
    }

    final completedThreads = <_ThreadExecution>[];
    double currentTime = 0.0;

    while (allThreads.isNotEmpty ||
        _hasThreadsInQueues(cpuQueues) ||
        ioQueue.isNotEmpty) {
      // Add newly arrived threads to appropriate queues
      allThreads.removeWhere((thread) {
        if (thread.arrivalTime <= currentTime) {
          if (thread.currentBurst?.type == BurstType.cpu) {
            cpuQueues[thread.priority].add(thread);
          } else if (thread.currentBurst?.type == BurstType.io) {
            ioQueue.add(thread);
          }
          return true;
        }
        return false;
      });

      bool anyProgress = false;

      // Schedule CPU bursts with feedback (higher priority queues first)
      for (int cpu = 0; cpu < numberOfCPUs; cpu++) {
        if (cpuTimes[cpu] <= currentTime) {
          final thread = _getNextThreadFromQueues(cpuQueues);
          if (thread != null) {
            // Calculate quantum for current priority level
            final currentQuantum = quantum * (thread.priority + 1);

            // Calculate execution time for this quantum
            final executeTime = (thread.remainingTime <= currentQuantum)
                ? thread.remainingTime
                : currentQuantum.toDouble();

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
                thread.priority = 0; // Reset to highest priority for new burst
                allThreads.add(thread);
              } else {
                completedThreads.add(thread);
              }
            } else {
              // Quantum expired, demote to lower priority queue if possible
              if (thread.priority < cpuQueues.length - 1) {
                thread.priority++;
              }
              thread.arrivalTime = cpuTimes[cpu];
              cpuQueues[thread.priority].add(thread);
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

      // Schedule I/O bursts (non-preemptive FIFO)
      for (int ioChannel = 0; ioChannel < numberOfIOChannels; ioChannel++) {
        if (ioQueue.isNotEmpty && ioTimes[ioChannel] <= currentTime) {
          final thread = ioQueue.removeAt(0);

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
            thread.priority = 0; // Reset to highest priority for new burst
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

/// Helper class to track thread execution state for Multiple Priority Queues with Feedback
class _ThreadExecution {
  final String processId;
  final String threadId;
  int priority;
  double arrivalTime;
  final List<Burst> bursts;
  int currentBurstIndex;
  double remainingTime;

  _ThreadExecution({
    required this.processId,
    required this.threadId,
    required this.priority,
    required this.arrivalTime,
    required this.bursts,
    required this.currentBurstIndex,
    required this.remainingTime,
  });

  Burst? get currentBurst =>
      currentBurstIndex < bursts.length ? bursts[currentBurstIndex] : null;
}
