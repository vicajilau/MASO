import 'package:maso/core/deep_copy_mixin.dart';
import 'package:maso/domain/models/maso/burst_type.dart';

class Burst with DeepCopy<Burst> {
  final BurstType type;
  final int duration;
  String device;

  Burst({
    required this.type,
    required this.duration,
    this.device = 'none',
  });

  factory Burst.fromJson(Map<String, dynamic> json) {
    return Burst(
      type: BurstType.values.firstWhere((e) => e.name == json['type']),
      duration: json['duration'],
      device: json['device'] ?? 'none',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'duration': duration,
      'device': device,
    };
  }

  @override
  Burst copy() {
    return Burst(
      type: type,
      duration: duration,
      device: device,
    );
  }

  @override
  String toString() =>
      "Burst: {type: $type, duration: $duration, device: $device}";

  /// Overrides the equality operator to compare `Burst` instances based on their values.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Burst &&
        other.type == type &&
        other.duration == duration &&
        other.device == device;
  }

  /// Overrides the `hashCode` to be consistent with the equality operator.
  @override
  int get hashCode => type.hashCode ^ duration.hashCode ^ device.hashCode;
}
