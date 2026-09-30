import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class GhostMode {
  static final ValueNotifier<bool> active =
      ValueNotifier<bool>(Hive.box('store').get('ghost') == true);

  static void toggle() {
    final next = !active.value;
    active.value = next;
    Hive.box('store').put('ghost', next);
  }

  static Color get accent =>
      active.value ? const Color(0xFF00FF41) : const Color(0xFFE53935);
  static Color get bg =>
      active.value ? Colors.black : const Color(0xFF0A0A0F);
  static Color get card =>
      active.value ? const Color(0xFF04140A) : const Color(0xFF14141C);
  static Color get cardAlt =>
      active.value ? const Color(0xFF06180D) : const Color(0xFF16161F);
}
