import 'package:go_router/go_router.dart';
import 'package:maso/presentation/screens/file_loaded_screen.dart';

import '../presentation/screens/home_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String fileLoadedScreen = '/file_loaded_screen';
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
  ],
);
