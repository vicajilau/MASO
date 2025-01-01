import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../core/service_locator.dart';
import '../../../domain/models/maso_file.dart';
import '../../../domain/models/process.dart';
import '../../data/services/execution_time_calculator_service.dart';

class MasoFileExecutionScreen extends StatefulWidget {
  const MasoFileExecutionScreen({super.key});

  @override
  State<MasoFileExecutionScreen> createState() =>
      _MasoFileExecutionScreenState();
}

class _MasoFileExecutionScreenState extends State<MasoFileExecutionScreen> {
  late List<Process> _processes;

  @override
  void initState() {
    super.initState();

    // Load the ExecutionSetup and the MasoFile from the ServiceLocator
    final masoFile = ServiceLocator.instance.getIt<MasoFile>();

    // Load processes from the MASO file
    _processes = masoFile.processes;

    // Start the execution of the processes immediately
    executeProcesses();
  }

  // Function to execute processes according to the selected algorithm
  void executeProcesses() {
    final executionTimeCalculator =
        ServiceLocator.instance.getIt<ExecutionTimeCalculatorService>();

    // Use the executionTimeCalculator to calculate the execution times
    _processes = executionTimeCalculator.calculateExecutionTimes(_processes);

    // Trigger UI update after execution
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.executionScreenTitle),
        actions: [],
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
                    // Display the calculated execution time
                    trailing: Text(
                        'Execution Time: ${process.executionTime ?? 'N/A'}'),
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
