import '../../domain/models/maso_file.dart';
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
    return await _fileService.readMasoFile(filePath);
  }

  /// Saves a `MasoFile` to a file.
  /// This method calls the `writeMasoFile` function from FileService to write the file.
  Future<void> saveMasoFile(String filePath, MasoFile masoFile) async {
    await _fileService.writeMasoFile(filePath, masoFile);
  }
}
