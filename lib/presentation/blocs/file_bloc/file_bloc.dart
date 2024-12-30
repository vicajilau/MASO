import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/file_repository.dart';
import 'file_event.dart';
import 'file_state.dart';

/// BLoC that handles file operations: loading and saving files.
class FileBloc extends Bloc<FileEvent, FileState> {
  /// The repository responsible for file operations
  final FileRepository fileRepository;

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
          emit(FileLoaded(masoFile)); // Emit the loaded file state
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

    on<CreateMasoMetadata>((event, emit) async {
      emit(
          FileLoading()); // Emit loading state while the file is being processed
      try {
        final masoFile = await fileRepository.createMasoFile(
            name: event.name,
            version: event.version,
            description: event.description);
        emit(FileLoaded(masoFile)); // Emit the loaded file state
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
        // Save the MasoFile saved
        event.masoFile = await fileRepository.saveMasoFile(
            event.masoFile, event.dialogTitle);
        emit(FileLoaded(
            event.masoFile)); // Emit the loaded file state after save
      } on Exception catch (e) {
        emit(FileError(
            reason: FileErrorType.errorSavingFile,
            error: e)); // Emit error from Exception
      } catch (e) {
        emit(FileError(
            reason: FileErrorType.errorSavingFile, error: Exception(e)));
      }
    });

    on<FileReset>((event, emit) async {
      emit(FileInitial()); // Emit initial state after reset
    });

    on<FilePickRequested>((event, emit) async {
      emit(FileLoading()); // Emit loading state while pick the file
      try {
        final path = await fileRepository.pickFileManually();
        if (path != null) {
          add(FileDropped(path));
        }
        emit(FileInitial());
      } on Exception catch (e) {
        emit(FileError(
            reason: FileErrorType.errorSavingFile,
            error: e)); // Emit error from Exception
      } catch (e) {
        emit(FileError(
            reason: FileErrorType.errorSavingFile, error: Exception(e)));
      }
    });
  }
}
