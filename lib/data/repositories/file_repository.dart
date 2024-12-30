import 'package:maso/core/service_locator.dart';

import '../../domain/models/maso_file.dart';
import '../../domain/models/metadata.dart';
import '../services/file_service.dart';

/// FileRepository class manages file-related operations by delegating tasks to FileService
class FileRepository {
  /// Instance of FileService to handle file operations
  final FileService _fileService;

  /// Constructor to initialize FileRepository with a FileService instance
  FileRepository(this._fileService);

  /// Loads a `MasoFile` from a file.
  /// This method calls the `readMasoFile` function from FileService to read the file.
  Future<MasoFile> loadMasoFile(String filePath) async {
    final masoFile = await _fileService.readMasoFile(filePath);
    ServiceLocator.instance.registerMasoFile(masoFile);
    return masoFile;
  }

  /// Loads a `MasoFile` from a file.
  /// This method calls the `readMasoFile` function from FileService to read the file.
  Future<MasoFile> createMasoFile(
      {required String name,
      required String version,
      required String description}) async {
    final masoFile = MasoFile(
        metadata:
            Metadata(name: name, version: version, description: description),
        processes: []);
    ServiceLocator.instance.registerMasoFile(masoFile);
    return masoFile;
  }

  /// Saves a `MasoFile` to a file.
  /// This method calls the `writeMasoFile` function from FileService to write the file.
  Future<MasoFile> saveMasoFile(MasoFile masoFile, String dialogTitle) async {
    return await _fileService.saveMasoFile(masoFile, dialogTitle);
  }

  /// Picks a file manually using the file service.
  ///
  /// This method delegates the task of file selection to the `_fileService`'s
  /// `pickFile` method. It returns a [String] representing the file path of
  /// the selected file, or [null] if no file is selected.
  ///
  /// Returns:
  ///   A [Future<String?>] containing the path of the selected file, or [null].
  Future<String?> pickFileManually() async {
    return _fileService.pickFile();
  }

  /// Checks if the file has changed by comparing the current file content
  /// with the cached version of the file.
  ///
  /// This method reads the original content of the file specified by the
  /// [filePath] and compares it with the [cachedMasoFile]. If the content
  /// is different, it returns [true]; otherwise, it returns [false].
  ///
  /// Parameters:
  ///   - [filePath]: The path to the file to be checked.
  ///   - [cachedMasoFile]: The cached version of the file content to compare.
  ///
  /// Returns:
  ///   A [Future<bool>] indicating whether the file content has changed.
  Future<bool> hasMasoFileChanged(
      String? filePath, MasoFile cachedMasoFile) async {
    if (filePath == null) return true;
    final originalMasoFile = await _fileService.readMasoFile(filePath);
    return originalMasoFile != cachedMasoFile;
  }
}
