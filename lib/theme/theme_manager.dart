import 'package:flutter/material.dart';

class ThemeManager with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  get themeMode => _themeMode;

  toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

ThemeData lightTheme(context) {
  return ThemeData(
      textSelectionTheme: const TextSelectionThemeData(
          selectionHandleColor: Colors.transparent),
      splashFactory: NoSplash.splashFactory,
      fontFamily: 'ZillaSlab',
      useMaterial3: true,
      brightness: Brightness.light,
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Colors.green,
        actionTextColor: Colors.white,
      ),
      appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          foregroundColor: Colors.blue,
          centerTitle: true,
          titleTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 22.0)),
      primaryColor: Colors.black,
      dialogBackgroundColor: Colors.white,
      splashColor: Colors.white);
}

ThemeData darkTheme(context) => ThemeData(
      textSelectionTheme: const TextSelectionThemeData(
          selectionHandleColor: Colors.transparent),
      splashFactory: NoSplash.splashFactory,
      useMaterial3: true,
      fontFamily: 'ZillaSlab',
      scaffoldBackgroundColor: const Color(0xff2c3e50),
      brightness: Brightness.dark,
      appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xff2c3e50),
          foregroundColor: Colors.white,
          centerTitle: true,
          titleTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 22.0)),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Colors.white,
        actionTextColor: Colors.blue,
      ),
      primaryColor: Colors.white,
      dialogBackgroundColor: Colors.white,
      splashColor: const Color(0xff2c3e50),
    );
