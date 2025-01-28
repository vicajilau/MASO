import 'package:maso/core/constants/settings.dart';
import 'package:maso/core/deep_copy_mixin.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'maso/process_mode.dart';

/// Constants for SharedPreferences keys
class SettingsKeys {
  static const String contextSwitchTime = 'contextSwitchTime';
  static const String ioChannels = 'ioChannels';
  static const String cpuCount = 'cpuCount';
}

/// Class to manage MASO settings, including persistence and default values
class SettingsMaso with DeepCopy<SettingsMaso> {
  /// The mode of processes, not persisted
  ProcessesMode processesMode;

  /// Time for context switching, persisted
  int contextSwitchTime;

  /// Number of IO channels, persisted
  int ioChannels;

  /// Number of CPUs, persisted
  int cpuCount;

  /// Constructor with default values
  SettingsMaso({
    this.processesMode = ProcessesMode.regular,
    this.contextSwitchTime = Settings.defaultContextSwitchTime,
    this.ioChannels = Settings.defaultIoChannels,
    this.cpuCount = Settings.defaultCpuCount,
  });

  /// Loads settings from SharedPreferences, falling back to defaults
  static Future<SettingsMaso> loadFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsMaso(
      processesMode: ProcessesMode.regular, // Not persisted, uses default value
      contextSwitchTime: prefs.getInt(SettingsKeys.contextSwitchTime) ??
          Settings.defaultContextSwitchTime,
      ioChannels:
          prefs.getInt(SettingsKeys.ioChannels) ?? Settings.defaultIoChannels,
      cpuCount: prefs.getInt(SettingsKeys.cpuCount) ?? Settings.defaultCpuCount,
    );
  }

  /// Saves settings to SharedPreferences
  Future<void> saveToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(SettingsKeys.contextSwitchTime, contextSwitchTime);
    await prefs.setInt(SettingsKeys.ioChannels, ioChannels);
    await prefs.setInt(SettingsKeys.cpuCount, cpuCount);
  }

  /// Creates a deep copy of the settings
  @override
  SettingsMaso copy() {
    return SettingsMaso(
      processesMode: processesMode,
      contextSwitchTime: contextSwitchTime,
      ioChannels: ioChannels,
      cpuCount: cpuCount,
    );
  }
}
