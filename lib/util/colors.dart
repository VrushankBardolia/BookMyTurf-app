import 'package:flutter/material.dart';

// Dark mode ColorScheme
final ColorScheme darkColorScheme = const ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF81C784),
  onPrimary: Colors.black,
  secondary: Color(0xFF388E3C),
  onSecondary: Colors.white,
  error: Colors.redAccent,
  onError: Colors.black,
  background: Color(0xFF000000),
  onBackground: Colors.white,
  surface: Color(0xFF1E1E1E),
  onSurface: Colors.white,
);

class BMTTheme{
  static const Color black = Color(0xFF0C0C0C);
  static const Color black50 = Color(0x800C0C0C);
  static const Color white = Color(0xFFF1F1F1);
  static const Color white50 = Color(0x80F1F1F1);
  static const Color background = Color(0xFF1D1D1D);
  static const Color brand = Color(0xFF00C950);
}