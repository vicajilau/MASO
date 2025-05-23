import 'package:flutter/material.dart';
import 'package:maso/routes/app_router.dart';

import 'core/constants/theme.dart';
import 'core/file_handler.dart';
import 'core/l10n/app_localizations.dart';
import 'core/service_locator.dart';

void main() {
  ServiceLocator.instance.setup();
  runApp(const MasoApp());
}

class MasoApp extends StatefulWidget {
  const MasoApp({super.key});

  @override
  State<MasoApp> createState() => _MasoAppState();
}

class _MasoAppState extends State<MasoApp> {
  @override
  void initState() {
    super.initState();

    FileHandler.initialize((filePath) {
      if (mounted) {
        appRouter.go(AppRoutes.home);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      showSemanticsDebugger: false,
    );
  }
}
