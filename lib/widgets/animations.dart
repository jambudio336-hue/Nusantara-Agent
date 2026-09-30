import 'dart:async';
import 'package:flutter/material.dart';

class PageFade extends StatefulWidget {
  final Widget child;
  const PageFade({super.key, required this.child});
  @override State<PageFade> createState() => _PageFadeState();
}
class _PageFadeState extends State<PageFade> with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  @override void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 450))..forward();
  }
  @override void dispose() { controller.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: controller, curve: Curves.easeOut);
    return FadeTransition(opacity: curve, child: SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, .04), end: Offset.zero).animate(curve),
      child: widget.child,
    ));
  }
}

class PopIn extends StatefulWidget {
  final Widget child;
  final int delayMs;
  const PopIn({super.key, required this.child, this.delayMs = 0});
  @override State<PopIn> createState() => _PopInState();
}
class _PopInState extends State<PopIn> with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  Timer? delay;
  @override void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    if (widget.delayMs <= 0) {
      controller.forward();
    } else {
      delay = Timer(Duration(milliseconds: widget.delayMs), () {
        if (mounted) controller.forward();
      });
    }
  }
  @override void dispose() { delay?.cancel(); controller.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: controller, curve: Curves.easeOut);
    return FadeTransition(opacity: curve, child: ScaleTransition(
      scale: Tween<double>(begin: .96, end: 1).animate(curve), child: widget.child));
  }
}

class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const Pressable({super.key, required this.child, required this.onTap});
  @override State<Pressable> createState() => _PressableState();
}
class _PressableState extends State<Pressable> {
  bool down = false;
  @override Widget build(BuildContext context) => GestureDetector(
    onTap: widget.onTap,
    onTapDown: (_) => setState(() => down = true),
    onTapCancel: () => setState(() => down = false),
    onTapUp: (_) => setState(() => down = false),
    child: AnimatedScale(scale: down ? .97 : 1, duration: const Duration(milliseconds: 90), child: widget.child),
  );
}

class TypingDots extends StatefulWidget {
  const TypingDots({super.key});
  @override State<TypingDots> createState() => _TypingDotsState();
}
class _TypingDotsState extends State<TypingDots> with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  @override void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  }
  @override void dispose() { controller.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (_, __) => Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (i) {
      final phase = (controller.value + i / 3) % 1;
      final pulse = phase < .5 ? phase * 2 : (1 - phase) * 2;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Transform.scale(scale: .7 + pulse * .3,
          child: const CircleAvatar(radius: 3, backgroundColor: Colors.white54)),
      );
    })),
  );
}
