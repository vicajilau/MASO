/// The IoDevice class represents an I/O Device with a name and status.
class IoDevice {
  /// The name of the IoDevice
  final String name;

  /// If the IoDevice is enabled
  bool enabled;

  /// Constructor for creating a IoDevice instance with name and status.
  IoDevice({
    required this.name,
    required this.enabled,
  });

  /// Factory constructor to create a IoDevice instance from a JSON map.
  factory IoDevice.fromJson(Map<String, dynamic> json) => IoDevice(
        name: json['name'] as String,
        enabled: json['enabled'] as bool,
      );

  /// Factory constructor to create a none IoDevice.
  factory IoDevice.none() => IoDevice(
        name: 'none',
        enabled: false,
      );

  /// Converts the IoDevice instance to a JSON map.
  Map<String, dynamic> toJson() => {
        'name': name,
        'enabled': enabled,
      };

  /// Override the equality operator to compare IoDevice instances based on their values.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IoDevice && other.name == name && other.enabled == enabled;
  }

  /// Override the hashCode to be consistent with the equality operator.
  @override
  int get hashCode => name.hashCode ^ enabled.hashCode;

  @override
  String toString() => "I/O Device: {name: $name, enabled: $enabled}";
}
