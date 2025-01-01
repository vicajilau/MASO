import 'package:maso/domain/models/process.dart';

import '../../domain/models/execution_setup.dart';
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
  List<Process> calculateExecutionTimes(List<Process> processes) {
    // Depending on the selected algorithm, calculate the execution time.
    switch (executionSetup.algorithm) {
      case SchedulingAlgorithm.firstComeFirstServed:
        return _calculateFirstComeFirstServed(processes);
      case SchedulingAlgorithm.shortestJobFirst:
        return _calculateShortestJobFirst(processes);
      case SchedulingAlgorithm.shortestRemainingTimeFirst:
        return _calculateShortestRemainingTimeFirst(processes);
      case SchedulingAlgorithm.roundRobin:
        return _calculateRoundRobin(processes);
      case SchedulingAlgorithm.priorityBased:
        return _calculatePriorityBased(processes);
      case SchedulingAlgorithm.multiplePriorityQueues:
        return _calculateMultiplePriorityQueues(processes);
      case SchedulingAlgorithm.multiplePriorityQueuesWithFeedback:
        return _calculateMultiplePriorityQueuesWithFeedback(processes);
      case SchedulingAlgorithm.timeLimit:
        return _calculateTimeLimit(processes);
    }
  }

  /// Calculates the execution time for the "First Come First Served" (FCFS) algorithm.
  ///
  /// [processes] List of processes to be processed.
  ///
  /// Returns the list of processes with the execution time calculated according to FCFS.
  List<Process> _calculateFirstComeFirstServed(List<Process> processes) {
    // Sort processes by their arrival time (the first process to arrive should be processed first)
    processes.sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));

    int currentTime = 0; // Start from time 0
    for (var process in processes) {
      // If the process arrives after the current time, the CPU waits until it arrives
      if (process.arrivalTime > currentTime) {
        currentTime = process.arrivalTime;
      }

      // Calculate the execution time: it is the current time + the service time of the process
      process.executionTime = currentTime + process.serviceTime;

      // Update the current time to the point when this process finishes
      currentTime = process.executionTime!;
    }

    return processes;
  }

  /// Calculates the execution time for the "Shortest Job First" (SJF) algorithm.
  ///
  /// [processes] List of processes to be processed.
  ///
  /// Returns the list of processes with the execution time calculated according to SJF.
  List<Process> _calculateShortestJobFirst(List<Process> processes) {
    // Logic for Shortest Job First algorithm
    return processes;
  }

  /// Calculates the execution time for the "Shortest Remaining Time First" (SRTF) algorithm.
  ///
  /// [processes] List of processes to be processed.
  ///
  /// Returns the list of processes with the execution time calculated according to SRTF.
  List<Process> _calculateShortestRemainingTimeFirst(List<Process> processes) {
    // Logic for Shortest Remaining Time First algorithm
    return processes;
  }

  /// Calculates the execution time for the "Round Robin" (RR) algorithm.
  ///
  /// [processes] List of processes to be processed.
  ///
  /// Returns the list of processes with the execution time calculated according to Round Robin.
  List<Process> _calculateRoundRobin(List<Process> processes) {
    // Logic for Round Robin algorithm
    return processes;
  }

  /// Calculates the execution time for the "Priority Based" scheduling algorithm.
  ///
  /// [processes] List of processes to be processed.
  ///
  /// Returns the list of processes with the execution time calculated according to the Priority Based algorithm.
  List<Process> _calculatePriorityBased(List<Process> processes) {
    // Logic for Priority Based algorithm
    return processes;
  }

  /// Calculates the execution time for the "Multiple Priority Queues" scheduling algorithm.
  ///
  /// [processes] List of processes to be processed.
  ///
  /// Returns the list of processes with the execution time calculated according to Multiple Priority Queues.
  List<Process> _calculateMultiplePriorityQueues(List<Process> processes) {
    // Logic for Multiple Priority Queues algorithm
    return processes;
  }

  /// Calculates the execution time for the "Multiple Priority Queues with Feedback" scheduling algorithm.
  ///
  /// [processes] List of processes to be processed.
  ///
  /// Returns the list of processes with the execution time calculated according to Multiple Priority Queues with Feedback.
  List<Process> _calculateMultiplePriorityQueuesWithFeedback(
      List<Process> processes) {
    // Logic for Multiple Priority Queues with Feedback algorithm
    return processes;
  }

  /// Calculates the execution time for the "Time Limit" scheduling algorithm.
  ///
  /// [processes] List of processes to be processed.
  ///
  /// Returns the list of processes with the execution time calculated according to Time Limit.
  List<Process> _calculateTimeLimit(List<Process> processes) {
    // Logic for Time Limit algorithm
    return processes;
  }
}
