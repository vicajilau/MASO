import 'package:flutter/material.dart';
import 'package:maso/domain/models/scheduling_algorithm.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../domain/models/execution_setup.dart';

class ExecutionSetupDialog extends StatefulWidget {
  const ExecutionSetupDialog({super.key});

  @override
  State<ExecutionSetupDialog> createState() => _ExecutionSetupDialogState();
}

class _ExecutionSetupDialogState extends State<ExecutionSetupDialog> {
  SchedulingAlgorithm _selectedAlgorithm =
      SchedulingAlgorithm.firstComeFirstServed;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.executionSetupTitle),
      content: Column(
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
              child: Text(AppLocalizations.of(context)!
                  .algorithmLabel(algorithm.name)),
            ))
                .toList(),
            decoration: InputDecoration(
              labelText:
              AppLocalizations.of(context)!.selectAlgorithmLabel,
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancelButton),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(
              context,
              ExecutionSetup(algorithm: _selectedAlgorithm),
            );
          },
          child: Text(AppLocalizations.of(context)!.acceptButton),
        ),
      ],
    );
  }
}
