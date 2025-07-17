import 'package:maso/core/constants/execution_time_constants.dart';
import 'package:maso/data/services/execution_time/base_execution_time_service.dart';
import 'package:maso/domain/models/machine.dart';

import '../../../domain/models/core_processor.dart';
import '../../../domain/models/hardware_component.dart';
import '../../../domain/models/hardware_state.dart';
import '../../../domain/models/maso/regular_process.dart';

/// Execution time service for the Multiple Priority Queues scheduling algorithm.
///
/// This algorithm organizes processes into multiple priority queues
/// and executes higher-priority queues first, using FIFO within each queue.
/// It supports only regular (non-burst) processes.
class MultiplePriorityQueuesExecutionTimeService
    extends BaseExecutionTimeService {
  /// Constructs the service with the provided process list and execution setup.
  MultiplePriorityQueuesExecutionTimeService(
      super.processes, super.executionSetup);

  /// Calculates the execution machine for regular processes using multiple priority queues.
  ///
  /// - Processes are grouped by `priority`.
  /// - Each queue is sorted by `arrivalTime`.
  /// - Queues are executed in order from highest to lowest priority (lower value = higher priority).
  /// - Processes are distributed to CPUs round-robin, handling idle and context switching.
  @override
  Machine calculateMachineWithRegularProcesses() {
    final allProcesses = processes.whereType<RegularProcess>().toList();
    final numberOfCPUs = executionSetup.settings.cpuCount;
    final contextSwitchTime = executionSetup.settings.contextSwitchTime;

    // Agrupar procesos por prioridad
    final Map<int, List<RegularProcess>> priorityQueues = {};
    for (var process in allProcesses) {
      if (!process.enabled) continue;
      priorityQueues.putIfAbsent(process.priority, () => []).add(process);
    }

    // Ordenar claves de prioridad ascendente (prioridad más alta primero)
    final sortedPriorities = priorityQueues.keys.toList()..sort();

    // Inicializar CPUs vacías
    final List<CoreProcessor> cpus = List.generate(
      numberOfCPUs,
      (_) => CoreProcessor.empty(),
    );
    final List<int> cpuTimes = List.filled(numberOfCPUs, 0);
    int currentCPU = 0;

    for (final priority in sortedPriorities) {
      final queue = priorityQueues[priority]!
        ..sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));

      for (var i = 0; i < queue.length; i++) {
        final process = queue[i];
        final core = cpus[currentCPU].core;
        final currentCpuTime = cpuTimes[currentCPU];

        final startTime = currentCpuTime < process.arrivalTime
            ? process.arrivalTime
            : currentCpuTime;

        // Insertar tiempo ocioso si hace falta
        if (startTime > currentCpuTime) {
          final idleProcess = RegularProcess(
            id: ExecutionTimeConstants.freeProcessId,
            arrivalTime: currentCpuTime,
            serviceTime: startTime - currentCpuTime,
            enabled: true,
          );
          core.add(HardwareComponent(HardwareState.free, idleProcess));
        }

        // Copiar proceso y ajustar arrivalTime
        final processCopied = process.copy();
        processCopied.arrivalTime = startTime;

        core.add(HardwareComponent(HardwareState.busy, processCopied));
        cpuTimes[currentCPU] = startTime + process.serviceTime;

        // Añadir cambio de contexto si se reutilizará esta CPU
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

        currentCPU = (currentCPU + 1) % numberOfCPUs;
      }
    }

    return Machine(cpus: cpus, ioChannels: []);
  }

  /// Burst processes are not supported for this algorithm.
  @override
  Machine calculateMachineWithBurstProcesses() {
    throw UnimplementedError();
  }
}
