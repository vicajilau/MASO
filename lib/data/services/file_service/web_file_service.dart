import 'dart:async';
import 'dart:convert';
// ignore_for_file: deprecated_member_use
import 'dart:html';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import '../../../domain/models/maso/maso_file.dart';
import 'i_file_service.dart';

/// The `FileService` class provides functionalities for managing `.maso` files.
/// This includes reading, decoding, saving, and picking `.maso` files across platforms.
class FileService implements IFileService {
  /// Keep an original copy of the Maso document in order to detect changes in the Maso document.
  @override
  MasoFile? originalFile;

  /// Reads a `.maso` file from the specified [filePath], retrieves its binary data,
  /// and decodes it into a `MasoFile` object.
  ///
  /// - [filePath]: The path or URL of the `.maso` file.
  /// - Returns: A `MasoFile` object containing the parsed data from the file.
  /// - Throws: An exception if there is an error reading or decoding the file.
  @override
  Future<MasoFile> readMasoFile(String filePath) async {
    final codeUnits = await readBlobFile(filePath);
    final masoFile = decodeAndCreateMasoFile(filePath, codeUnits);
    originalFile = masoFile.copyWith();
    return masoFile;
  }

  /// Decodes binary data [codeUnits] into a `MasoFile` object using the provided [filePath].
  ///
  /// - [filePath]: The path of the file being decoded.
  /// - [codeUnits]: The binary content of the file as `Uint8List`.
  /// - Returns: A `MasoFile` object containing the parsed data.
  MasoFile decodeAndCreateMasoFile(String? filePath, Uint8List codeUnits) {
    // Decode the binary data to a UTF-8 string
    final content = utf8.decode(codeUnits);

    // Convert the string content to a JSON Map and create a MasoFile object
    final json = jsonDecode(content) as Map<String, dynamic>;
    return MasoFile.fromJson(json, filePath);
  }

  /// Saves a `MasoFile` object to the file system by opening a save dialog.
  ///
  /// - [masoFile]: The `MasoFile` object to save.
  /// - [dialogTitle]: The title of the save dialog window.
  /// - Returns: The `MasoFile` object with an updated file path if the user selects a path.
  /// - Throws: An exception if there is an error saving the file.
  @override
  Future<MasoFile?> saveMasoFile(
      MasoFile masoFile, String dialogTitle, String fileName) async {
    // Convert the MasoFile object to JSON string and encode it to bytes
    String jsonString = jsonEncode(masoFile.toJson());

    // Open a save dialog for the user to select a file path
    downloadMasoFile(dialogTitle, jsonString);
    originalFile = masoFile.copyWith();
    return masoFile;
  }

  /// Saves a `Exported` object to the file system.
  ///
  /// This method opens a save dialog for the user to choose the file path
  /// and writes the `MasoFile` data in JSON format to the selected file.
  ///
  /// - [masoFile]: The `MasoFile` object to save.
  /// - [dialogTitle]: The title for the save dialog window.
  /// - [fileName]: The name for the file.
  /// - Returns: The `MasoFile` object with an updated file path if the user selects a path.
  @override
  Future<void> saveExportedFile(
      Uint8List bytes, String dialogTitle, String fileName) async {
    // Open a save dialog for the user to select a file path
    // Create a new Blob containing the bytes
    final blob = Blob([bytes]);

    // Generate a URL for the Blob, allowing it to be downloaded
    final url = Url.createObjectUrlFromBlob(blob);

    // Create an anchor element for triggering the download
    AnchorElement(href: url)
      ..target = 'blank' // Open the file in a new tab (if supported)
      ..download = fileName // Set the file name for the download
      ..click(); // Simulate a click to start the download

    // Release the Blob URL to free up memory after the download
    Url.revokeObjectUrl(url); // Cleans up the URL to release memory.
  }

  /// Initiates the download of a `.maso` file by creating a blob from the provided content.
  ///
  /// - [filename]: The name of the file to be downloaded.
  /// - [content]: The content of the file as a string, which will be encoded to bytes.
  void downloadMasoFile(String filename, String content) {
    // Encode the string content to bytes for blob creation
    final bytes = utf8.encode(content);

    // Create a new Blob containing the bytes
    final blob = Blob([bytes]);

    // Generate a URL for the Blob, allowing it to be downloaded
    final url = Url.createObjectUrlFromBlob(blob);

    // Create an anchor element for triggering the download
    AnchorElement(href: url)
      ..target = 'blank' // Open the file in a new tab (if supported)
      ..download = filename // Set the file name for the download
      ..click(); // Simulate a click to start the download

    // Release the Blob URL to free up memory after the download
    Url.revokeObjectUrl(url); // Cleans up the URL to release memory.
  }

  /// Opens a file picker dialog for the user to select a `.maso` file.
  ///
  /// If a file is selected, it retrieves the file's binary data and decodes it into a `MasoFile` object.
  ///
  /// - Returns: A `MasoFile` object if a valid file is selected, or `null` if no file is selected.
  @override
  Future<MasoFile?> pickFile() async {
    // Open the file picker dialog
    final result = await FilePicker.platform.pickFiles();

    // If a file is selected, read and return the file as a MasoFile object
    if (result != null) {
      final bytes = result.files.single.bytes;
      if (bytes != null) {
        return decodeAndCreateMasoFile(result.files.single.path, bytes);
      }
    }
    return null; // Return null if no file is selected
  }

  /// Reads the binary data of a file from a Blob URL.
  ///
  /// This method fetches the file from the provided [blobUrl], processes it as a Blob,
  /// and reads its content as an `Uint8List`.
  ///
  /// - [blobUrl]: The URL of the file to read.
  /// - Returns: A `Uint8List` containing the binary content of the file.
  /// - Throws: An exception if there is an error fetching or reading the file.
  Future<Uint8List> readBlobFile(String blobUrl) async {
    try {
      // Fetch the Blob from the URL
      final response = await window.fetch(blobUrl);
      final blob = await response.blob();

      // Create a FileReader to read the Blob's content
      final reader = FileReader();
      final completer = Completer<Uint8List>();

      // Set up a listener for when the reading is complete
      reader.onLoad.listen((event) {
        completer.complete(reader.result as Uint8List);
      });

      reader.onError.listen((event) {
        completer.completeError('Error reading the blob');
      });

      // Read the Blob as an ArrayBuffer
      reader.readAsArrayBuffer(blob);

      // Return the result as a Future<Uint8List>
      return await completer.future;
    } catch (e) {
      throw Exception('Error reading the file: $e');
    }
  }
}
