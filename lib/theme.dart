import 'package:flutter/material.dart';

class MzTheme {
  static const Color red = Color(0xFFE53935);
  static const Color bg = Color(0xFF08090F);
  static const Color card = Color(0xFF12131D);
  static const Color cardAlt = Color(0xFF181A27);
  static const Color cyan = Color(0xFF19D3FF);
  static const Color purple = Color(0xFF9B5CFF);
  static const Color green = Color(0xFF39FF88);
  static const Color gold = Color(0xFFFFC857);

  static ThemeData get dark => _base(seed: red, background: bg);

  static ThemeData get ghost => _base(
    seed: const Color(0xFF00FF41),
    background: Colors.black,
    appBar: const Color(0xFF04140A),
  );

  static ThemeData _base({required Color seed, required Color background, Color? appBar}) {
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark);
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: scheme,
      appBarTheme: AppBarTheme(backgroundColor: appBar ?? card, elevation: 0, centerTitle: false),
      statusBarColor: background,
      navigationBarColor: background,
      cardTheme: CardThemeData(color: card, elevation: 0, margin: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: Colors.white10))),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: cardAlt,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: seed, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: card,
        indicatorColor: seed.withValues(alpha: .22),
        labelTextStyle: WidgetStateProperty.all(const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
      ),
      snackBarTheme: SnackBarThemeData(backgroundColor: cardAlt, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {TargetPlatform.android: FadeForwardsPageTransitionsBuilder()}),
    );
  }
}
