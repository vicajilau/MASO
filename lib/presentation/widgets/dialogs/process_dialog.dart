import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maso/domain/models/list_processes_extension.dart';
import 'package:maso/domain/models/process.dart';

import '../../../core/l10n/app_localizations.dart';

/// A dialog widget for creating or editing a process.
class ProcessDialog extends StatefulWidget {
  final Process? process; // The process being edited (if any).
  final List<Process> existingProcesses; // List of already existing processes.
  final int? processPosition; // Position of the process in the existing list.

  /// Constructor to initialize the dialog with necessary parameters.
  const ProcessDialog(
      {super.key,
      this.process,
      required this.existingProcesses,
      this.processPosition});

  @override
  State<ProcessDialog> createState() => _ProcessDialogState();
}

/// State class for ProcessDialog.
class _ProcessDialogState extends State<ProcessDialog> {
  late TextEditingController
      _nameController; // Controller for the name input field.
  late TextEditingController
      _arrivalTimeController; // Controller for the arrival time input field.
  late TextEditingController
      _serviceTimeController; // Controller for the service time input field.
  late bool _isEnabled; // Indicates if the process is enabled or disabled.

  String? _nameError; // Error message for the name field.
  String? _arrivalTimeError; // Error message for the arrival time field.
  String? _serviceTimeError; // Error message for the service time field.

  @override
  void initState() {
    super.initState();
    // Initialize the text controllers.
    _nameController = TextEditingController();
    _arrivalTimeController = TextEditingController();
    _serviceTimeController = TextEditingController();
    if (widget.process != null) {
      _nameController.text = widget.process!.name;
      _arrivalTimeController.text = widget.process!.arrivalTime.toString();
      _serviceTimeController.text = widget.process!.serviceTime.toString();
      _isEnabled = widget.process!.enabled;
    } else {
      _isEnabled = true;
    }
  }

  @override
  void dispose() {
    // Dispose of the text controllers to free up resources.
    _nameController.dispose();
    _arrivalTimeController.dispose();
    _serviceTimeController.dispose();
    super.dispose();
  }

  /// Validate the input fields.
  bool _validateInput() {
    final name = _nameController.text.trim(); // Get trimmed name input.
    final arrivalTime = int.tryParse(
        _arrivalTimeController.text); // Parse arrival time to an integer.
    final serviceTime = int.tryParse(
        _serviceTimeController.text); // Parse service time to an integer.

    // Reset error messages.
    setState(() {
      _nameError = null;
      _arrivalTimeError = null;
      _serviceTimeError = null;
    });

    // Validate name input.
    if (name.isEmpty) {
      setState(() {
        _nameError = AppLocalizations.of(context)!
            .emptyNameError; // Set error for empty name.
      });
      return false;
    }

    // Check for duplicate process names.
    if (widget.existingProcesses
        .containProcessWithName(name, position: widget.processPosition)) {
      setState(() {
        _nameError = AppLocalizations.of(context)!
            .duplicateNameError; // Set error for duplicate name.
      });
      return false;
    }

    // Validate arrival time input.
    if (arrivalTime == null || arrivalTime < 0) {
      setState(() {
        _arrivalTimeError = AppLocalizations.of(context)!
            .invalidArrivalTimeError; // Set error for invalid arrival time.
      });
      return false;
    }

    // Validate service time input.
    if (serviceTime == null || serviceTime <= arrivalTime) {
      setState(() {
        _serviceTimeError = AppLocalizations.of(context)!
            .invalidTimeDifferenceError; // Set error for invalid service time.
      });
      return false;
    }

    return true; // Input is valid.
  }

  /// Submit the form if input is valid.
  void _submit() {
    if (_validateInput()) {
      // Create a new or updated process instance.
      final newOrUpdatedProcess = Process(
        name: _nameController.text.trim(),
        arrivalTime: int.parse(_arrivalTimeController.text),
        serviceTime: int.parse(_serviceTimeController.text),
        enabled: _isEnabled,
      );
      context.pop(
          newOrUpdatedProcess); // Return the new/updated process to the previous context.
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!
          .createProcessTitle), // Title of the dialog.
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Name input field.
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.processNameLabel,
                errorText: _nameError,
                errorMaxLines: 2,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _nameError = null; // Clear error when the user types.
                });
              },
            ),
            const SizedBox(height: 10), // Spacing between fields.
            // Arrival time input field.
            TextFormField(
              controller: _arrivalTimeController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.arrivalTimeDialogLabel,
                errorText: _arrivalTimeError,
                errorMaxLines: 2,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number, // Numeric keyboard for input.
              onChanged: (value) {
                setState(() {
                  _arrivalTimeError = null; // Clear error when the user types.
                });
              },
            ),
            const SizedBox(height: 10), // Spacing between fields.
            // Service time input field.
            TextFormField(
              controller: _serviceTimeController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.serviceTimeDialogLabel,
                errorText: _serviceTimeError,
                errorMaxLines: 2,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number, // Numeric keyboard for input.
              onChanged: (value) {
                setState(() {
                  _serviceTimeError = null; // Clear error when the user types.
                });
              },
            ),
            const SizedBox(height: 10), // Spacing between fields.
            // Switch to toggle enabled/disabled state.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isEnabled
                      ? AppLocalizations.of(context)!.enabledLabel
                      : AppLocalizations.of(context)!.disabledLabel,
                ),
                Switch(
                  value: _isEnabled,
                  onChanged: (value) {
                    setState(() {
                      _isEnabled = value; // Update the enabled state.
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        // Cancel button to close the dialog without saving.
        TextButton(
          onPressed: () => context.pop(),
          child: Text(AppLocalizations.of(context)!.cancelButton),
        ),
        // Save button to submit the form.
        ElevatedButton(
          onPressed: _submit,
          child: Text(AppLocalizations.of(context)!.saveButton),
        ),
      ],
    );
  }
}
