import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:platform_detail/platform_detail.dart';

import '../../domain/models/maso_file.dart';

/// The FileService class is responsible for reading and writing MASO files.
class FileService {
  /// Reads a MASO file from the provided file path and returns a `MasoFile` object.
  Future<MasoFile> readMasoFile(String filePath) async {
    final response = await readBlobFile(filePath);
    final content = utf8.decode(response);

    // Decode the string content into a Map and convert it to a MasoFile object
    final json = jsonDecode(content) as Map<String, dynamic>;
    return MasoFile.fromJson(json, filePath);
  }

  /// Save a maso filex for a `MasoFile` in the file system.
  Future<MasoFile> saveMasoFile(MasoFile masoFile, String dialogTitle) async {
    String jsonString = jsonEncode(masoFile.toJson());
    final bytes = utf8.encode(jsonString);
    final path = await FilePicker.platform.saveFile(
        dialogTitle: dialogTitle,
        fileName: 'output-file.maso',
        initialDirectory: masoFile.filePath,
        bytes: bytes);

    if (path != null && !PlatformDetail.isMobile) {
      masoFile.filePath = path;
      await _writeMasoFile(masoFile);
    }
    return masoFile;
  }

  /// Writes a `MasoFile` object to a file at the specified path on Desktop.
  Future<void> _writeMasoFile(MasoFile masoFile) async {
    // Create a File object for the provided file path
    final file = File(masoFile.filePath!);

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

  Future<Uint8List> readBlobFile(String blobUrl) async {
    try {
      // Obtener el Blob desde el URL
      final response = await html.window.fetch(blobUrl);
      final blob = await response.blob();

      // Crear un FileReader para leer el contenido del Blob
      final reader = html.FileReader();
      final completer = Completer<Uint8List>();

      // Configurar un listener para cuando la lectura esté completa
      reader.onLoad.listen((event) {
        completer.complete(reader.result as Uint8List);
      });

      reader.onError.listen((event) {
        completer.completeError('Error al leer el blob');
      });

      // Leer el Blob como ArrayBuffer
      reader.readAsArrayBuffer(blob);

      // Retornar el resultado como Future<Uint8List>
      return await completer.future;
    } catch (e) {
      throw Exception('Error leyendo el archivo: $e');
    }
  }
}
