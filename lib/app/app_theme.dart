import 'package:flutter/material.dart';

ThemeData buildAppTheme(Brightness brightness) {
  const seed = Color(0xFF0F6C7A);
  final base = ThemeData(
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: brightness),
    useMaterial3: true,
  );
  return base.copyWith(
    scaffoldBackgroundColor: brightness == Brightness.dark
        ? const Color(0xFF0F171A)
        : const Color(0xFFF4F7F8),
    cardTheme: CardThemeData(
      elevation: 0,
      color: brightness == Brightness.dark
          ? const Color(0xFF172126)
          : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: EdgeInsets.zero,
    ),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: base.colorScheme.onSurface,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      filled: true,
      fillColor: brightness == Brightness.dark
          ? const Color(0xFF11181D)
          : Colors.white,
    ),
  );
}
