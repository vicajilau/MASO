import '../../domain/models/maso_file.dart';
import '../services/file_service.dart';

// FileRepository class manages file-related operations by delegating tasks to FileService
class FileRepository {
  // Instance of FileService to handle file operations
  final FileService _fileService;

  // Constructor to initialize FileRepository with a FileService instance
  FileRepository(this._fileService);

  /// Loads a `MasoFile` from a file.
  /// This method calls the `readMasoFile` function from FileService to read the file.
  Future<MasoFile> loadMasoFile(String filePath) async {
    try {
      // Attempt to load the file using FileService
      return await _fileService.readMasoFile(filePath);
    } catch (e) {
      // If an error occurs, throw an exception with a descriptive message
      throw Exception('Error loading the MASO file: $e');
    }
  }

  /// Saves a `MasoFile` to a file.
  /// This method calls the `writeMasoFile` function from FileService to write the file.
  Future<void> saveMasoFile(String filePath, MasoFile masoFile) async {
    try {
      // Attempt to save the file using FileService
      await _fileService.writeMasoFile(filePath, masoFile);
    } catch (e) {
      // If an error occurs, throw an exception with a descriptive message
      throw Exception('Error saving the MASO file: $e');
    }
  }
}
