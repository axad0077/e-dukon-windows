import 'src/diagnostics/error_hooks.dart';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'src/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  installDiagnosticErrorHooks();

  // The POS screen formats the date with the Uzbek locale.
  await initializeDateFormatting('uz');
  await initializeDateFormatting('ru');
  await initializeDateFormatting('en');

  // Initialize sqflite for desktop platforms (Linux, Windows, macOS)
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const ProviderScope(child: DokonApp()));
}
