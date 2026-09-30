import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class IntroScreen extends StatefulWidget {
  final Widget next;
  const IntroScreen({super.key, required this.next});

  @override State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  late final VideoPlayerController controller;
  bool ready = false;
  bool finished = false;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.asset('assets/intro.mp4');
    controller.initialize().then((_) {
      if (!mounted) return;
      controller.setVolume(1.0);
      controller.play();
      controller.addListener(_videoListener);
      setState(() => ready = true);
      _pulse();
    }).catchError((_) => _finish());
    Future<void>.delayed(const Duration(seconds: 10), () {
      if (mounted && !ready) _finish();
    });
  }

  void _pulse() {
    if (!mounted || finished) return;
    HapticFeedback.heavyImpact();
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (mounted && !finished) _pulse();
    });
  }

  void _videoListener() {
    if (!controller.value.isInitialized) return;
    if (controller.value.position >= controller.value.duration &&
        !controller.value.isPlaying) {
      _finish();
    }
  }

  void _finish() {
    if (finished || !mounted) return;
    finished = true;
    controller.removeListener(_videoListener);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => widget.next),
    );
  }

  @override
  void dispose() {
    finished = true;
    controller.removeListener(_videoListener);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ready
            ? FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller.value.size.width,
                  height: controller.value.size.height,
                  child: VideoPlayer(controller),
                ),
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFFE53935)),
                  SizedBox(height: 16),
                  Text('MAZKIPLAY AI', style: TextStyle(color: Colors.white, letterSpacing: 4)),
                ],
              ),
      ),
    );
  }
}
