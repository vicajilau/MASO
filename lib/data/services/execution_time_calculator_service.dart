import 'package:maso/core/debug_print.dart';
import 'package:maso/domain/models/hardware_state.dart';
import 'package:maso/domain/models/machine.dart';

import '../../domain/models/execution_setup.dart';
import '../../domain/models/hardware_component.dart';
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
    switch (executionSetup.algorithm) {
      case SchedulingAlgorithm.firstComeFirstServed:
        return _calculateFirstComeFirstServed(filteredProcesses);
      case SchedulingAlgorithm.shortestJobFirst:
        return _calculateShortestJobFirst(filteredProcesses);
      case SchedulingAlgorithm.shortestRemainingTimeFirst:
        return _calculateShortestRemainingTimeFirst(filteredProcesses);
      case SchedulingAlgorithm.roundRobin:
        return _calculateRoundRobin(filteredProcesses);
      case SchedulingAlgorithm.priorityBased:
        return _calculatePriorityBased(filteredProcesses);
      case SchedulingAlgorithm.multiplePriorityQueues:
        return _calculateMultiplePriorityQueues(filteredProcesses);
      case SchedulingAlgorithm.multiplePriorityQueuesWithFeedback:
        return _calculateMultiplePriorityQueuesWithFeedback(filteredProcesses);
      case SchedulingAlgorithm.timeLimit:
        return _calculateTimeLimit(filteredProcesses);
    }
  }

  /// Calculates the execution time for the "First Come First Served" (FCFS) algorithm.
  ///
  /// [processes] List of processes to be processed.
  ///
  /// Returns the list of processes with the execution time calculated according to FCFS.
  Machine _calculateFirstComeFirstServed(List<IProcess> processes) {
    // Sort processes by their arrival time (the first process to arrive should be processed first)
    processes.sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));
    final filteredProcesses =
        processes.where((process) => process.enabled).toList();

    final numberOfCPUs = executionSetup.settings.cpuCount;
    final List<List<HardwareComponent>> cpus =
        List.generate(numberOfCPUs, (index) => []);
    int currentCPU = 0;

    for (var process in filteredProcesses) {
      cpus[currentCPU].add(HardwareComponent(HardwareState.busy, process));
      currentCPU = (currentCPU + 1) % numberOfCPUs;
    }

    final machine = Machine(cpus: cpus, ioChannels: []);
    printInDebug("La machine calculada es: $machine");
    return machine;
  }

  /// Calculates the execution time for the "Shortest Job First" (SJF) algorithm.
  ///
  /// [processes] List of processes to be processed.
  ///
  /// Returns the list of processes with the execution time calculated according to SJF.
  Machine _calculateShortestJobFirst(List<IProcess> processes) {
    // Logic for Shortest Job First algorithm
    final machine = Machine(cpus: [], ioChannels: []);
    return machine;
  }

  /// Calculates the execution time for the "Shortest Remaining Time First" (SRTF) algorithm.
  ///
  /// [processes] List of processes to be processed.
  ///
  /// Returns the list of processes with the execution time calculated according to SRTF.
  Machine _calculateShortestRemainingTimeFirst(List<IProcess> processes) {
    // Logic for Shortest Remaining Time First algorithm
    final machine = Machine(cpus: [], ioChannels: []);
    return machine;
  }

  /// Calculates the execution time for the "Round Robin" (RR) algorithm.
  ///
  /// [processes] List of processes to be processed.
  ///
  /// Returns the list of processes with the execution time calculated according to Round Robin.
  Machine _calculateRoundRobin(List<IProcess> processes) {
    // Logic for Round Robin algorithm
    final machine = Machine(cpus: [], ioChannels: []);
    return machine;
  }

  /// Calculates the execution time for the "Priority Based" scheduling algorithm.
  ///
  /// [processes] List of processes to be processed.
  ///
  /// Returns the list of processes with the execution time calculated according to the Priority Based algorithm.
  Machine _calculatePriorityBased(List<IProcess> processes) {
    // Logic for Priority Based algorithm
    final machine = Machine(cpus: [], ioChannels: []);
    return machine;
  }

  /// Calculates the execution time for the "Multiple Priority Queues" scheduling algorithm.
  ///
  /// [processes] List of processes to be processed.
  ///
  /// Returns the list of processes with the execution time calculated according to Multiple Priority Queues.
  Machine _calculateMultiplePriorityQueues(List<IProcess> processes) {
    // Logic for Multiple Priority Queues algorithm
    final machine = Machine(cpus: [], ioChannels: []);
    return machine;
  }

  /// Calculates the execution time for the "Multiple Priority Queues with Feedback" scheduling algorithm.
  ///
  /// [processes] List of processes to be processed.
  ///
  /// Returns the list of processes with the execution time calculated according to Multiple Priority Queues with Feedback.
  Machine _calculateMultiplePriorityQueuesWithFeedback(
      List<IProcess> processes) {
    // Logic for Multiple Priority Queues with Feedback algorithm
    final machine = Machine(cpus: [], ioChannels: []);
    return machine;
  }

  /// Calculates the execution time for the "Time Limit" scheduling algorithm.
  ///
  /// [processes] List of processes to be processed.
  ///
  /// Returns the list of processes with the execution time calculated according to Time Limit.
  Machine _calculateTimeLimit(List<IProcess> processes) {
    // Logic for Time Limit algorithm
    final machine = Machine(cpus: [], ioChannels: []);
    return machine;
  }
}
