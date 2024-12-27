import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../data/repositories/file_repository.dart';
import '../../domain/models/maso_file.dart';

// Events
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

// States
/// Abstract class representing the base state for file operations.
abstract class FileState {}

/// Initial state when no file operation is in progress.
class FileInitial extends FileState {}

/// State representing that a file operation is currently loading.
class FileLoading extends FileState {}

/// State representing a successfully loaded file, containing the file data and path.
class FileLoaded extends FileState {
  final MasoFile masoFile; // The loaded MasoFile object
  final String filePath; // Path of the loaded file

  FileLoaded(this.masoFile, this.filePath);
}

/// State representing an error during file operation, with an error message.
class FileError extends FileState {
  final Exception? error; // Error exception
  final FileErrorType reason; // Error reason

  FileError({required this.reason, this.error});

  /// Returns a descriptive string for the error type.
  /// The [context] parameter can be used for localization if needed.
  String getDescription(BuildContext context) {
    switch (reason) {
      case FileErrorType.invalidExtension:
        return AppLocalizations.of(context)!.errorInvalidFile;
      case FileErrorType.errorOpeningFile:
        return AppLocalizations.of(context)!.errorLoadingFile(error.toString());
      case FileErrorType.errorSavingFile:
        return AppLocalizations.of(context)!.errorSavingFile(error.toString());
    }
  }
}

/// Enumeration representing specific reasons for file-related errors.
enum FileErrorType {
  /// The file has an unsupported or incorrect extension.
  invalidExtension,

  /// There was an error while trying to open the file.
  errorOpeningFile,

  /// There was an error while trying to save the file.
  errorSavingFile;
}

// BLoC
/// BLoC that handles file operations: loading and saving files.
class FileBloc extends Bloc<FileEvent, FileState> {
  final FileRepository
      fileRepository; // The repository responsible for file operations

  /// Constructor for the FileBloc that initializes the state and event handlers.
  FileBloc(this.fileRepository) : super(FileInitial()) {
    // Handling the FileDropped event
    on<FileDropped>((event, emit) async {
      emit(
          FileLoading()); // Emit loading state while the file is being processed
      try {
        if (event.filePath.endsWith('.maso')) {
          // If the file has the correct extension, load the file
          final masoFile = await fileRepository.loadMasoFile(event.filePath);
          emit(FileLoaded(
              masoFile, event.filePath)); // Emit the loaded file state
        } else {
          // If the file is not a .maso file, emit an error state
          emit(FileError(reason: FileErrorType.invalidExtension));
        }
      } on Exception catch (e) {
        emit(FileError(
            reason: FileErrorType.errorOpeningFile,
            error: e)); // Emit error if file saving fails
      } catch (e) {
        emit(FileError(
            reason: FileErrorType.errorOpeningFile,
            error: Exception(e))); // Emit error if file loading fails
      }
    });

    // Handling the FileSaveRequested event
    on<FileSaveRequested>((event, emit) async {
      emit(FileLoading()); // Emit loading state while saving the file
      try {
        // Save the MasoFile to the specified path
        await fileRepository.saveMasoFile(event.filePath, event.masoFile);
        emit(FileLoaded(event.masoFile,
            event.filePath)); // Emit the loaded file state after save
      } on Exception catch (e) {
        emit(FileError(
            reason: FileErrorType.errorSavingFile,
            error: e)); // Emit error from Exception
      } catch (e) {
        emit(FileError(
            reason: FileErrorType.errorSavingFile,
            error: Exception(e))); // Emit error from _TypeError
      }
    });
  }
}
