import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/file_repository.dart';
import '../../domain/models/maso_file.dart';

// Events
/// Abstract class representing the base event for file operations.
abstract class FileEvent {}

/// Event triggered when a file is dropped into the application.
class FileDropped extends FileEvent {
  final String filePath;  // Path of the dropped file
  FileDropped(this.filePath);
}

/// Event triggered when a file save is requested, with the file path and data.
class FileSaveRequested extends FileEvent {
  final String filePath;  // Path where the file should be saved
  final MasoFile masoFile;  // The MasoFile object to be saved
  FileSaveRequested(this.filePath, this.masoFile);
}

// States
/// Abstract class representing the base state for file operations.
abstract class FileState {}

/// Initial state when no file operation is in progress.
class FileInitial extends FileState {}

/// State representing that a file operation is currently loading.
class FileLoading extends FileState {}

/// State representing a successfully loaded file, containing the file data and path.
class FileLoaded extends FileState {
  final MasoFile masoFile;  // The loaded MasoFile object
  final String filePath;  // Path of the loaded file

  FileLoaded(this.masoFile, this.filePath);
}

/// State representing an error during file operation, with an error message.
class FileError extends FileState {
  final String message;  // Error message
  FileError(this.message);
}

// BLoC
/// BLoC that handles file operations: loading and saving files.
class FileBloc extends Bloc<FileEvent, FileState> {
  final FileRepository fileRepository;  // The repository responsible for file operations

  /// Constructor for the FileBloc that initializes the state and event handlers.
  FileBloc(this.fileRepository) : super(FileInitial()) {
    // Handling the FileDropped event
    on<FileDropped>((event, emit) async {
      emit(FileLoading());  // Emit loading state while the file is being processed
      try {
        if (event.filePath.endsWith('.maso')) {
          // If the file has the correct extension, load the file
          final masoFile = await fileRepository.loadMasoFile(event.filePath);
          emit(FileLoaded(masoFile, event.filePath));  // Emit the loaded file state
        } else {
          // If the file is not a .maso file, emit an error state
          emit(FileError('Error: Invalid file. Must be a .maso file.'));
        }
      } catch (e) {
        emit(FileError("Error opening file: $e"));  // Emit error if file loading fails
      }
    });

    // Handling the FileSaveRequested event
    on<FileSaveRequested>((event, emit) async {
      emit(FileLoading());  // Emit loading state while saving the file
      try {
        // Save the MasoFile to the specified path
        await fileRepository.saveMasoFile(event.filePath, event.masoFile);
        emit(FileLoaded(event.masoFile, event.filePath));  // Emit the loaded file state after save
      } catch (e) {
        emit(FileError("Error saving file: $e"));  // Emit error if file saving fails
      }
    });
  }
}
