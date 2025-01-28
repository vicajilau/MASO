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
  List<IProcess> calculateExecutionTimes(List<IProcess> processes) {
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
  List<IProcess> _calculateFirstComeFirstServed(List<IProcess> processes) {
    // Sort processes by their arrival time (the first process to arrive should be processed first)
    processes.sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));

    int currentTime = 0; // Start from time 0
    for (var process in processes) {
      // If the process arrives after the current time, the CPU waits until it arrives
      if (process.arrivalTime > currentTime) {
        currentTime = process.arrivalTime;
      }

      // Calculate the execution time: it is the current time + the service time of the process
      process.executionTime = 0;

      // Update the current time to the point when this process finishes
      currentTime = process.executionTime;
    }

    return processes;
  }

  /// Calculates the execution time for the "Shortest Job First" (SJF) algorithm.
  ///
  /// [processes] List of processes to be processed.
  ///
  /// Returns the list of processes with the execution time calculated according to SJF.
  List<IProcess> _calculateShortestJobFirst(List<IProcess> processes) {
    // Logic for Shortest Job First algorithm
    return processes;
  }

  /// Calculates the execution time for the "Shortest Remaining Time First" (SRTF) algorithm.
  ///
  /// [processes] List of processes to be processed.
  ///
  /// Returns the list of processes with the execution time calculated according to SRTF.
  List<IProcess> _calculateShortestRemainingTimeFirst(List<IProcess> processes) {
    // Logic for Shortest Remaining Time First algorithm
    return processes;
  }

  /// Calculates the execution time for the "Round Robin" (RR) algorithm.
  ///
  /// [processes] List of processes to be processed.
  ///
  /// Returns the list of processes with the execution time calculated according to Round Robin.
  List<IProcess> _calculateRoundRobin(List<IProcess> processes) {
    // Logic for Round Robin algorithm
    return processes;
  }

  /// Calculates the execution time for the "Priority Based" scheduling algorithm.
  ///
  /// [processes] List of processes to be processed.
  ///
  /// Returns the list of processes with the execution time calculated according to the Priority Based algorithm.
  List<IProcess> _calculatePriorityBased(List<IProcess> processes) {
    // Logic for Priority Based algorithm
    return processes;
  }

  /// Calculates the execution time for the "Multiple Priority Queues" scheduling algorithm.
  ///
  /// [processes] List of processes to be processed.
  ///
  /// Returns the list of processes with the execution time calculated according to Multiple Priority Queues.
  List<IProcess> _calculateMultiplePriorityQueues(List<IProcess> processes) {
    // Logic for Multiple Priority Queues algorithm
    return processes;
  }

  /// Calculates the execution time for the "Multiple Priority Queues with Feedback" scheduling algorithm.
  ///
  /// [processes] List of processes to be processed.
  ///
  /// Returns the list of processes with the execution time calculated according to Multiple Priority Queues with Feedback.
  List<IProcess> _calculateMultiplePriorityQueuesWithFeedback(
      List<IProcess> processes) {
    // Logic for Multiple Priority Queues with Feedback algorithm
    return processes;
  }

  /// Calculates the execution time for the "Time Limit" scheduling algorithm.
  ///
  /// [processes] List of processes to be processed.
  ///
  /// Returns the list of processes with the execution time calculated according to Time Limit.
  List<IProcess> _calculateTimeLimit(List<IProcess> processes) {
    // Logic for Time Limit algorithm
    return processes;
  }
}
