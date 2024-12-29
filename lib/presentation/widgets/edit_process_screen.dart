import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:maso/domain/models/process.dart';

class EditProcessScreen extends StatefulWidget {
  final Process process;

  const EditProcessScreen({super.key, required this.process});

  @override
  State<EditProcessScreen> createState() => _EditProcessScreenState();
}

class _EditProcessScreenState extends State<EditProcessScreen> {
  late TextEditingController _nameController;
  late TextEditingController _arrivalTimeController;
  late TextEditingController _serviceTimeController;
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.process.name);
    _arrivalTimeController =
        TextEditingController(text: widget.process.arrivalTime.toString());
    _serviceTimeController =
        TextEditingController(text: widget.process.serviceTime.toString());
    _isEnabled = widget.process.enabled;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _arrivalTimeController.dispose();
    _serviceTimeController.dispose();
    super.dispose();
  }

  void _submit() {
    final updatedProcess = Process(
      name: _nameController.text,
      arrivalTime: int.tryParse(_arrivalTimeController.text) ?? 0,
      serviceTime: int.tryParse(_serviceTimeController.text) ?? 0,
      enabled: _isEnabled,
    );
    context.pop(updatedProcess);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.editProcessTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.processNameLabel,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _arrivalTimeController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.arrivalTimeDialogLabel,
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _serviceTimeController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.serviceTimeDialogLabel,
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_isEnabled
                    ? AppLocalizations.of(context)!.enabledLabel
                    : AppLocalizations.of(context)!.disabledLabel),
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
