import 'package:get_it/get_it.dart';
import '../data/repositories/file_repository.dart';
import '../data/services/file_service.dart';
import '../domain/models/maso_file.dart';
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
            () => FileRepository(getIt<FileService>()));
    getIt.registerFactory<FileBloc>(() => FileBloc(getIt<FileRepository>()));
  }

  // Function to register or update MasoFile in GetIt
  void registerMasoFile(MasoFile masoFile) {
    if (getIt.isRegistered<MasoFile>()) {
      getIt.unregister<MasoFile>();
    }
    getIt.registerLazySingleton<MasoFile>(() => masoFile);
  }
}
