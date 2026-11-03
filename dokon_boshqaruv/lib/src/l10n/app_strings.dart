import 'package:flutter/widgets.dart';
export 'translations.dart';

class AppLocaleScope extends InheritedWidget {
  const AppLocaleScope(
      {super.key, required this.language, required super.child});
  final String language;
  static String of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppLocaleScope>()?.language ??
      'uz';
  @override
  bool updateShouldNotify(AppLocaleScope oldWidget) =>
      language != oldWidget.language;
}
