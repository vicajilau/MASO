import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';

/// Exception class for errors related to MASO file processing.
class BadMasoFileException implements Exception {
  /// The specific type of error that occurred.
  final BadMasoFileErrorType type;

  /// Creates a new `BadMasoFileException` with the given error type.
  BadMasoFileException(this.type);

  /// Returns a localized description of the error based on the current app language.
  ///
  /// Uses `AppLocalizations` to provide error messages in the appropriate language.
  ///
  /// Example usage:
  /// ```dart
  /// try {
  ///   throw BadMasoFileException(BadMasoFileErrorType.unsupportedVersion);
  /// } catch (e) {
  ///   if (e is BadMasoFileException) {
  ///     print(e.description(context)); // Localized error message
  ///   }
  /// }
  /// ```
  ///
  /// - `metadataBadContent`: The file metadata is invalid or corrupted.
  /// - `processesBadContent`: The process list contains invalid data.
  /// - `unsupportedVersion`: The file version is not supported by the current app.
  /// - `invalidExtension`: The file does not have a valid `.maso` extension.
  String description(BuildContext context) {
    print("object");
    switch (type) {
      case BadMasoFileErrorType.metadataBadContent:
        return AppLocalizations.of(context)!.metadataBadContent;
      case BadMasoFileErrorType.processesBadContent:
        return AppLocalizations.of(context)!.processesBadContent;
      case BadMasoFileErrorType.unsupportedVersion:
        return AppLocalizations.of(context)!.unsupportedVersion;
      case BadMasoFileErrorType.invalidExtension:
        return AppLocalizations.of(context)!.invalidExtension;
    }
  }

  @override
  String toString() => "BadMasoFileException: $type";
}

/// Enum representing different types of errors that can occur in a MASO file.
enum BadMasoFileErrorType {
  /// Indicates that the metadata content is invalid.
  metadataBadContent,

  /// Indicates that the process list has invalid content.
  processesBadContent,

  /// Indicates that the MASO file version is not supported.
  unsupportedVersion,

  /// Indicates that the extension file is not .maso.
  invalidExtension
}
