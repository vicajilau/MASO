import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../domain/models/maso/process_mode.dart';
import '../../../domain/models/settings_maso.dart';

class SettingsDialog extends StatefulWidget {
  final SettingsMaso settings;
  final ValueChanged<SettingsMaso> onSettingsChanged;

  const SettingsDialog({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late SettingsMaso currentSettings;

  @override
  void initState() {
    super.initState();
    currentSettings = SettingsMaso(
      processesMode: widget.settings.processesMode,
      contextSwitchTime: widget.settings.contextSwitchTime,
      ioChannels: widget.settings.ioChannels,
      cpuCount: widget.settings.cpuCount,
    );
  }

  void _updateProcessesMode(ProcessesMode newMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.settingsDialogWarningTitle),
        content: Text(AppLocalizations.of(context)!.settingsDialogWarningContent),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              setState(() {
                currentSettings.processesMode = newMode;
              });
              widget.onSettingsChanged(currentSettings);
            },
            child: Text(AppLocalizations.of(context)!.confirm),
          ),
        ],
      ),
    );
  }

  void _updateSetting(String key, int value) {
    setState(() {
      switch (key) {
        case 'contextSwitchTime':
          currentSettings.contextSwitchTime = value;
          break;
        case 'ioChannels':
          currentSettings.ioChannels = value;
          break;
        case 'cpuCount':
          currentSettings.cpuCount = value;
          break;
      }
    });
    widget.onSettingsChanged(currentSettings);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.settingsDialogTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                groupValue: currentSettings.processesMode,
                onChanged: (newMode) {
                  if (newMode != null) {
                    _updateProcessesMode(newMode);
                  }
                },
              );
            }),
            const SizedBox(height: 16),
            _buildSliderSetting(
              context,
              label: AppLocalizations.of(context)!.contextSwitchTime,
              value: currentSettings.contextSwitchTime,
              onChanged: (value) => _updateSetting('contextSwitchTime', value),
            ),
            _buildSliderSetting(
              context,
              label: AppLocalizations.of(context)!.ioChannels,
              value: currentSettings.ioChannels,
              onChanged: (value) => _updateSetting('ioChannels', value),
            ),
            _buildSliderSetting(
              context,
              label: AppLocalizations.of(context)!.cpuCount,
              value: currentSettings.cpuCount,
              onChanged: (value) => _updateSetting('cpuCount', value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text(AppLocalizations.of(context)!.close),
        ),
      ],
    );
  }

  Widget _buildSliderSetting(
      BuildContext context, {
        required String label,
        required int value,
        double minValue = 0,
        required ValueChanged<int> onChanged,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        Slider(
          value: value.toDouble(),
          min: minValue,
          max: 5,
          divisions: 5,
          label: value.toString(),
          onChanged: (newValue) => onChanged(newValue.round()),
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