import 'package:maso/core/constants/execution_time_constants.dart';
import 'package:maso/data/services/execution_time/base_execution_time_service.dart';
import 'package:maso/domain/models/machine.dart';

import '../../../domain/models/core_processor.dart';
import '../../../domain/models/cpu_state.dart';
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
    final filtered = processes.whereType<RegularProcess>().toList()
      ..sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));

    final numberOfCPUs = executionSetup.settings.cpuCount;
    final contextSwitchTime = executionSetup.settings.contextSwitchTime;
    final quantum = executionSetup.settings.quantum;

    final cpus = List.generate(numberOfCPUs, (_) => CoreProcessor.empty());
    final cpuStates = List.generate(numberOfCPUs, (_) => CPUState());

    final pending = List<RegularProcess>.from(filtered);
    final queue = <RegularProcess>[];

    int time = 0;

    while (pending.isNotEmpty ||
        queue.isNotEmpty ||
        cpuStates.any((c) => !c.idle)) {
      // Adding processes that arrive at this instant
      final arrivals = <RegularProcess>[];
      pending.removeWhere((p) {
        if (p.arrivalTime == time) {
          arrivals.add(p.copy());
          return true;
        }
        return false;
      });
      if (arrivals.isNotEmpty) {
        queue.addAll(arrivals);
      }

      // Run logic for each CPU
      for (int cpu = 0; cpu < numberOfCPUs; cpu++) {
        final core = cpus[cpu].core;
        final state = cpuStates[cpu];

        // If CPU is in context switch, reduce its duration
        if (state.contextSwitchRemaining > 0) {
          state.contextSwitchRemaining--;
          continue;
        }

        // If CPU is busy, reduce execution time
        if (state.executing != null) {
          state.executionRemaining--;
          if (state.executionRemaining == 0) {
            final finished = state.executing! as RegularProcess;
            final remaining = finished.remainingTime - state.executedQuantum;

            if (remaining > 0) {
              final requeued = finished.copy();
              requeued.remainingTime = remaining;
              requeued.arrivalTime = time;
              queue.add(requeued);
            }

            // Register execution completion
            final completed = finished.copy();
            completed.serviceTime = state.executedQuantum;
            completed.arrivalTime = time - state.executedQuantum;
            core.add(HardwareComponent(HardwareState.busy, completed));

            state.executing = null;
            state.executedQuantum = 0;

            if (contextSwitchTime > 0) {
              final switchProcess = RegularProcess(
                id: ExecutionTimeConstants.switchContextProcessId,
                arrivalTime: time,
                serviceTime: contextSwitchTime,
                enabled: true,
              );
              core.add(HardwareComponent(
                  HardwareState.switchingContext, switchProcess));
              state.contextSwitchRemaining = contextSwitchTime;
            }
          }
          continue;
        }

        // If CPU is idle and queue is not empty, assign a new process
        if (state.executing == null &&
            queue.isNotEmpty &&
            state.contextSwitchRemaining == 0) {
          final process = queue.removeAt(0);
          final executionTime =
              process.remainingTime > quantum ? quantum : process.remainingTime;

          final toExecute = process.copy();
          toExecute.serviceTime = executionTime;
          toExecute.arrivalTime = time;

          state.executing = process;
          state.executionRemaining = executionTime;
          state.executedQuantum = executionTime;
        }

        // If CPU is idle and queue is empty, mark as FREE
        if (state.executing == null &&
            queue.isEmpty &&
            state.contextSwitchRemaining == 0) {
          core.add(HardwareComponent(
            HardwareState.free,
            RegularProcess(
              id: ExecutionTimeConstants.freeProcessId,
              arrivalTime: time,
              serviceTime: 1,
              enabled: true,
            ),
          ));
        }
      }
      time++;
    }

    return Machine(cpus: cpus, ioChannels: []);
  }

  /// Not implemented: Round Robin does not support burst processes in this version.
  @override
  Machine calculateMachineWithBurstProcesses() {
    throw UnimplementedError();
  }
}
