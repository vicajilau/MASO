import 'package:go_router/go_router.dart';
import 'package:maso/presentation/screens/file_loaded_screen.dart';
import 'package:maso/presentation/screens/maso_file_execution_screen.dart';

import '../presentation/screens/home_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String fileLoadedScreen = '/file_loaded_screen';
  static const String masoFileExecutionScreen = '/maso_file_execution_screen';
}

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.fileLoadedScreen,
      builder: (context, state) => const FileLoadedScreen(),
    ),
    GoRoute(
      path: AppRoutes.masoFileExecutionScreen,
      builder: (context, state) => const MasoFileExecutionScreen(),
    ),
  ],
);
