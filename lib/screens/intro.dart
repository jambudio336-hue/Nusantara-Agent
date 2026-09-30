import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class IntroScreen extends StatefulWidget {
  final Widget next;
  const IntroScreen({super.key, required this.next});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  late final VideoPlayerController controller;
  bool ready = false;
  bool finished = false;
  DateTime? _openedAt;

  @override
  void initState() {
    super.initState();
    _enterImmersive();
    controller = VideoPlayerController.asset('assets/intro.mp4');
    _initVideo();
  }

  Future<void> _enterImmersive() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<void> _initVideo() async {
    try {
      await controller.initialize();
      if (!mounted) return;
      controller.setVolume(1.0); // use the video's original audio track at full player volume
      controller.addListener(_videoListener);
      setState(() => ready = true);
      _openedAt = DateTime.now();
      await controller.play();
      _pulse();
    } catch (_) {
      _finish();
    }
  }

  void _pulse() {
    if (!mounted || finished) return;
    final elapsed = _openedAt == null ? Duration.zero : DateTime.now().difference(_openedAt!);
    if (elapsed >= const Duration(seconds: 10)) return;
    HapticFeedback.heavyImpact();
    Future<void>.delayed(const Duration(milliseconds: 320), () {
      if (mounted && !finished) _pulse();
    });
  }

  void _videoListener() {
    if (!controller.value.isInitialized) return;
    final position = controller.value.position;
    final duration = controller.value.duration;
    if (duration > Duration.zero &&
        position >= duration &&
        !controller.value.isPlaying) {
      _finish();
    }
  }

  Future<void> _finish() async {
    if (finished || !mounted) return;
    finished = true;
    await controller.pause();
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => widget.next),
    );
  }

  @override
  void dispose() {
    finished = true;
    controller.removeListener(_videoListener);
    controller.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: ready
              ? SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: controller.value.size.width,
                      height: controller.value.size.height,
                      child: VideoPlayer(controller),
                    ),
                  ),
                )
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFFE53935)),
                    SizedBox(height: 16),
                    Text(
                      'MAZKIPLAY AI',
                      style: TextStyle(
                        color: Colors.white,
                        letterSpacing: 4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
