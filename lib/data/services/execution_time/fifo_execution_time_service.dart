import 'package:maso/core/constants/execution_time_constants.dart';
import 'package:maso/data/services/execution_time/base_execution_time_service.dart';
import 'package:maso/domain/models/machine.dart';
import 'package:maso/domain/models/maso/i_process.dart';

import '../../../domain/models/core_processor.dart';
import '../../../domain/models/hardware_component.dart';
import '../../../domain/models/hardware_state.dart';
import '../../../domain/models/maso/regular_process.dart';
import '../../../domain/models/maso/burst_process.dart';
import '../../../domain/models/maso/burst.dart';
import '../../../domain/models/maso/burst_type.dart';

/// Execution time service for the First-In, First-Out (FIFO) scheduling algorithm.
///
/// This class implements the `BaseExecutionTimeService` interface,
/// supporting only regular (non-burst) processes.
/// It assigns processes to CPUs in order of arrival, cycling through CPUs,
/// and handles idle times and context switches if configured.
class FifoExecutionTimeService extends BaseExecutionTimeService {
  /// Constructs a FIFO execution time service with the provided process list and setup.
  FifoExecutionTimeService(super.processes, super.executionSetup);

  /// Calculates the execution machine for regular processes using FIFO scheduling.
  ///
  /// - Processes are filtered by their `enabled` flag.
  /// - They are sorted by `arrivalTime`.
  /// - Processes are assigned to CPUs in a round-robin fashion.
  /// - Idle periods are marked with `HardwareState.free`.
  /// - Context switch time is handled if defined in the setup.
  @override
  Machine calculateMachineWithRegularProcesses() {
    final filteredProcesses = processes.whereType<RegularProcess>().toList()
      ..sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));

    final numberOfCPUs = executionSetup.settings.cpuCount;
    final contextSwitchTime = executionSetup.settings.contextSwitchTime;

    // Initialize empty CPU cores
    List<CoreProcessor> cpus = List.generate(
      numberOfCPUs,
      (_) => CoreProcessor.empty(),
    );

    // Track the current execution time per CPU
    List<int> cpuTimes = List.filled(numberOfCPUs, 0);
    int currentCPU = 0;

    for (var i = 0; i < filteredProcesses.length; i++) {
      final process = filteredProcesses[i];
      final core = cpus[currentCPU].core;

      final currentCpuTime = cpuTimes[currentCPU];

      // Determine the start time: either the process arrival or when the CPU is free
      final startTime = currentCpuTime < process.arrivalTime
          ? process.arrivalTime
          : currentCpuTime;

      // Add a 'free' block if there is idle time
      if (startTime > currentCpuTime) {
        final idleProcess = RegularProcess(
          id: ExecutionTimeConstants.freeProcessId,
          arrivalTime: currentCpuTime,
          serviceTime: startTime - currentCpuTime,
          enabled: true,
        );

        core.add(HardwareComponent(HardwareState.free, idleProcess));
      }

      // Copy and adjust the process start time
      IProcess processCopied = process.copy();
      processCopied.arrivalTime = startTime;

      // Add the process as a busy component
      core.add(HardwareComponent(HardwareState.busy, processCopied));

      cpuTimes[currentCPU] = startTime + process.serviceTime;

      // Add context switch if this CPU will be reused
      final willThisCPUBeUsedAgain =
          i + numberOfCPUs < filteredProcesses.length;

      if (contextSwitchTime > 0 && willThisCPUBeUsedAgain) {
        final switchProcess = RegularProcess(
          id: ExecutionTimeConstants.switchContextProcessId,
          arrivalTime: cpuTimes[currentCPU],
          serviceTime: contextSwitchTime,
          enabled: true,
        );

        core.add(HardwareComponent(
          HardwareState.switchingContext,
          switchProcess,
        ));

        cpuTimes[currentCPU] += contextSwitchTime;
      }

      // Move to the next CPU (round-robin)
      currentCPU = (currentCPU + 1) % numberOfCPUs;
    }

    return Machine(cpus: cpus, ioChannels: []);
  }

  /// Calculates machine execution using burst-based processes with FIFO scheduling.
  ///
  /// For burst processes:
  /// - Each thread in a process executes its bursts sequentially
  /// - CPU bursts are scheduled on CPUs using FIFO
  /// - I/O bursts are scheduled on I/O channels
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
    final cpuTimes = List.filled(numberOfCPUs, 0);
    final ioTimes = List.filled(numberOfIOChannels, 0);

    // Create a list of all enabled threads from all processes
    final allThreads = <_ThreadExecution>[];
    for (final process in burstProcesses) {
      for (final thread in process.threads.where((t) => t.enabled)) {
        allThreads.add(_ThreadExecution(
          processId: process.id,
          threadId: thread.id,
          arrivalTime: process.arrivalTime,
          bursts: List.from(thread.bursts),
          currentBurstIndex: 0,
        ));
      }
    }

    // Sort threads by arrival time (FIFO)
    allThreads.sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));

    // Ready queues for CPU and I/O
    final cpuReadyQueue = <_ThreadExecution>[];
    final ioReadyQueue = <_ThreadExecution>[];
    final completedThreads = <_ThreadExecution>[];

    int currentTime = 0;

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

      // Schedule CPU bursts
      for (int cpu = 0; cpu < numberOfCPUs; cpu++) {
        if (cpuReadyQueue.isNotEmpty && cpuTimes[cpu] <= currentTime) {
          final thread = cpuReadyQueue.removeAt(0);
          final burst = thread.currentBurst!;

          // Create process representation for this burst
          final burstProcess = RegularProcess(
            id: '${thread.processId}.${thread.threadId}',
            arrivalTime: currentTime,
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
              arrivalTime: cpuTimes[cpu],
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
            arrivalTime: currentTime,
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

/// Helper class to track thread execution state
class _ThreadExecution {
  final String processId;
  final String threadId;
  int arrivalTime;
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
