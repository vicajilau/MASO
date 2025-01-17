import 'package:maso/core/deep_copy_mixin.dart';

/// Represents a burst, which can either be a CPU task or an I/O operation.
/// Each burst has a type (e.g., 'cpu', 'io') and a duration in time units.
class Burst with DeepCopy<Burst> {
  /// The type of burst, either 'cpu' or 'io'.
  final String type;

  /// Duration of the burst in time units.
  final int duration;

  /// Constructor for the Burst class.
  ///
  /// [type] specifies the type of the burst ('cpu' or 'io').
  /// [duration] indicates the time duration of the burst.
  Burst({
    required this.type,
    required this.duration,
  });

  /// Converts the Burst object into a JSON-serializable map.
  ///
  /// Returns a `Map<String, dynamic>` representing the burst in JSON format.
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'duration': duration,
    };
  }

  /// Creates a Burst instance from a JSON map.
  ///
  /// [json] is the JSON map containing the burst data.
  /// Returns a `Burst` object.
  factory Burst.fromJson(Map<String, dynamic> json) {
    return Burst(
      type: json['type'],
      duration: json['duration'],
    );
  }

  @override
  Burst copy() {
    return Burst(type: type, duration: duration);
  }
}
