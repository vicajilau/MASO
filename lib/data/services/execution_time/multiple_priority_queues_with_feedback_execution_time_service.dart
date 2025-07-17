import 'package:maso/core/constants/execution_time_constants.dart';
import 'package:maso/data/services/execution_time/base_execution_time_service.dart';
import 'package:maso/domain/models/machine.dart';

import '../../../domain/models/core_processor.dart';
import '../../../domain/models/hardware_component.dart';
import '../../../domain/models/hardware_state.dart';
import '../../../domain/models/maso/regular_process.dart';

/// Execution time service for the Multiple Priority Queues with Feedback scheduling algorithm.
///
/// This algorithm starts all processes in the highest-priority queue and demotes them to lower-priority
/// queues if they use up their time quantum without finishing.
class MultiplePriorityQueuesWithFeedbackExecutionTimeService
    extends BaseExecutionTimeService {
  MultiplePriorityQueuesWithFeedbackExecutionTimeService(
      super.processes, super.executionSetup);

  @override
  Machine calculateMachineWithRegularProcesses() {
    final allProcesses = processes.whereType<RegularProcess>().toList();
    final numberOfCPUs = executionSetup.settings.cpuCount;
    final contextSwitchTime = executionSetup.settings.contextSwitchTime;

    // Cuantos de tiempo por nivel de prioridad
    final List<int> timeQuanta = [4, 6, 8]; // Puedes ajustar o sacar de config

    // Inicializar colas de prioridad
    final List<List<RegularProcess>> queues =
        List.generate(timeQuanta.length, (_) => []);

    // Todos los procesos comienzan en la cola de prioridad 0
    final processQueue = [...allProcesses]
      ..sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));
    queues[0].addAll(processQueue);

    // CPUs y tiempos
    final cpus = List.generate(numberOfCPUs, (_) => CoreProcessor.empty());
    final cpuTimes = List.filled(numberOfCPUs, 0);
    int currentCPU = 0;

    // Mientras haya procesos en alguna cola
    while (queues.any((q) => q.isNotEmpty)) {
      for (int level = 0; level < queues.length; level++) {
        final queue = queues[level];

        int index = 0;
        while (index < queue.length) {
          final process = queue[index];

          final cpuTime = cpuTimes[currentCPU];
          final startTime =
              cpuTime < process.arrivalTime ? process.arrivalTime : cpuTime;

          final core = cpus[currentCPU].core;

          // Añadir tiempo inactivo si hay hueco
          if (startTime > cpuTime) {
            final idle = RegularProcess(
              id: ExecutionTimeConstants.freeProcessId,
              arrivalTime: cpuTime,
              serviceTime: startTime - cpuTime,
              enabled: true,
            );
            core.add(HardwareComponent(HardwareState.free, idle));
          }

          final quantum = timeQuanta[level];
          final remaining = process.serviceTime;
          final executedTime = remaining > quantum ? quantum : remaining;

          final running = process.copy()
            ..arrivalTime = startTime
            ..serviceTime = executedTime;

          core.add(HardwareComponent(HardwareState.busy, running));
          cpuTimes[currentCPU] = startTime + executedTime;

          // Context switch
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

          // Reinsertar si no terminó
          if (remaining > quantum && level + 1 < queues.length) {
            final leftover = process.copy()
              ..arrivalTime = cpuTimes[currentCPU]
              ..serviceTime = remaining - quantum;

            queues[level + 1].add(leftover);
          }

          // Eliminar del nivel actual
          queue.removeAt(index);

          // Round-robin entre CPUs
          currentCPU = (currentCPU + 1) % numberOfCPUs;
        }
      }
    }

    return Machine(cpus: cpus, ioChannels: []);
  }

  @override
  Machine calculateMachineWithBurstProcesses() {
    throw UnimplementedError();
  }
}
