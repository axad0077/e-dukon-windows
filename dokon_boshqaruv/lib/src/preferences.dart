import 'package:flutter/material.dart';
import 'l10n/app_strings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final themeModeProvider = StateNotifierProvider<ThemePreference, ThemeMode>(
    (ref) => ThemePreference());

class ThemePreference extends StateNotifier<ThemeMode> {
  ThemePreference() : super(ThemeMode.system) {
    _restore();
  }
  final _storage = const FlutterSecureStorage();
  bool _changed = false;
  Future<void> _writes = Future<void>.value();
  Future<void> _restore() async {
    try {
      final saved = await _storage.read(key: 'ui_theme_v1');
      if (!mounted || _changed) return;
      state = ThemeMode.values
          .firstWhere((x) => x.name == saved, orElse: () => ThemeMode.system);
    } catch (_) {/* Keep the system theme if local storage is unavailable. */}
  }

  Future<void> select(ThemeMode value) async {
    _changed = true;
    state = value;
    final write = _writes
        .catchError((Object _) {})
        .then((_) => _storage.write(key: 'ui_theme_v1', value: value.name));
    _writes = write;
    await write;
  }
}

final languageProvider = StateNotifierProvider<LanguagePreference, String>(
    (ref) => LanguagePreference());

class LanguagePreference extends StateNotifier<String> {
  LanguagePreference() : super('uz') {
    _restore();
  }
  final _storage = const FlutterSecureStorage();
  bool _changed = false;
  Future<void> _writes = Future<void>.value();
  Future<void> _restore() async {
    try {
      final saved = await _storage.read(key: 'ui_language_v1');
      if (!mounted || _changed || !['uz', 'ru', 'en'].contains(saved)) return;
      activeLanguage = saved!;
      state = saved;
    } catch (_) {}
  }

  Future<void> select(String value) async {
    if (!['uz', 'ru', 'en'].contains(value)) return;
    _changed = true;
    activeLanguage = value;
    state = value;
    final write = _writes
        .catchError((Object _) {})
        .then((_) => _storage.write(key: 'ui_language_v1', value: value));
    _writes = write;
    await write;
  }
}

ThemeData buildAppTheme(Brightness brightness) {
  final colors = ColorScheme.fromSeed(
      seedColor: const Color(0xFF175CD3), brightness: brightness);
  final dark = brightness == Brightness.dark;
  final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: colors.outlineVariant));
  return ThemeData(
    fontFamily: 'Inter',
    useMaterial3: true,
    colorScheme: colors,
    scaffoldBackgroundColor:
        dark ? const Color(0xFF10141C) : const Color(0xFFF6F8FC),
    appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        centerTitle: false),
    inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        border: border,
        enabledBorder: border,
        contentPadding: const EdgeInsets.all(16)),
    filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
            minimumSize: const Size(48, 48),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            alignment: Alignment.center,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)))),
    outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
            minimumSize: const Size(48, 48),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            alignment: Alignment.center,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)))),
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
            minimumSize: const Size(48, 48),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12))),
    iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(48, 48))),
    navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        indicatorColor: colors.primaryContainer,
        elevation: 0),
    dividerTheme: DividerThemeData(color: colors.outlineVariant, thickness: 1),
  );
}
