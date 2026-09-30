import 'package:flutter/material.dart';

class MzTheme {
  static const Color red = Color(0xFFE53935);
  static const Color bg = Color(0xFF0A0A0F);
  static const Color card = Color(0xFF14141C);
  static const Color cardAlt = Color(0xFF16161F);
  static const Color cyan = Color(0xFF19D3FF);
  static const Color purple = Color(0xFF9B5CFF);
  static const Color green = Color(0xFF39FF88);

  static ThemeData get dark {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(seedColor: red, brightness: Brightness.dark),
      appBarTheme: const AppBarTheme(backgroundColor: card, elevation: 0),
    );
  }

  static ThemeData get ghost {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: Colors.black,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color(0xFF00FF41),
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF04140A),
        elevation: 0,
      ),
    );
  }
}
