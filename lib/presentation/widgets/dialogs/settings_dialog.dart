import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../domain/models/maso/process_mode.dart';

class SettingsDialog extends StatefulWidget {
  final ProcessesMode currentMode;
  final ValueChanged<ProcessesMode> onModeChanged;

  const SettingsDialog({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late ProcessesMode selectedMode;

  @override
  void initState() {
    super.initState();
    selectedMode = widget.currentMode;
  }

  void _updateMode(ProcessesMode newMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.settingsDialogWarningTitle),
        content:
            Text(AppLocalizations.of(context)!.settingsDialogWarningContent),
        actions: [
          TextButton(
            onPressed: () => context.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop(context);
              setState(() {
                selectedMode = newMode;
              });
              widget.onModeChanged(newMode);
              context.pop();
            },
            child: Text(AppLocalizations.of(context)!.confirm),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.settingsDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          Text(
            AppLocalizations.of(context)!.settingsDialogDescription,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          ...ProcessesMode.values.map((mode) {
            return RadioListTile<ProcessesMode>(
              title: Text(
                getProcessModeName(context, mode),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              value: mode,
              groupValue: selectedMode,
              onChanged: (newMode) {
                if (newMode != null) {
                  _updateMode(newMode);
                }
              },
            );
          }),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text(AppLocalizations.of(context)!.close),
        ),
      ],
    );
  }

  String getProcessModeName(BuildContext context, ProcessesMode mode) {
    switch (mode) {
      case ProcessesMode.regular:
        return AppLocalizations.of(context)!.processModeRegular;
      case ProcessesMode.burst:
        return AppLocalizations.of(context)!.processModeBurst;
    }
  }
}
