import 'package:maso/core/extensions/process_list_extension.dart';
import 'package:maso/data/services/execution_time/base_execution_time_service.dart';
import 'package:maso/data/services/execution_time/fifo_execution_time_service.dart';
import 'package:maso/domain/models/machine.dart';
import 'package:maso/domain/models/maso/process_mode.dart';

import '../../core/debug_print.dart';
import '../../domain/models/execution_setup.dart';
import '../../domain/models/maso/i_process.dart';
import '../../domain/models/scheduling_algorithm.dart';

/// A class responsible for calculating the execution time of processes based on the selected scheduling algorithm.
/// This class uses the `ExecutionSetup` to determine the algorithm to apply.
class ExecutionTimeCalculatorService {
  /// The execution setup that holds the selected scheduling algorithm.
  final ExecutionSetup executionSetup;

  /// Constructor to initialize the `ExecutionTimeCalculator` with the required `ExecutionSetup`.
  /// The `ExecutionSetup` contains the scheduling algorithm to be used for calculating the execution time.
  ExecutionTimeCalculatorService({required this.executionSetup});

  /// Method to calculate the execution times of a list of processes based on the selected scheduling algorithm.
  /// It switches between different algorithms and applies the corresponding calculation method.
  ///
  /// [processes] List of processes whose execution times need to be calculated.
  ///
  /// Returns a new list of processes with their `executionTime` calculated based on the algorithm.
  Machine calculateExecutionTimes(List<IProcess> processes) {
    // Depending on the selected algorithm, calculate the execution time.
    final filteredProcesses =
        processes.where((process) => process.enabled).toList();
    final BaseExecutionTimeService executor;
    switch (executionSetup.algorithm) {
      case SchedulingAlgorithm.firstComeFirstServed:
        executor = FifoExecutionTimeService(filteredProcesses, executionSetup);
      case SchedulingAlgorithm.shortestJobFirst:
        executor = FifoExecutionTimeService(filteredProcesses, executionSetup);
      case SchedulingAlgorithm.shortestRemainingTimeFirst:
        executor = FifoExecutionTimeService(filteredProcesses, executionSetup);
      case SchedulingAlgorithm.roundRobin:
        executor = FifoExecutionTimeService(filteredProcesses, executionSetup);
      case SchedulingAlgorithm.priorityBased:
        executor = FifoExecutionTimeService(filteredProcesses, executionSetup);
      case SchedulingAlgorithm.multiplePriorityQueues:
        executor = FifoExecutionTimeService(filteredProcesses, executionSetup);
      case SchedulingAlgorithm.multiplePriorityQueuesWithFeedback:
        executor = FifoExecutionTimeService(filteredProcesses, executionSetup);
      case SchedulingAlgorithm.timeLimit:
        executor = FifoExecutionTimeService(filteredProcesses, executionSetup);
    }

    final Machine machine;
    switch (processes.getMode()) {
      case ProcessesMode.regular:
        machine = executor.calculateMachineWithRegularProcesses();
      case ProcessesMode.burst:
        machine = executor.calculateMachineWithBurstProcesses();
    }
    printInDebug("La machine calculada es: $machine");
    return machine;
  }
}
