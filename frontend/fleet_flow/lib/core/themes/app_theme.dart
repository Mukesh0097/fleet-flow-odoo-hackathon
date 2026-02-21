import 'package:fluent_ui/fluent_ui.dart';

class AppTheme {
  static FluentThemeData get lightTheme {
    return FluentThemeData(
      brightness: Brightness.light,
      accentColor: Colors.blue,
    );
  }

  static FluentThemeData get darkTheme {
    return FluentThemeData(
      brightness: Brightness.dark,
      accentColor: Colors.blue,
      scaffoldBackgroundColor: const Color(0xFF1E1E1E),
    );
  }
}
