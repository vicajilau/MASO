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
    final queue = <RegularProcess>[];
    final pending = List<RegularProcess>.from(filtered);

    // Main scheduling loop
    while (queue.isNotEmpty || pending.isNotEmpty) {
      bool anyExecuted = false;
      final requeue = <RegularProcess>[];

      final minTime = cpuTimes.reduce((a, b) => a < b ? a : b);

      final nextArrivals = <RegularProcess>[];
      pending.removeWhere((p) {
        if (p.arrivalTime <= minTime) {
          nextArrivals.add(p.copy());
          return true;
        }
        return false;
      });

      // Primero añadimos los procesos recién llegados antes de procesar CPUs
      queue.addAll(nextArrivals);

      for (int cpu = 0; cpu < numberOfCPUs; cpu++) {
        final core = cpus[cpu].core;

        // Si cola vacía, CPU idle si espera procesos pendientes
        if (queue.isEmpty) {
          if (pending.isNotEmpty && cpuTimes[cpu] < pending.first.arrivalTime) {
            final idleTime = pending.first.arrivalTime - cpuTimes[cpu];
            final idleProcess = RegularProcess(
              id: ExecutionTimeConstants.freeProcessId,
              arrivalTime: cpuTimes[cpu],
              serviceTime: idleTime,
              enabled: true,
            );
            core.add(HardwareComponent(HardwareState.free, idleProcess));
            cpuTimes[cpu] += idleTime;
          }
          continue;
        }

        final process = queue.removeAt(0);
        final executionTime =
            process.remainingTime > quantum ? quantum : process.remainingTime;

        final adjustedProcess = process.copy();
        adjustedProcess.arrivalTime = cpuTimes[cpu];
        adjustedProcess.serviceTime = executionTime;

        core.add(HardwareComponent(HardwareState.busy, adjustedProcess));
        cpuTimes[cpu] += executionTime;

        final remainingTime = process.remainingTime - executionTime;
        if (remainingTime > 0) {
          final remaining = process.copy();
          remaining.remainingTime = remainingTime;
          remaining.arrivalTime = cpuTimes[cpu];
          requeue.add(remaining); // Añadimos para reinsertar después
        }

        if (contextSwitchTime > 0) {
          final switchProcess = RegularProcess(
            id: ExecutionTimeConstants.switchContextProcessId,
            arrivalTime: cpuTimes[cpu],
            serviceTime: contextSwitchTime,
            enabled: true,
          );
          core.add(
              HardwareComponent(HardwareState.switchingContext, switchProcess));
          cpuTimes[cpu] += contextSwitchTime;
        }

        anyExecuted = true;
      }

      // Finalmente añadimos los procesos interrumpidos al final de la cola
      queue.addAll(requeue);

      if (!anyExecuted && pending.isNotEmpty) {
        final nextArrival = pending.first.arrivalTime;
        for (int i = 0; i < cpuTimes.length; i++) {
          if (cpuTimes[i] < nextArrival) {
            cpuTimes[i] = nextArrival;
          }
        }
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
