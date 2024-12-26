import 'package:maso/domain/models/process.dart';

import 'metadata.dart';

/// The MasoFile class represents a MASO file, which consists of metadata and a list of processes.
class MasoFile {
  /// Metadata of the MASO file
  final Metadata metadata;

  /// List of processes described in the MASO file
  final List<Process> processes;

  /// Constructor for creating a MasoFile instance with metadata and processes.
  MasoFile({
    required this.metadata,
    required this.processes,
  });

  /// Factory constructor to create a MasoFile instance from a JSON map.
  factory MasoFile.fromJson(Map<String, dynamic> json) {
    return MasoFile(
      // Parse the 'metadata' field and create a Metadata instance
      metadata: Metadata.fromJson(json['metadata'] as Map<String, dynamic>),
      // Parse the 'processes' field and create a list of Process instances
      processes: (json['processes'] as List<dynamic>)
          .map((e) => Process.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Converts the MasoFile instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      // Convert the metadata instance to JSON
      'metadata': metadata.toJson(),
      // Convert each process instance to JSON
      'processes': processes.map((e) => e.toJson()).toList(),
    };
  }
}
