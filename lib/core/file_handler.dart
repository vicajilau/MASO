import 'package:flutter/services.dart';

class FileHandler {
  static const _channel = MethodChannel('maso.file');

  static void initialize(Function(String filePath) onFileOpened) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'openFile') {
        final filePath = call.arguments as String;
        onFileOpened(filePath);
      }
    });
  }
}
