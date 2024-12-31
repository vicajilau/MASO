import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class CreateMasoFileDialog extends StatefulWidget {
  const CreateMasoFileDialog({super.key});

  @override
  State<CreateMasoFileDialog> createState() => _CreateMasoFileDialogState();
}

class _CreateMasoFileDialogState extends State<CreateMasoFileDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isNotEmpty && description.isNotEmpty) {
      context.pop({
        'name': name,
        'description': description,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.fillAllFieldsError),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.createMasoFileTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.fileNameLabel,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.fileDescriptionLabel,
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
          onPressed: _submit,
          child: Text(AppLocalizations.of(context)!.createButton),
        ),
      ],
    );
  }
}
