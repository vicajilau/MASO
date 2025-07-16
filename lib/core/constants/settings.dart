/// A class containing default and boundary values for MASO application settings.
class Settings {
  /// Default context switch time (in milliseconds).
  static const int defaultContextSwitchTime = 0;

  /// Default number of IO channels.
  static const int defaultIoChannels = 1;

  /// Default number of CPUs.
  static const int defaultCpuCount = 1;

  /// Maximum allowable context switch time.
  static const int maxContextSwitchTime = 5;

  /// Maximum allowable number of IO channels.
  static const int maxIoChannels = 5;

  /// Maximum allowable number of CPUs.
  static const int maxCpuCount = 5;

  /// Minimum allowable context switch time.
  static const int minContextSwitchTime = 0;

  /// Minimum allowable number of IO channels.
  static const int minIoChannels = 1;

  /// Minimum allowable number of CPUs.
  static const int minCpuCount = 1;

  /// Minimum allowable quantum.
  static const int defaultQuantum = 1;

  /// Minimum allowable number of Quantum.
  static const int minQuantum = 1;

  /// Maximum allowable number of Quantum.
  static const int maxQuantum = 5;
}
