import 'package:flutter/material.dart';
import 'package:maestropesto/app/maestro_pesto_app.dart';
import 'package:maestropesto/core/database/database_bootstrap.dart';

Future<void> main() async {
  // Drift expects the Flutter binding to be ready before opening the
  // native database (path_provider, file I/O, etc.). Ensure the binding
  // is initialised before we open the AppDatabase.
  WidgetsFlutterBinding.ensureInitialized();

  final services = await AppServices.open();

  // Run the app and close the database cleanly when the engine exits.
  runApp(MaestroPestoApp(services: services));
}