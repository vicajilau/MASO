import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:maso/routes/app_router.dart';

import 'core/constants/theme.dart';
import 'core/service_locator.dart';

void main() {
  ServiceLocator.instance.setup();
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
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      showSemanticsDebugger: true,
    );
  }
}
