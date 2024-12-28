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
            error: Exception(e)));
      }
    });

    on<FilePickRequested>((event, emit) async {
      emit(FileLoading()); // Emit loading state while saving the file
      try {
        // Save the MasoFile to the specified path
        final path = await fileRepository.pickFile();
        if (path != null) {
          add(FileDropped(path));
        }

      } on Exception catch (e) {
        emit(FileError(
            reason: FileErrorType.errorSavingFile,
            error: e)); // Emit error from Exception
      } catch (e) {
        emit(FileError(
            reason: FileErrorType.errorSavingFile,
            error: Exception(e)));
      }
    });
  }
}