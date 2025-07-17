// app/app.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sahiyar_club/app/bindings/initial_bindings.dart';
import 'package:sahiyar_club/app/core/theme/app_theme.dart';
import 'package:sahiyar_club/app/routes/app_pages.dart';
import 'package:sahiyar_club/app/routes/app_routes.dart';
import 'package:sahiyar_club/controllers/connectivity_controller.dart';
import 'package:sahiyar_club/pages/no_internet_page.dart';

class SahiyarClubApp extends StatelessWidget {
  const SahiyarClubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
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
          child: ConnectivityWrapper(child: child!),
        );
      },

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      fallbackLocale: const Locale('en', 'US'),
    );
  }
}

class ConnectivityWrapper extends StatelessWidget {
  final Widget child;

  const ConnectivityWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConnectivityController>(
      init: ConnectivityController(),
      builder: (controller) {
        return Obx(() {
          if (controller.isConnected.value) {
            return child;
          } else {
            return const NoInternetPage();
          }
        });
      },
    );
  }
}
