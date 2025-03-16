import 'package:flutter/material.dart';

final colorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 158, 206, 154),
  surface: const Color.fromARGB(255, 19, 24, 17),
  onSurface: const Color.fromARGB(255, 158, 206, 154),
  primary: const Color.fromARGB(255, 65, 94, 69),
  onPrimary: const Color.fromARGB(255, 206, 255, 216),
  secondary: const Color.fromARGB(255, 6, 12, 6),
  error: Colors.red.withOpacity(0.5),
);

final theme = ThemeData.dark().copyWith(
  colorScheme: colorScheme,
  appBarTheme: const AppBarTheme().copyWith(
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: colorScheme.surface,
    foregroundColor: Colors.white70,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: colorScheme.primary,
      foregroundColor: Colors.white,
    ),
  ),
  popupMenuTheme: PopupMenuThemeData(
    color: colorScheme.surface,
    shadowColor: Colors.white12,
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: colorScheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: Colors.white38),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      textStyle: TextStyle(
        color: colorScheme.primary,
        fontSize: 18,
      ),
    ),
  ),
  textTheme: const TextTheme().copyWith(
    titleLarge: const TextStyle(
      color: Color.fromARGB(180, 255, 255, 255),
      fontWeight: FontWeight.bold,
      fontSize: 24,
    ),
    bodyLarge: const TextStyle(
      color: Color.fromARGB(180, 255, 255, 255),
      fontSize: 18,
    ),
    bodyMedium: const TextStyle(
      color: Color.fromARGB(180, 255, 255, 255),
      fontSize: 14,
    ),
    bodySmall: const TextStyle(
      color: Color.fromARGB(180, 255, 255, 255),
      fontSize: 12,
    ),
  ),
);
