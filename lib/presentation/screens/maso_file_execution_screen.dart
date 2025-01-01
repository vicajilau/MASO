import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:maso/domain/models/execution_setup.dart';
import 'package:maso/domain/models/scheduling_algorithm.dart';

import '../../../core/service_locator.dart';
import '../../../domain/models/maso_file.dart';
import '../../../domain/models/process.dart';

class MasoFileExecutionScreen extends StatefulWidget {
  const MasoFileExecutionScreen({super.key});

  @override
  State<MasoFileExecutionScreen> createState() =>
      _MasoFileExecutionScreenState();
}

class _MasoFileExecutionScreenState extends State<MasoFileExecutionScreen> {
  late List<Process> _processes;
  late SchedulingAlgorithm _selectedAlgorithm;

  @override
  void initState() {
    super.initState();

    // Load the ExecutionSetup and the MasoFile from the ServiceLocator
    final executionSetup = ServiceLocator.instance.getIt<ExecutionSetup>();
    final masoFile = ServiceLocator.instance.getIt<MasoFile>();

    _selectedAlgorithm = executionSetup.algorithm;

    // Load processes from the MASO file
    _processes = masoFile.processes;

    // Start the execution of the processes immediately
    executeProcesses();
  }

  // Function to execute processes according to the selected algorithm
  void executeProcesses() {
    switch (_selectedAlgorithm) {
      case SchedulingAlgorithm.firstComeFirstServed:
        _processes.sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));
        break;
      case SchedulingAlgorithm.shortestJobFirst:
        _processes.sort((a, b) => a.serviceTime.compareTo(b.serviceTime));
        break;
      case SchedulingAlgorithm.shortestRemainingTimeFirst:
        // Implement Shortest Remaining Time First logic here
        break;
      case SchedulingAlgorithm.roundRobin:
        // Implement Round Robin execution logic here
        break;
      case SchedulingAlgorithm.priorityBased:
        // Implement Priority Based scheduling logic here
        break;
      case SchedulingAlgorithm.multiplePriorityQueues:
        // Implement Multiple Priority Queues scheduling logic here
        break;
      case SchedulingAlgorithm.multiplePriorityQueuesWithFeedback:
        // Implement Multiple Priority Queues with Feedback scheduling logic here
        break;
      case SchedulingAlgorithm.timeLimit:
        // Implement Time Limit scheduling logic here
        break;
    }

    // Trigger UI update after execution
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.executionScreenTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display a temporal line of process execution
            Expanded(
              child: ListView(
                children: _processes.map((process) {
                  return ListTile(
                    title: Text(process.name),
                    subtitle: Text(
                        'Arrival Time: ${process.arrivalTime}, Service Time: ${process.serviceTime}'),
                    trailing: Text('Execution Time: 10'),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
