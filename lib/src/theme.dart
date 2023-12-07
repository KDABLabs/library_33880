import 'package:flutter/material.dart';

ThemeData lightTheme({required Color seedColor}) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.light,
  );

  return ThemeData.light(useMaterial3: false).copyWith(
    colorScheme: colorScheme,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.primary,
      foregroundColor: Colors.white,
    ),
    brightness: Brightness.light,
  );
}

ThemeData darkTheme({required Color seedColor}) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.dark,
  );

  return ThemeData.dark(useMaterial3: false).copyWith(
    colorScheme: colorScheme,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.inversePrimary,
    ),
    brightness: Brightness.dark,
  );
}
