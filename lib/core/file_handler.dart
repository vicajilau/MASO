import 'package:flutter/services.dart';
import 'package:maso/core/debug_print.dart';

class FileHandler {
  static const _channel = MethodChannel('maso.file');

  static void initialize(Function(String filePath) onFileOpened) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'openFile') {
        final filePath = call.arguments as String;
        printInDebug("File imported: $filePath");
        onFileOpened(filePath);
      }
    });
  }
}
