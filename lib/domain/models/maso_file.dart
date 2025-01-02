import 'package:maso/domain/models/process.dart';

import 'metadata.dart';

/// The `MasoFile` class represents a MASO file, which consists of metadata and a list of processes.
class MasoFile {
  String? filePath;

  /// The metadata of the MASO file.
  final Metadata metadata;

  /// The list of processes described in the MASO file.
  final List<Process> processes;

  /// Constructor for creating a `MasoFile` instance with metadata and processes.
  MasoFile({required this.metadata, required this.processes, this.filePath});

  /// Factory constructor to create a `MasoFile` instance from a JSON map.
  factory MasoFile.fromJson(Map<String, dynamic> json, String? filePath) {
    checkIfJsonIsCorrect(
        json); // Verifies if the JSON is correct before creating the object.
    return MasoFile(
        metadata: Metadata.fromJson(
            json['metadata'] as Map<String, dynamic>), // Parsing the metadata.
        processes: (json['processes']
                as List<dynamic>) // Parsing the list of processes.
            .map((e) => Process.fromJson(e as Map<String, dynamic>))
            .toList(),
        filePath: filePath);
  }

  /// Converts the `MasoFile` instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'metadata': metadata.toJson(), // Converts the metadata to JSON.
      'processes': processes
          .map((e) => e.toJson())
          .toList(), // Converts each process to JSON.
    };
  }

  /// Static method to verify if the provided JSON is valid and has the correct structure.
  static void checkIfJsonIsCorrect(Map<String, dynamic> json) {
    try {
      // Attempts to deserialize the 'metadata' object from the JSON into a 'Metadata' instance.
      Metadata.fromJson(json['metadata'] as Map<String, dynamic>);
    } catch (e) {
      // If an error occurs (e.g., if 'metadata' is not in the correct format),
      // throws an exception with a specific message about the incorrect 'metadata' content.
      throw Exception(MasoFileBadContent.metadataBadContent);
    }

    try {
      // Attempts to convert the 'processes' content into a list of 'Process' objects.
      (json['processes'] as List<dynamic>)
          .map((e) => Process.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If an error occurs (e.g., if 'processes' does not have the expected structure),
      // throws an exception with a specific message about the incorrect 'processes' content.
      throw Exception(MasoFileBadContent.processesBadContent);
    }
  }

  /// Overrides the equality operator to compare `MasoFile` instances based on their values.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MasoFile &&
        other.metadata == metadata && // Compares the metadata.
        _processesEqual(other.processes); // Compares the list of processes.
  }

  /// Overrides the `hashCode` to be consistent with the equality operator.
  @override
  int get hashCode => metadata.hashCode ^ _processesHashCode(processes);

  /// Compares the 'processes' list deeply by checking each 'process' object.
  bool _processesEqual(List<Process> otherProcesses) {
    if (processes.length != otherProcesses.length) {
      return false; // If the lengths are not equal, they are not equal.
    }
    for (int i = 0; i < processes.length; i++) {
      if (processes[i] != otherProcesses[i]) {
        return false; // Compares each process in the list.
      }
    }
    return true;
  }

  /// Generates a `hashCode` for the 'processes' list based on each 'process' object.
  int _processesHashCode(List<Process> processes) {
    int result = 0;
    for (var process in processes) {
      result ^= process
          .hashCode; // Applies XOR to generate a unique hash for the processes.
    }
    return result;
  }

  /// Creates a new `MasoFile` instance with modified values from the current instance.
  MasoFile copyWith(
      {String? filePath, Metadata? metadata, List<Process>? processes}) {
    return MasoFile(
        metadata: metadata ??
            this
                .metadata, // If no 'metadata' is provided, uses the current value.
        processes: processes ??
            this
                .processes, // If no 'processes' are provided, uses the current value.
        filePath: filePath ??
            this.filePath); // If no 'filePath' is provided, uses the current value.
  }
}

enum MasoFileBadContent { metadataBadContent, processesBadContent }
