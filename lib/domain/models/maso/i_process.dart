/// The `IProcess` abstract class represents a generic process with common attributes.
/// It serves as the base class for different types of processes, such as `RegularProcess`
/// and `BurstProcess`.
abstract class IProcess {
  /// The name of the process.
  final String name;

  /// The arrival time of the process in seconds.
  final int arrivalTime;

  /// Whether the process is enabled or not.
  bool enabled;

  /// The I/O device associated with the process.
  final String ioDevice;

  /// The total execution time of the process.
  int executionTime;

  /// Constructor for initializing an `IProcess` instance with required attributes.
  IProcess({
    required this.name,
    required this.arrivalTime,
    required this.enabled,
    required this.ioDevice,
    this.executionTime = 0,
  });

  /// Converts the `IProcess` instance to a JSON map.
  Map<String, dynamic> toJson();
}
