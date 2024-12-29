import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';

import '../../domain/models/maso_file.dart';

/// The FileService class is responsible for reading and writing MASO files.
class FileService {
  /// Reads a MASO file from the provided file path and returns a `MasoFile` object.
  Future<MasoFile> readMasoFile(String filePath) async {
    // Create a File object for the provided file path
    final file = File(filePath);

    // Read the file content as a string
    final content = await file.readAsString();

    // Decode the string content into a Map and convert it to a MasoFile object
    final json = jsonDecode(content) as Map<String, dynamic>;
    return MasoFile.fromJson(json, filePath);
  }

  /// Writes a `MasoFile` object to a file at the specified path.
  Future<void> writeMasoFile(String filePath, MasoFile masoFile) async {
    // Create a File object for the provided file path
    final file = File(filePath);

    // Convert the MasoFile object to JSON string format
    final content = jsonEncode(masoFile.toJson());

    // Write the content to the file
    await file.writeAsString(content);
  }

  Future<String?> pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      return result.files.single.path;
    }
    return null;
  }
}
