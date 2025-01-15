import '../../../core/deep_copy_mixin.dart';

/// The `IProcess` abstract class represents a generic process with common attributes.
/// It serves as the base class for different types of processes, such as `RegularProcess`
/// and `BurstProcess`.
abstract class IProcess with DeepCopy<IProcess> {
  /// The name of the process.
  final String name;

  /// The arrival time of the process in seconds.
  final int arrivalTime;

  /// Whether the process is enabled or not.
  bool enabled;


  /// The total execution time of the process.
  int executionTime;

  /// Constructor for initializing an `IProcess` instance with required attributes.
  IProcess({
    required this.name,
    required this.arrivalTime,
    required this.enabled,
    this.executionTime = 0,
  });

  /// Converts the `IProcess` instance to a JSON map.
  Map<String, dynamic> toJson();

  /// Overrides the equality operator to compare `IProcess` instances based on their values.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IProcess &&
        other.name == name &&
        other.arrivalTime == arrivalTime &&
        other.enabled == other.enabled;
  }

  /// Overrides the `hashCode` to be consistent with the equality operator.
  @override
  int get hashCode =>
      name.hashCode ^ arrivalTime.hashCode ^ enabled.hashCode;

  /// Creates a deep copy of the object.
  @override
  IProcess copy();
}
