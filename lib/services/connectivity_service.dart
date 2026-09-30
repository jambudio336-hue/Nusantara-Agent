import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme.dart';

class NetGate {
  static Widget guard(Widget child) => _NetGateView(child: child);
}

class _NetGateView extends StatefulWidget {
  final Widget child;
  const _NetGateView({required this.child});

  @override
  State<_NetGateView> createState() => _NetGateViewState();
}

class _NetGateViewState extends State<_NetGateView>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late final AnimationController _pulse;
  bool? _online;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: .75,
      upperBound: 1,
    )..repeat(reverse: true);

    _check();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _check());
  }

  Future<void> _check() async {
    if (kIsWeb) {
      if (mounted) setState(() => _online = true);
      return;
    }

    try {
      final result = await InternetAddress.lookup('openrouter.ai')
          .timeout(const Duration(seconds: 5));
      final online = result.isNotEmpty && result.first.rawAddress.isNotEmpty;
      if (mounted) setState(() => _online = online);
    } catch (_) {
      if (mounted) setState(() => _online = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final blocked = _online != true;

    return Stack(
      children: [
        IgnorePointer(
          ignoring: blocked,
          child: widget.child,
        ),
        if (blocked)
          Positioned.fill(
            child: Material(
              color: const Color(0xEE08080D),
              child: Center(
                child: AnimatedBuilder(
                  animation: _pulse,
                  builder: (_, child) => Transform.scale(
                    scale: _pulse.value,
                    child: child,
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(28),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: MzTheme.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: MzTheme.red.withOpacity(.6),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.wifi_off_rounded,
                          color: MzTheme.red,
                          size: 58,
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'ONLINE CHECK',
                          style: TextStyle(
                            color: MzTheme.red,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _online == null
                              ? 'Memeriksa koneksi internet...'
                              : 'Mazkiplay AI memakai layanan online dan realtime. '
                                'Pengecekan koneksi akan diperbarui otomatis.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white60),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Auto-check setiap 5 detik',
                          style: TextStyle(color: Colors.white30, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
