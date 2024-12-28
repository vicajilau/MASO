import '../../../domain/models/maso_file.dart';

/// Abstract class representing the base event for file operations.
abstract class FileEvent {}

/// Event triggered when a file is dropped into the application.
class FileDropped extends FileEvent {
  final String filePath; // Path of the dropped file
  FileDropped(this.filePath);
}

/// Event triggered when a file save is requested, with the file path and data.
class FileSaveRequested extends FileEvent {
  final String filePath; // Path where the file should be saved
  final MasoFile masoFile; // The MasoFile object to be saved
  FileSaveRequested(this.filePath, this.masoFile);
}

class FilePickRequested extends FileEvent {}