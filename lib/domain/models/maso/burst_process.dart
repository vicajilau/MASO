import 'i_process.dart';

/// The `BurstProcess` class extends the `IProcess` interface,
/// representing a process with a list of CPU burst durations.
/// This class includes several attributes such as `name`,
/// `arrivalTime`, `cpuBurstDuration`, `enabled`, and `ioDevice`
/// to describe the process and its behavior during execution.
class BurstProcess extends IProcess {
  final List<int> cpuBurstDuration;

  /// Constructor to initialize the attributes of the BurstProcess.
  BurstProcess({
    required super.name,
    required super.arrivalTime,
    required this.cpuBurstDuration,
    required super.enabled,
    required super.ioDevice,
  });

  /// Factory method that creates a BurstProcess instance from a JSON map.
  /// This is useful for deserialization when data is read from JSON format.
  factory BurstProcess.fromJson(Map<String, dynamic> json) {
    return BurstProcess(
      name: json['name'],
      arrivalTime: json['arrival_time'],
      cpuBurstDuration: List<int>.from(json['cpu_burst_duration']),
      enabled: json['enabled'],
      ioDevice: json['io_device'],
    );
  }

  /// Overrides the toJson method to return a map representation of the
  /// BurstProcess object. This allows serialization of the object.
  @override
  Map<String, dynamic> toJson() => {
        'name': name,
        'arrival_time': arrivalTime,
        'cpu_burst_duration': cpuBurstDuration,
        'enabled': enabled,
        'io_device': ioDevice,
      };

  @override
  String toString() =>
      "Burst Process: {name: $name, arrivalTime: $arrivalTime, cpuBurstDuration: $cpuBurstDuration, enabled: $enabled, ioDevice: $ioDevice}";

  /// Overrides the equality operator to compare `Process` instances based on their values.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BurstProcess &&
        other.name == name &&
        other.arrivalTime == arrivalTime &&
        other.cpuBurstDuration == cpuBurstDuration &&
        other.enabled == other.enabled &&
        other.ioDevice == other.ioDevice;
  }

  /// Overrides the `hashCode` to be consistent with the equality operator.
  @override
  int get hashCode =>
      name.hashCode ^
      arrivalTime.hashCode ^
      cpuBurstDuration.hashCode ^
      enabled.hashCode ^
      ioDevice.hashCode;

  @override
  IProcess copy() {
    return BurstProcess(
        name: name,
        arrivalTime: arrivalTime,
        cpuBurstDuration: List<int>.from(cpuBurstDuration),
        enabled: enabled,
        ioDevice: ioDevice);
  }
}
