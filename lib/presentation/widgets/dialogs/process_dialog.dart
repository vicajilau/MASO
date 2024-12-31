import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:maso/domain/models/list_processes_extension.dart';
import 'package:maso/domain/models/process.dart';

class ProcessDialog extends StatefulWidget {
  final Process? process;
  final List<Process> existingProcesses;
  final int? processPosition;

  const ProcessDialog(
      {super.key,
      this.process,
      required this.existingProcesses,
      this.processPosition});

  @override
  State<ProcessDialog> createState() => _ProcessDialogState();
}

class _ProcessDialogState extends State<ProcessDialog> {
  late TextEditingController _nameController;
  late TextEditingController _arrivalTimeController;
  late TextEditingController _serviceTimeController;
  late bool _isEnabled;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.process?.name ?? '');
    _arrivalTimeController = TextEditingController(
        text: widget.process?.arrivalTime.toString() ?? '');
    _serviceTimeController = TextEditingController(
        text: widget.process?.serviceTime.toString() ?? '');
    _isEnabled =
        widget.process?.enabled ?? true; // Default to enabled for creation
  }

  @override
  void dispose() {
    _nameController.dispose();
    _arrivalTimeController.dispose();
    _serviceTimeController.dispose();
    super.dispose();
  }

  bool _validateInput() {
    final name = _nameController.text.trim();
    final arrivalTime = int.tryParse(_arrivalTimeController.text);
    final serviceTime = int.tryParse(_serviceTimeController.text);

    if (name.isEmpty) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.emptyNameError;
      });
      return false;
    }

    if (widget.existingProcesses
        .containProcessWithName(name, position: widget.processPosition)) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.duplicateNameError;
      });
      return false;
    }

    if (arrivalTime == null || arrivalTime < 0) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.invalidArrivalTimeError;
      });
      return false;
    }

    if (serviceTime == null || serviceTime <= arrivalTime) {
      setState(() {
        _errorMessage =
            AppLocalizations.of(context)!.invalidTimeDifferenceError;
      });
      return false;
    }

    if ((serviceTime - arrivalTime) < 1) {
      setState(() {
        _errorMessage =
            AppLocalizations.of(context)!.timeDifferenceTooSmallError;
      });
      return false;
    }

    setState(() {
      _errorMessage = null;
    });
    return true;
  }

  void _submit() {
    if (_validateInput()) {
      final newOrUpdatedProcess = Process(
        name: _nameController.text.trim(),
        arrivalTime: int.parse(_arrivalTimeController.text),
        serviceTime: int.parse(_serviceTimeController.text),
        enabled: _isEnabled,
      );
      context.pop(newOrUpdatedProcess);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.process != null;

    return AlertDialog(
      title: Text(
        isEditing
            ? AppLocalizations.of(context)!.editProcessTitle
            : AppLocalizations.of(context)!.createProcessTitle,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.processNameLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _arrivalTimeController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.arrivalTimeDialogLabel,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _serviceTimeController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.serviceTimeDialogLabel,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
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
                      _isEnabled = value;
                    });
                  },
                ),
              ],
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
          onPressed: _submit,
          child: Text(AppLocalizations.of(context)!.saveButton),
        ),
      ],
    );
  }
}
