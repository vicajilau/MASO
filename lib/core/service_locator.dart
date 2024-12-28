import 'package:get_it/get_it.dart';

import '../data/repositories/file_repository.dart';
import '../data/services/file_service.dart';
import '../presentation/blocs/file_bloc/file_bloc.dart';

// Create an instance of GetIt, which is the service locator
final getIt = GetIt.instance;

// Function to set up the service locator and register dependencies
void setupServiceLocator() {
  // Register FileService as a lazy singleton, it will be created only when requested
  getIt.registerLazySingleton<FileService>(() => FileService());

  // Register FileRepository as a lazy singleton, passing FileService instance from GetIt
  getIt.registerLazySingleton<FileRepository>(
      () => FileRepository(getIt<FileService>()));

  // Register FileBloc as a factory, a new instance will be created every time it's requested
  getIt.registerFactory<FileBloc>(() => FileBloc(getIt<FileRepository>()));
}
