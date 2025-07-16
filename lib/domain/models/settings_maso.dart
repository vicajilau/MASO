import 'package:maso/core/constants/settings.dart';
import 'package:maso/core/deep_copy_mixin.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'maso/process_mode.dart';

/// Constants for SharedPreferences keys
class SettingsKeys {
  static const String contextSwitchTime = 'contextSwitchTime';
  static const String ioChannels = 'ioChannels';
  static const String cpuCount = 'cpuCount';
  static const String quantum = 'quantum';
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

  /// Quantum for Round Robin, persisted
  int quantum;

  /// Constructor with default values
  SettingsMaso({
    this.processesMode = ProcessesMode.regular,
    this.contextSwitchTime = Settings.defaultContextSwitchTime,
    this.ioChannels = Settings.defaultIoChannels,
    this.cpuCount = Settings.defaultCpuCount,
    this.quantum = Settings.defaultQuantum,
  });

  /// Loads settings from SharedPreferences, falling back to defaults
  static Future<SettingsMaso> loadFromPreferences(ProcessesMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsMaso(
      processesMode: mode,
      contextSwitchTime: prefs.getInt(SettingsKeys.contextSwitchTime) ??
          Settings.defaultContextSwitchTime,
      ioChannels:
          prefs.getInt(SettingsKeys.ioChannels) ?? Settings.defaultIoChannels,
      cpuCount: prefs.getInt(SettingsKeys.cpuCount) ?? Settings.defaultCpuCount,
      quantum: prefs.getInt(SettingsKeys.quantum) ?? Settings.defaultQuantum,
    );
  }

  /// Saves settings to SharedPreferences
  Future<void> saveToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(SettingsKeys.contextSwitchTime, contextSwitchTime);
    await prefs.setInt(SettingsKeys.ioChannels, ioChannels);
    await prefs.setInt(SettingsKeys.cpuCount, cpuCount);
    await prefs.setInt(SettingsKeys.quantum, quantum);
  }

  /// Creates a deep copy of the settings
  @override
  SettingsMaso copy() {
    return SettingsMaso(
      processesMode: processesMode,
      contextSwitchTime: contextSwitchTime,
      ioChannels: ioChannels,
      cpuCount: cpuCount,
      quantum: quantum,
    );
  }
}
