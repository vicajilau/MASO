import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class ExitConfirmationScreen extends StatelessWidget {
  const ExitConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.confirmExitTitle),
      content: Text(AppLocalizations.of(context)!.confirmExitMessage),
      actions: [
        TextButton(
          onPressed: () => context.pop(false),
          child: Text(AppLocalizations.of(context)!.cancelButton),
        ),
        ElevatedButton(
          onPressed: () => context.pop(true),
          child: Text(AppLocalizations.of(context)!.exitButton),
        ),
      ],
    );
  }
}
