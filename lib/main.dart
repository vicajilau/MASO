import 'package:flutter/material.dart';
import 'package:maso/routes/app_router.dart';

import 'core/constants/theme.dart';
import 'core/service_locator.dart';

void main() {
  setupServiceLocator();
  runApp(const MasoApp());
}

class MasoApp extends StatelessWidget {
  const MasoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode
          .system, // Cambia automáticamente entre claro y oscuro según el sistema
    );
  }
}
