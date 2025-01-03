/// The Process class represents a process with a name, arrival time, and service time.
class Process {
  /// The name of the process
  final String name;

  /// The arrival time of the process
  final int arrivalTime;

  /// The service time of the process
  final int serviceTime;

  /// The execution time of the process
  int? executionTime;

  /// If the process is enabled
  bool enabled;

  /// Constructor for creating a Process instance with name, arrival time, and service time.
  Process({
    required this.name,
    required this.arrivalTime,
    required this.serviceTime,
    this.executionTime,
    required this.enabled,
  });

  /// Factory constructor to create a Process instance from a JSON map.
  factory Process.fromJson(Map<String, dynamic> json) => Process(
        name: json['name'] as String,
        arrivalTime: json['arrival_time'] as int,
        serviceTime: json['service_time'] as int,
        enabled: json['enabled'] as bool,
      );

  /// Converts the Process instance to a JSON map.
  Map<String, dynamic> toJson() => {
        'name': name,
        'arrival_time': arrivalTime,
        'service_time': serviceTime,
        'enabled': enabled,
      };

  /// Override the equality operator to compare Process instances based on their values.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Process &&
        other.name == name &&
        other.arrivalTime == arrivalTime &&
        other.serviceTime == serviceTime &&
        other.enabled == enabled;
  }

  /// Override the hashCode to be consistent with the equality operator.
  @override
  int get hashCode =>
      name.hashCode ^
      arrivalTime.hashCode ^
      serviceTime.hashCode ^
      enabled.hashCode;

  @override
  String toString() =>
      "Process: {name: $name, arrivalTime: $arrivalTime, service: $serviceTime, enabled: $enabled}";
}
