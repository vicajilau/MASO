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

/// Execution time service for the Round Robin scheduling algorithm.
///
/// This service schedules regular (non-burst) processes using the Round Robin strategy.
/// It handles quantum slicing and optional context switch delays between processes.
class RoundRobinExecutionTimeService extends BaseExecutionTimeService {
  /// Creates a Round Robin execution time service with the given processes and setup.
  RoundRobinExecutionTimeService(super.processes, super.executionSetup);

  /// Calculates the execution schedule for regular processes using Round Robin.
  ///
  /// - Processes are sorted by their arrival time.
  /// - Each process gets CPU time in `quantum`-sized slices.
  /// - Context switch time is inserted between process slices if configured.
  /// - Processes are requeued until their total service time is consumed.
  /// - Idle time is inserted if no processes are ready and a CPU is idle.
  @override
  Machine calculateMachineWithRegularProcesses() {
    // Filter and sort incoming processes by arrival time
    final filtered = processes.whereType<RegularProcess>().toList()
      ..sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));

    final numberOfCPUs = executionSetup.settings.cpuCount;
    final contextSwitchTime = executionSetup.settings.contextSwitchTime;
    final quantum = executionSetup.settings.quantum;

    // Create one CoreProcessor per CPU
    List<CoreProcessor> cpus = List.generate(
      numberOfCPUs,
      (_) => CoreProcessor.empty(),
    );

    // Tracks current time for each CPU
    List<int> cpuTimes = List.filled(numberOfCPUs, 0);

    // Ready queue and list of processes not yet arrived
    final readyQueue = <RegularProcess>[];
    final arrivingProcesses = List<RegularProcess>.from(filtered);

    int globalTime = 0;

    // Main scheduling loop
    while (readyQueue.isNotEmpty || arrivingProcesses.isNotEmpty) {
      // If no process is ready, advance time to next arrival and add that process
      if (readyQueue.isEmpty && arrivingProcesses.isNotEmpty) {
        globalTime = arrivingProcesses.first.arrivalTime;
        readyQueue.add(arrivingProcesses.removeAt(0));
      }

      // If no processes at all, break
      if (readyQueue.isEmpty) {
        break;
      }

      // For single CPU case, use CPU 0. For multiple CPUs, select the one free earliest
      int selectedCPU = 0;
      if (numberOfCPUs > 1) {
        for (int i = 1; i < numberOfCPUs; i++) {
          if (cpuTimes[i] < cpuTimes[selectedCPU]) {
            selectedCPU = i;
          }
        }
      }

      final core = cpus[selectedCPU].core;
      final cpuTime = cpuTimes[selectedCPU];

      // If CPU is behind global time, add idle time
      if (cpuTime < globalTime) {
        final idleTime = globalTime - cpuTime;
        final idleProcess = RegularProcess(
          id: ExecutionTimeConstants.freeProcessId,
          arrivalTime: cpuTime,
          serviceTime: idleTime,
          enabled: true,
        );
        core.add(HardwareComponent(HardwareState.free, idleProcess));
        cpuTimes[selectedCPU] = globalTime;
      }

      // Get the first process from the ready queue (FIFO)
      final process = readyQueue.removeAt(0);

      // Determine execution time (up to quantum)
      final executionTime =
          process.serviceTime > quantum ? quantum : process.serviceTime;

      // Create execution slice
      final runningProcess = process.copy();
      runningProcess.arrivalTime = cpuTimes[selectedCPU];
      runningProcess.serviceTime = executionTime;

      core.add(HardwareComponent(HardwareState.busy, runningProcess));
      cpuTimes[selectedCPU] += executionTime;

      // Update global time to the end of this execution
      globalTime = cpuTimes[selectedCPU];

      // IMPORTANT: Add any processes that arrived during this execution BEFORE
      // adding the current process back to the queue (if it has remaining time)
      while (arrivingProcesses.isNotEmpty &&
          arrivingProcesses.first.arrivalTime <= globalTime) {
        final arrivingProcess = arrivingProcesses.removeAt(0);
        readyQueue.add(arrivingProcess);
        // Debug: print('t=$globalTime: Process ${arrivingProcess.id} arrives during execution');
      }

      // If process has remaining time, add it back to the END of the ready queue
      final remainingTime = process.serviceTime - executionTime;
      if (remainingTime > 0) {
        final remainingProcess = process.copy();
        remainingProcess.serviceTime = remainingTime;
        readyQueue.add(remainingProcess); // Add to the END of the queue
      }

      // Add context switch if configured and there are more processes to execute
      if (contextSwitchTime > 0 &&
          (readyQueue.isNotEmpty || arrivingProcesses.isNotEmpty)) {
        final switchProcess = RegularProcess(
          id: ExecutionTimeConstants.switchContextProcessId,
          arrivalTime: cpuTimes[selectedCPU],
          serviceTime: contextSwitchTime,
          enabled: true,
        );

        core.add(HardwareComponent(
          HardwareState.switchingContext,
          switchProcess,
        ));

        cpuTimes[selectedCPU] += contextSwitchTime;
        globalTime = cpuTimes[selectedCPU];
      }
    }

    return Machine(cpus: cpus, ioChannels: []);
  }

  /// Not implemented: Round Robin does not support burst processes in this version.
  /// Calculates machine execution using burst-based processes with Round Robin scheduling.
  ///
  /// For burst processes with Round Robin:
  /// - Each thread in a process executes its bursts sequentially
  /// - CPU bursts use Round Robin with quantum time slices
  /// - I/O bursts are non-preemptive (run to completion)
  /// - Threads can run concurrently within the same process
  /// - Time slicing occurs only on CPU bursts
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

    // Ready queues for CPU and I/O (FIFO order for Round Robin)
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

      // Schedule CPU bursts with Round Robin
      for (int cpu = 0; cpu < numberOfCPUs; cpu++) {
        if (cpuReadyQueue.isNotEmpty && cpuTimes[cpu] <= currentTime) {
          final thread = cpuReadyQueue.removeAt(0);

          // Calculate execution time for this quantum
          final executeTime = (thread.remainingTime <= quantum)
              ? thread.remainingTime
              : quantum.toDouble();

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
            // Quantum expired, add back to ready queue
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

      // Schedule I/O bursts (non-preemptive)
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

/// Helper class to track thread execution state for Round Robin
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
