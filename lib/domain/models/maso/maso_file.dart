import 'package:maso/core/constants/maso_metadata.dart';
import 'package:maso/domain/models/maso/processes.dart';

import '../../../core/deep_collection_equality.dart';
import '../custom_exceptions/bad_maso_file_exception.dart';
import 'io_device.dart';
import 'metadata.dart';

/// The `MasoFile` class represents a MASO file, which consists of metadata, I/O devices,
/// and a list of processes. This class provides methods for deserialization, validation,
/// and modification of the MASO file's contents.
class MasoFile {
  String? filePath;

  /// The metadata of the MASO file.
  final Metadata metadata;

  /// The list of I/O devices described in the MASO file.
  final List<IoDevice> ioDevices;

  /// The processes described in the MASO file.
  final Processes processes;

  /// Constructor for creating a `MasoFile` instance with metadata, I/O devices, and processes.
  MasoFile({
    required this.metadata,
    required this.ioDevices,
    required this.processes,
    this.filePath,
  });

  /// Factory constructor to create a `MasoFile` instance from a JSON map.
  factory MasoFile.fromJson(Map<String, dynamic> json, String? filePath) {
    // Verifies if the JSON is correct before creating the object.
    checkIfJsonIsCorrect(json);
    return MasoFile(
      metadata: Metadata.fromJson(json['metadata'] as Map<String, dynamic>),
      ioDevices: (json['io_devices'] as List<dynamic>)
          .map((device) => IoDevice.fromJson(device as Map<String, dynamic>))
          .toList(),
      processes: Processes.fromJson(json['processes'] as Map<String, dynamic>),
      filePath: filePath,
    );
  }

  /// Converts the `MasoFile` instance to a JSON map.
  Map<String, dynamic> toJson() => {
        'metadata': metadata.toJson(),
        'io_devices': ioDevices.map((device) => device.toJson()).toList(),
        'processes': processes.toJson(),
      };

  /// Static method to verify if the provided JSON is valid and has the correct structure.
  static void checkIfJsonIsCorrect(Map<String, dynamic> json) {
    try {
      // Validate metadata
      final metadata =
          Metadata.fromJson(json['metadata'] as Map<String, dynamic>);
      if (!MasoMetadata.isSupportedVersion(metadata.version)) {
        throw BadMasoFileException(BadMasoFileErrorType.unsupportedVersion);
      }
    } catch (e) {
      if (e is BadMasoFileException) {
        rethrow;
      }
      throw BadMasoFileException(BadMasoFileErrorType.metadataBadContent);
    }

    try {
      // Validate I/O devices
      final devices = json['io_devices'] as List<dynamic>;
      for (var device in devices) {
        IoDevice.fromJson(device as Map<String, dynamic>);
      }
    } catch (e) {
      throw BadMasoFileException(BadMasoFileErrorType.ioDevicesBadContent);
    }

    try {
      // Validate processes
      Processes.fromJson(json['processes'] as Map<String, dynamic>);
    } catch (e) {
      throw BadMasoFileException(BadMasoFileErrorType.processesBadContent);
    }
  }

  /// Overrides the equality operator to compare `MasoFile` instances based on their values.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MasoFile &&
        other.metadata == metadata &&
        DeepCollectionEquality.listEquals(other.ioDevices, ioDevices) &&
        other.processes == processes;
  }

  /// Overrides the `hashCode` to be consistent with the equality operator.
  @override
  int get hashCode =>
      metadata.hashCode ^ ioDevices.hashCode ^ processes.hashCode;

  /// Creates a new `MasoFile` instance with modified values from the current instance.
  MasoFile copyWith({
    String? filePath,
    Metadata? metadata,
    List<IoDevice>? ioDevices,
    Processes? processes,
  }) {
    return MasoFile(
      filePath: filePath ?? this.filePath,
      metadata: metadata ?? this.metadata,
      ioDevices: ioDevices ??
          this
              .ioDevices
              .map((ioDevice) =>
                  IoDevice(name: ioDevice.name, enabled: ioDevice.enabled))
              .toList(),
      processes: processes ?? this.processes.copyWith(),
    );
  }

  @override
  String toString() =>
      "Maso File {metadata: $metadata, ioDevices: $ioDevices, processes: $processes} with Hash($hashCode).";
}
