import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class ExitConfirmationScreen extends StatelessWidget {
  final Future<bool> Function() onExitConfirmed;

  const ExitConfirmationScreen({super.key, required this.onExitConfirmed});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.confirmExitTitle),
      content: Text(AppLocalizations.of(context)!.confirmExitMessage),
      actions: [
        TextButton(
          onPressed: () {
            context.pop(false);
          },
          child: Text(AppLocalizations.of(context)!.cancelButton),
        ),
        ElevatedButton(
          onPressed: () async {
            bool shouldExit = await onExitConfirmed();
            if (context.mounted) {
              context.pop(shouldExit);
            }
          },
          child: Text(AppLocalizations.of(context)!.exitButton),
        ),
      ],
    );
  }
}
