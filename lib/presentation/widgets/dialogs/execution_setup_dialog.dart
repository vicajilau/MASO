import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:maso/domain/models/scheduling_algorithm.dart';

import '../../../core/service_locator.dart';
import '../../../domain/models/execution_setup.dart';

class ExecutionSetupDialog extends StatefulWidget {
  const ExecutionSetupDialog({super.key});

  @override
  State<ExecutionSetupDialog> createState() => _ExecutionSetupDialogState();
}

class _ExecutionSetupDialogState extends State<ExecutionSetupDialog> {
  // The previous ExecutionSetup instance if available (can be null)
  ExecutionSetup? _previousES;

  // The selected scheduling algorithm, defaulting to 'firstComeFirstServed'
  SchedulingAlgorithm _selectedAlgorithm =
      SchedulingAlgorithm.firstComeFirstServed;

  @override
  void initState() {
    super.initState();

    // Check if ExecutionSetup is registered in the service locator before accessing it
    if (ServiceLocator.instance.getIt.isRegistered<ExecutionSetup>()) {
      // Assign the previous ExecutionSetup and update the selected algorithm
      _previousES = ServiceLocator.instance.getIt<ExecutionSetup>();
      _selectedAlgorithm = _previousES!.algorithm;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width (you can also adjust the multiplier based on your design)
    double screenWidth = MediaQuery.of(context).size.width;
    double maxWidth = screenWidth * 0.5; // 50% of the screen width as max width

    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.executionSetupTitle),
      content: SingleChildScrollView(
        // Allow scrolling in case of long text
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<SchedulingAlgorithm>(
              value: _selectedAlgorithm,
              onChanged: (SchedulingAlgorithm? newValue) {
                setState(() {
                  _selectedAlgorithm = newValue!;
                });
              },
              items: SchedulingAlgorithm.values
                  .map((algorithm) => DropdownMenuItem<SchedulingAlgorithm>(
                        value: algorithm,
                        child: ConstrainedBox(
                          // Limit width dynamically
                          constraints:
                              BoxConstraints(maxWidth: maxWidth), // Adapt width
                          child: Text(
                            AppLocalizations.of(context)!
                                .algorithmLabel(algorithm.name),
                            overflow: TextOverflow
                                .ellipsis, // Handle overflow with ellipsis
                          ),
                        ),
                      ))
                  .toList(),
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.selectAlgorithmLabel,
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text(AppLocalizations.of(context)!.cancelButton),
        ),
        ElevatedButton(
          onPressed: () {
            context.pop(ExecutionSetup(algorithm: _selectedAlgorithm));
          },
          child: Text(AppLocalizations.of(context)!.acceptButton),
        ),
      ],
    );
  }
}
