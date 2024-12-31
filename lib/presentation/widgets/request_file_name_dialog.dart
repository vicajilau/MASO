import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class RequestFileNameDialog extends StatefulWidget {
  const RequestFileNameDialog({super.key});

  @override
  State<RequestFileNameDialog> createState() => _RequestFileNameDialogState();
}

class _RequestFileNameDialogState extends State<RequestFileNameDialog> {
  late TextEditingController _controller;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _validateInput() {
    final filename = _controller.text.trim();

    if (filename.isEmpty) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.emptyFileNameMessage;
      });
      return false;
    }

    // Verificar si el nombre del archivo termina en '.maso'
    if (!filename.endsWith('.maso')) {
      _controller.text = "$filename.maso"; // Actualiza el texto sin el error
    }

    setState(() {
      _errorMessage = null; // Limpiar el mensaje de error
    });
    return true;
  }

  void _submit() {
    if (_validateInput()) {
      context.pop(_controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.requestFileNameTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              onChanged: (value) {
                setState(() {
                  _errorMessage = null;
                });
              },
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.fileNameHint,
                errorText: _errorMessage,
              ),
            ),
            const SizedBox(height: 10),
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
          child: Text(AppLocalizations.of(context)!.acceptButton),
        ),
      ],
    );
  }
}
