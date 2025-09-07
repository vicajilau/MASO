import 'package:maso/core/constants/execution_time_constants.dart';
import 'package:maso/data/services/execution_time/base_execution_time_service.dart';
import 'package:maso/domain/models/machine.dart';

import '../../../domain/models/core_processor.dart';
import '../../../domain/models/hardware_component.dart';
import '../../../domain/models/hardware_state.dart';
import '../../../domain/models/maso/regular_process.dart';

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
  @override
  Machine calculateMachineWithBurstProcesses() {
    throw UnimplementedError();
  }
}
