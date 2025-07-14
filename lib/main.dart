// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sahiyar_club/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI preferences
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const SahiyarClubApp());
}
