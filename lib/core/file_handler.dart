import 'package:flutter/services.dart';

/// Handles file interactions through platform channels.
class FileHandler {
  /// The platform method channel for handling file operations.
  static const _channel = MethodChannel('maso.file');

  /// Stores the path of a pending file to be processed.
  static String? _pendingFilePath;

  /// Initializes the file handler by setting up a method call listener.
  ///
  /// - [onFileOpened]: Callback function triggered when a file is opened.
  static void initialize(Function(String filePath) onFileOpened) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'openFile') {
        final filePath = call.arguments as String;
        _pendingFilePath = filePath;
        onFileOpened(filePath);
      }
    });
  }

  /// Retrieves the pending file path and clears it after reading.
  ///
  /// Returns the file path if available, otherwise `null`.
  static String? getPendingFile() {
    final file = _pendingFilePath;
    _pendingFilePath = null; // Clean up after reading
    return file;
  }
}
