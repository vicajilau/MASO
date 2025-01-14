

import 'package:maso/domain/models/maso/regular_process.dart';

import 'burst_process.dart';
import 'i_process.dart';

enum ProcessesMode {
  regular,
  burst;

  /// Converts a string to a `ProcessesMode` enum.
  static ProcessesMode fromJson(String value) {
    switch (value) {
      case 'regular':
        return ProcessesMode.regular;
      case 'burst':
        return ProcessesMode.burst;
    }
    throw ArgumentError("Invalid ProcessesMode value: $value");
  }
}

/// The Metadata class represents the metadata of a MASO file, including its name, version, and description.
class Processes {
  /// The name of the MASO file
  final ProcessesMode mode;

  /// The version of the MASO file
  final List<IProcess> elements;

  /// Constructor for creating a Metadata instance with name, version, and description.
  Processes({
    required this.mode,
    required this.elements,
  });

  /// Factory constructor to create a Metadata instance from a JSON map.
  factory Processes.fromJson(Map<String, dynamic> json) {
    final mode = ProcessesMode.fromJson(json['mode'] as String);

    final List<IProcess> elements =
        (json['elements'] as List<dynamic>).map<IProcess>((e) {
      final data = e as Map<String, dynamic>;
      switch (mode) {
        case ProcessesMode.regular:
          return RegularProcess.fromJson(data);
        case ProcessesMode.burst:
          return BurstProcess.fromJson(data);
      }
    }).toList();

    return Processes(mode: mode, elements: elements);
  }

  /// Converts the Metadata instance to a JSON map.
  Map<String, dynamic> toJson() => {
        'mode': mode, // Convert the 'mode' field to JSON
        'elements': elements, // Convert the 'elements' field to JSON
      };

  /// Override the equality operator to compare Metadata instances based on their values.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Processes &&
        other.mode == mode &&
        other.elements == elements;
  }

  /// Override the hashCode to be consistent with the equality operator.
  @override
  int get hashCode => mode.hashCode ^ elements.hashCode;

  @override
  String toString() => "Processes {mode: $mode, elements: $elements}";
}
