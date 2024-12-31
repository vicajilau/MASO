import 'package:maso/domain/models/process.dart';

import 'metadata.dart';

/// The MasoFile class represents a MASO file, which consists of metadata and a list of processes.
class MasoFile {
  String? filePath;

  /// Metadata of the MASO file
  final Metadata metadata;

  /// List of processes described in the MASO file
  final List<Process> processes;

  /// Constructor for creating a MasoFile instance with metadata and processes.
  MasoFile({required this.metadata, required this.processes, this.filePath});

  /// Factory constructor to create a MasoFile instance from a JSON map.
  factory MasoFile.fromJson(Map<String, dynamic> json, String? filePath) {
    checkIfJsonIsCorrect(json);
    return MasoFile(
        // Parse the 'metadata' field and create a Metadata instance
        metadata: Metadata.fromJson(json['metadata'] as Map<String, dynamic>),
        // Parse the 'processes' field and create a list of Process instances
        processes: (json['processes'] as List<dynamic>)
            .map((e) => Process.fromJson(e as Map<String, dynamic>))
            .toList(),
        filePath: filePath);
  }

  /// Converts the MasoFile instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      /// Convert the metadata instance to JSON
      'metadata': metadata.toJson(),

      /// Convert each process instance to JSON
      'processes': processes.map((e) => e.toJson()).toList(),
    };
  }

  /// Static method to check if the provided JSON is valid and has the correct structure.
  static void checkIfJsonIsCorrect(Map<String, dynamic> json) {
    try {
      /// Attempt to deserialize the 'metadata' object from the JSON into a 'Metadata' instance.
      /// It is expected that 'json['metadata']' is a Map<String, dynamic>.
      Metadata.fromJson(json['metadata'] as Map<String, dynamic>);
    } catch (e) {
      /// If an error occurs (e.g., if 'metadata' is not in the correct format),
      /// throw an exception with a specific message regarding the incorrect 'metadata' content.
      throw Exception(MasoFileBadContent.metadataBadContent);
    }

    try {
      /// Attempt to convert the 'processes' content into a list of 'Process' objects.
      /// First, get 'json['processes']' and treat it as a List<dynamic>.
      /// Then, use the 'map' function to convert each item into a 'Process' object using 'Process.fromJson'.
      /// Finally, convert the result of 'map' to a list using 'toList()'.
      (json['processes'] as List<dynamic>)
          .map((e) => Process.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      /// If an error occurs (e.g., if 'processes' does not have the expected structure),
      /// throw an exception with a specific message regarding the incorrect 'processes' content.
      throw Exception(MasoFileBadContent.processesBadContent);
    }
  }

  /// Override the equality operator to compare MasoFile instances based on their values.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MasoFile &&
        other.metadata == metadata &&
        _processesEqual(other.processes);
  }

  /// Override the hashCode to be consistent with the equality operator.
  @override
  int get hashCode =>
      filePath.hashCode ^ metadata.hashCode ^ _processesHashCode(processes);

  /// Compares the 'processes' list deeply by checking each process object.
  bool _processesEqual(List<Process> otherProcesses) {
    if (processes.length != otherProcesses.length) return false;
    for (int i = 0; i < processes.length; i++) {
      if (processes[i] != otherProcesses[i]) return false;
    }
    return true;
  }

  /// Generates a hash code for the 'processes' list based on each process object.
  int _processesHashCode(List<Process> processes) {
    int result = 0;
    for (var process in processes) {
      result ^= process.hashCode;
    }
    return result;
  }
}

enum MasoFileBadContent { metadataBadContent, processesBadContent }
