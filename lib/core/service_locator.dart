import 'package:get_it/get_it.dart';
import 'package:maso/domain/models/execution_setup.dart';

import '../data/repositories/file_repository.dart';
import '../data/services/file_service.dart'
    if (dart.library.html) '../data/services/file_service_web.dart';
import '../domain/models/maso_file.dart';
import '../domain/use_cases/check_file_changes_use_case.dart';
import '../presentation/blocs/file_bloc/file_bloc.dart';

// Singleton class for managing service registrations
class ServiceLocator {
  // Create a single instance of GetIt
  final GetIt getIt = GetIt.instance;

  // Private constructor to prevent external instantiation
  ServiceLocator._();

  // The single instance of ServiceLocator
  static final ServiceLocator _instance = ServiceLocator._();

  // Getter for the single instance
  static ServiceLocator get instance => _instance;

  // Function to set up the service locator and register dependencies
  void setup() {
    getIt.registerLazySingleton<FileService>(() => FileService());
    getIt.registerLazySingleton<FileRepository>(
        () => FileRepository(fileService: getIt<FileService>()));
    getIt.registerLazySingleton<CheckFileChangesUseCase>(
        () => CheckFileChangesUseCase(fileRepository: getIt<FileRepository>()));
    getIt.registerFactory<FileBloc>(
        () => FileBloc(fileRepository: getIt<FileRepository>()));
  }

  // Function to register or update MasoFile in GetIt
  void registerMasoFile(MasoFile masoFile) {
    if (getIt.isRegistered<MasoFile>()) {
      getIt.unregister<MasoFile>();
    }
    getIt.registerLazySingleton<MasoFile>(() => masoFile);
  }

  // Function to register or update ExecutionSetup in GetIt
  void registerExecutionSetup(ExecutionSetup es) {
    if (getIt.isRegistered<ExecutionSetup>()) {
      getIt.unregister<ExecutionSetup>();
    }
    getIt.registerLazySingleton<ExecutionSetup>(() => es);
  }
}
