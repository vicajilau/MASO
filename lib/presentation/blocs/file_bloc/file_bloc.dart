import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/file_repository.dart';
import '../../../domain/models/custom_exceptions/file_invalid_exception.dart';
import 'file_event.dart';
import 'file_state.dart';

/// The `FileBloc` class handles file operations such as loading, saving, and picking files.
/// It listens for file-related events and emits the corresponding states based on the outcome of those events.
class FileBloc extends Bloc<FileEvent, FileState> {
  /// The repository responsible for handling file-related operations.
  final FileRepository _fileRepository;

  /// Constructor for `FileBloc` that initializes the state and event handlers.
  ///
  /// - [fileRepository]: An instance of `FileRepository` used to manage file operations.
  FileBloc({required FileRepository fileRepository})
      : _fileRepository = fileRepository,
        super(FileInitial()) {
    // Handling the FileDropped event
    on<FileDropped>((event, emit) async {
      emit(
          FileLoading()); // Emit loading state while the file is being processed
      try {
        final masoFile = await _fileRepository.loadMasoFile(event.filePath);
        emit(FileLoaded(masoFile)); // Emit the loaded file state
      } on FileInvalidException {
        emit(FileError(reason: FileErrorType.invalidExtension));
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

    // Handling the CreateMasoMetadata event
    on<CreateMasoMetadata>((event, emit) async {
      emit(
          FileLoading()); // Emit loading state while the file is being processed
      try {
        final masoFile = await _fileRepository.createMasoFile(
            name: event.name,
            version: event.version,
            description: event.description);
        emit(FileLoaded(masoFile)); // Emit the loaded file state after creation
      } on Exception catch (e) {
        emit(FileError(
            reason: FileErrorType.errorOpeningFile,
            error: e)); // Emit error if file creation fails
      } catch (e) {
        emit(FileError(
            reason: FileErrorType.errorOpeningFile,
            error: Exception(e))); // Emit error if file creation fails
      }
    });

    // Handling the MasoFileSaveRequested event
    on<MasoFileSaveRequested>((event, emit) async {
      emit(FileLoading()); // Emit loading state while saving the file
      try {
        // Save the `MasoFile` and update the state with the saved file
        event.masoFile = await _fileRepository.saveMasoFile(
            event.masoFile, event.dialogTitle, event.fileName);
        emit(FileLoaded(
            event.masoFile)); // Emit the loaded file state after save
      } on Exception catch (e) {
        emit(FileError(
            reason: FileErrorType.errorSavingMasoFile,
            error: e)); // Emit error if file saving fails
      } catch (e) {
        emit(FileError(
            reason: FileErrorType.errorSavingMasoFile, error: Exception(e)));
      }
    });

    on<ExportFileSaveRequested>((event, emit) async {
      emit(FileLoading()); // Emit loading state while saving the file
      try {
        // Save the `MasoFile` and update the state with the saved file
        await _fileRepository.saveExportedFile(
            event.bytes, event.dialogTitle, event.fileName);
        emit(FileExported()); // Emit the loaded file state after save
      } on Exception catch (e) {
        emit(FileError(
            reason: FileErrorType.errorSavingMasoFile,
            error: e)); // Emit error if file saving fails
      } catch (e) {
        emit(FileError(
            reason: FileErrorType.errorSavingMasoFile, error: Exception(e)));
      }
    });

    // Handling the MasoFileReset event
    on<MasoFileReset>((event, emit) async {
      emit(FileInitial()); // Emit initial state after reset
    });

    // Handling the MasoFilePickRequested event
    on<MasoFilePickRequested>((event, emit) async {
      emit(FileLoading()); // Emit loading state while picking the file
      try {
        final masoFile = await _fileRepository.pickFileManually();
        if (masoFile != null) {
          emit(FileLoaded(masoFile)); // Emit the loaded file state if picked
        } else {
          emit(FileInitial()); // Emit initial state if no file is picked
        }
      } on Exception catch (e) {
        emit(FileError(
            reason: FileErrorType.errorOpeningFile,
            error: e)); // Emit error if file picking fails
      } catch (e) {
        emit(FileError(
            reason: FileErrorType.errorOpeningFile, error: Exception(e)));
      }
    });
  }
}
