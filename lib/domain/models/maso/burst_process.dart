import 'package:maso/core/deep_collection_equality.dart';
import 'package:maso/domain/models/maso/burst.dart';

import 'i_process.dart';

/// The `BurstProcess` class extends the `IProcess` interface,
/// representing a process with a list of CPU burst durations.
/// This class includes several attributes such as `name`,
/// `arrivalTime`, `cpuBurstDuration`, `enabled`, and `ioDevice`
/// to describe the process and its behavior during execution.
class BurstProcess extends IProcess {
  final List<Burst> bursts;

  /// Constructor to initialize the attributes of the BurstProcess.
  BurstProcess({
    required super.name,
    required super.arrivalTime,
    required this.bursts,
    required super.enabled,
  });

  /// Factory method that creates a BurstProcess instance from a JSON map.
  /// This is useful for deserialization when data is read from JSON format.
  factory BurstProcess.fromJson(Map<String, dynamic> json) {
    return BurstProcess(
      name: json['name'],
      arrivalTime: json['arrival_time'],
      bursts: (json['bursts'] as List)
          .map((burst) => Burst.fromJson(burst))
          .toList(),
      enabled: json['enabled'],
    );
  }

  /// Overrides the toJson method to return a map representation of the
  /// BurstProcess object. This allows serialization of the object.
  @override
  Map<String, dynamic> toJson() => {
        'name': name,
        'arrival_time': arrivalTime,
        'bursts': bursts,
        'enabled': enabled,
      };

  @override
  String toString() =>
      "Burst Process: {name: $name, arrivalTime: $arrivalTime, cpuBurstDuration: $bursts, enabled: $enabled}";

  /// Overrides the equality operator to compare `Process` instances based on their values.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BurstProcess &&
        other.name == name &&
        other.arrivalTime == arrivalTime &&
        DeepCollectionEquality.listEquals(other.bursts, bursts) &&
        other.enabled == other.enabled;
  }

  /// Overrides the `hashCode` to be consistent with the equality operator.
  @override
  int get hashCode =>
      name.hashCode ^
      arrivalTime.hashCode ^
      bursts.hashCode ^
      enabled.hashCode;

  @override
  IProcess copy() {
    return BurstProcess(
        name: name,
        arrivalTime: arrivalTime,
        bursts: bursts.map((burst) => burst.copy()).toList(),
        enabled: enabled);
  }
}
