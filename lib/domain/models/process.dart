/// The Process class represents a process with a name, arrival time, and service time.
class Process {
  /// The name of the process
  final String name;

  /// The arrival time of the process
  final int arrivalTime;

  /// The service time of the process
  final int serviceTime;

  /// If the process is enabled
  bool enabled;

  /// Constructor for creating a Process instance with name, arrival time, and service time.
  Process({
    required this.name,
    required this.arrivalTime,
    required this.serviceTime,
    required this.enabled
  });

  /// Factory constructor to create a Process instance from a JSON map.
  factory Process.fromJson(Map<String, dynamic> json) {
    return Process(
      name: json['name'] as String, // Parse the 'name' field
      arrivalTime:
          json['arrival_time'] as int, // Parse the 'arrival_time' field
      serviceTime:
          json['service_time'] as int, // Parse the 'service_time' field
      enabled:
      json['enabled'] as bool, // Parse the 'enabled' field
    );
  }

  /// Converts the Process instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'name': name, // Convert the 'name' field to JSON
      'arrival_time': arrivalTime, // Convert the 'arrival_time' field to JSON
      'service_time': serviceTime, // Convert the 'service_time' field to JSON
      'enabled': enabled, // Convert the 'service_time' field to JSON
    };
  }
}
