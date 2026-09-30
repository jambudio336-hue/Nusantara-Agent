import 'package:flutter/material.dart';

class MzTheme {
  static const red = Color(0xFFE53935);
  static const bg = Color(0xFF0A0A0F);
  static const card = Color(0xFF14141C);
  static const cardAlt = Color(0xFF16161F);

  static ThemeData get dark => ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(seedColor: red, brightness: Brightness.dark),
        appBarTheme: const AppBarTheme(backgroundColor: card, elevation: 0),
      );
}
