import 'i_process.dart';

/// The `RegularProcess` class implements the `IProcess` interface,
/// representing a regular process in a scheduling system.
/// This class includes several attributes such as `name`,
/// `arrivalTime`, `serviceTime`, `enabled`, and `ioDevice` to
/// describe the process and its characteristics.
class RegularProcess extends IProcess {
  final int serviceTime;

  /// Constructor to initialize the attributes of the RegularProcess.
  RegularProcess({
    required super.name,
    required super.arrivalTime,
    required this.serviceTime,
    required super.enabled,
    required super.ioDevice,
  });

  /// Factory method that creates a RegularProcess instance from a JSON map.
  /// This is useful for deserialization when data is read from JSON format.
  factory RegularProcess.fromJson(Map<String, dynamic> json) {
    return RegularProcess(
      name: json['name'],
      arrivalTime: json['arrival_time'],
      serviceTime: json['service_time'],
      enabled: json['enabled'],
      ioDevice: json['io_device'],
    );
  }

  /// Overrides the toJson method to return a map representation of the
  /// RegularProcess object. This allows serialization of the object.
  @override
  Map<String, dynamic> toJson() => {
        'name': name,
        'arrival_time': arrivalTime,
        'service_time': serviceTime,
        'enabled': enabled,
        'io_device': ioDevice,
      };

  @override
  String toString() =>
      "Regular Process: {name: $name, arrivalTime: $arrivalTime, serviceTime: $serviceTime, enabled: $enabled, ioDevice: $ioDevice}";

  /// Overrides the equality operator to compare `RegularProcess` instances based on their values.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RegularProcess &&
        other.name == name &&
        other.arrivalTime == arrivalTime &&
        other.serviceTime == serviceTime &&
        other.enabled == other.enabled &&
        other.ioDevice == other.ioDevice;
  }

  /// Overrides the `hashCode` to be consistent with the equality operator.
  @override
  int get hashCode =>
      name.hashCode ^
      arrivalTime.hashCode ^
      serviceTime.hashCode ^
      enabled.hashCode ^
      ioDevice.hashCode;

  @override
  IProcess copy() {
    return RegularProcess(
        name: name,
        arrivalTime: arrivalTime,
        serviceTime: serviceTime,
        enabled: enabled,
        ioDevice: ioDevice);
  }
}