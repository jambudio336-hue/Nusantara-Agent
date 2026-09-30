import 'package:flutter/material.dart';
import '../services/ghost_mode.dart';

class MzScaffold extends StatelessWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget body;
  final Widget? fab;
  const MzScaffold({super.key, this.title, this.actions, required this.body, this.fab});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return ValueListenableBuilder<bool>(
      valueListenable: GhostMode.active,
      builder: (context, ghost, child) => Scaffold(
        backgroundColor: ghost ? Colors.black : const Color(0xFF0A0A0F),
        appBar: title == null && actions == null ? null : AppBar(
          title: title == null ? null : Text(title!,
            style: TextStyle(color: ghost ? const Color(0xFF00FF41) : const Color(0xFFE53935))),
          actions: actions,
          backgroundColor: ghost ? const Color(0xFF04140A) : const Color(0xFF14141C),
        ),
        floatingActionButton: fab,
        body: SafeArea(child: Center(child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: width > 600 ? 560 : double.infinity),
          child: body,
        ))),
      ),
    );
  }
}

double fz(BuildContext context, double base) {
  final width = MediaQuery.of(context).size.width;
  final factor = (width / 360).clamp(.85, 1.25).toDouble();
  return base * factor;
}
