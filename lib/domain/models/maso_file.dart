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
    checkIfJsonIsCorrect(json);
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
}

enum MasoFileBadContent { metadataBadContent, processesBadContent }
