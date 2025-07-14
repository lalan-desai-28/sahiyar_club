import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sahiyar_club/app/bindings/initial_bindings.dart';
import 'package:sahiyar_club/app/core/theme/app_theme.dart';
import 'package:sahiyar_club/app/routes/app_pages.dart';
import 'package:sahiyar_club/app/routes/app_routes.dart';

class SahiyarClubApp extends StatelessWidget {
  const SahiyarClubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // App Configuration
      debugShowCheckedModeBanner: false,
      title: 'Sahiyar Club',

      // Navigation
      initialRoute: AppRoutes.SPLASH,
      getPages: AppPages.routes,
      initialBinding: InitialBindings(),

      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(textScaler: TextScaler.linear(1.0)),
          child: child!,
        );
      },

      // Reactive Theme - Remove hardcoded theme and themeMode
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // This will be controlled by ThemeController
      // Localization
      fallbackLocale: const Locale('en', 'US'),
    );
  }
}
