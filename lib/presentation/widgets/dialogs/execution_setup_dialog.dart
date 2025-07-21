import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maso/domain/models/scheduling_algorithm.dart';
import 'package:maso/domain/models/settings_maso.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/service_locator.dart';
import '../../../domain/models/execution_setup.dart';

class ExecutionSetupDialog extends StatefulWidget {
  const ExecutionSetupDialog({super.key});

  @override
  State<ExecutionSetupDialog> createState() => _ExecutionSetupDialogState();
}

class _ExecutionSetupDialogState extends State<ExecutionSetupDialog> {
  ExecutionSetup? _previousES;
  SchedulingAlgorithm _selectedAlgorithm =
      SchedulingAlgorithm.firstComeFirstServed;
  final TextEditingController _quantumController = TextEditingController();
  final TextEditingController _queueQuantaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (ServiceLocator.instance.getIt.isRegistered<ExecutionSetup>()) {
      _previousES = ServiceLocator.instance.getIt<ExecutionSetup>();
      _selectedAlgorithm = _previousES!.algorithm;

      // If there was already a quantum, fill it in
      if (_selectedAlgorithm == SchedulingAlgorithm.roundRobin) {
        final previousQuantum = _previousES!.settings.quantum;
        _quantumController.text = previousQuantum.toString();
      } else if (_selectedAlgorithm ==
          SchedulingAlgorithm.multiplePriorityQueuesWithFeedback) {
        final previousQueueQuanta = _previousES!.settings.queueQuanta;
        _queueQuantaController.text = previousQueueQuanta.toString();
      }
    }
  }

  @override
  void dispose() {
    _quantumController.dispose();
    _queueQuantaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width (you can also adjust the multiplier based on your design)
    double screenWidth = MediaQuery.of(context).size.width;
    double maxWidth = screenWidth * 0.5;

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
              items: SchedulingAlgorithm.values.map((algorithm) {
                return DropdownMenuItem<SchedulingAlgorithm>(
                  value: algorithm,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Text(
                      AppLocalizations.of(context)!
                          .algorithmLabel(algorithm.name),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.selectAlgorithmLabel,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedAlgorithm == SchedulingAlgorithm.roundRobin)
              TextFormField(
                controller: _quantumController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.quantumLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
            if (_selectedAlgorithm ==
                SchedulingAlgorithm.multiplePriorityQueuesWithFeedback)
              TextFormField(
                controller: _queueQuantaController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.queueQuantaLabel,
                  border: const OutlineInputBorder(),
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
          onPressed: () async {
            final settings = ServiceLocator.instance.getIt<SettingsMaso>();

            if (_selectedAlgorithm == SchedulingAlgorithm.roundRobin) {
              final parsed = int.tryParse(_quantumController.text);
              if (parsed == null || parsed <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text(AppLocalizations.of(context)!.invalidQuantumError),
                  ),
                );
                return;
              }
              settings.quantum = parsed;
            } else if (_selectedAlgorithm ==
                SchedulingAlgorithm.multiplePriorityQueuesWithFeedback) {
              final parsed = _queueQuantaController.text
                  .split(',')
                  .map((e) => int.tryParse(e.trim()))
                  .toList();

              // Check if there is any null or <= 0 value
              final isInvalid = parsed.any((e) => e == null || e <= 0);
              if (isInvalid) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        AppLocalizations.of(context)!.invalidQueueQuantaError),
                  ),
                );
                return;
              }

              settings.queueQuanta = parsed.cast<int>();
            }
            await settings.saveToPreferences();
            ServiceLocator.instance.registerSettings(settings);

            if (!context.mounted) return;
            context.pop(ExecutionSetup(
              algorithm: _selectedAlgorithm,
              settings: settings,
            ));
          },
          child: Text(AppLocalizations.of(context)!.acceptButton),
        ),
      ],
    );
  }
}
