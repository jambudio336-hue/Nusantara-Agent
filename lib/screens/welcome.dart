import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool agreed = false;

  @override
  void dispose() { _player.dispose(); super.dispose(); }

  Future<void> _start() async {
    if (!agreed) return;
    try { await _player.play(AssetSource('sound/habataitara.mp3')); } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('agreed', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const ChatScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(builder: (context, box) => SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, box.maxHeight > 700 ? 34 : 18, 20, 28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Center(child: Container(
                width: 126, height: 126,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [Color(0xFFE53935), Color(0xFF8B1020)]),
                  boxShadow: const [BoxShadow(color: Color(0x55E53935), blurRadius: 30)],
                  border: Border.all(color: Colors.white24, width: 2),
                ),
                child: const Icon(Icons.shield_rounded, color: Colors.white, size: 70),
              )),
              const SizedBox(height: 24),
              const Text('Selamat datang di\nMazkiplay AI', textAlign: TextAlign.center,
                style: TextStyle(fontSize: 31, height: 1.08, fontWeight: FontWeight.w900, letterSpacing: .3)),
              const SizedBox(height: 10),
              const Text('Nusantara Agent • AI • Security • OSINT • Trading',
                textAlign: TextAlign.center, style: TextStyle(color: Colors.white60, fontSize: 13)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .045),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: cs.primary.withValues(alpha: .28)),
                ),
                child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('DISCLAIMER', style: TextStyle(color: Color(0xFFFF6B6B), fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  SizedBox(height: 9),
                  Text(
                    'Mazkiplay AI adalah asisten AI serbaguna untuk pembelajaran, pengembangan software, analisis data, keamanan siber, OSINT publik, dan analisis pasar. Gunakan fitur keamanan hanya pada sistem, akun, jaringan, dan data yang kamu miliki atau punya izin untuk menguji. Output AI dapat keliru dan bukan pengganti verifikasi profesional.',
                    style: TextStyle(color: Colors.white70, height: 1.5, fontSize: 12.5),
                  ),
                ]),
              ),
              const SizedBox(height: 14),
              CheckboxListTile(
                value: agreed,
                onChanged: (v) => setState(() => agreed = v ?? false),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('Saya telah membaca dan menyetujui disclaimer.', style: TextStyle(fontSize: 13)),
              ),
              const SizedBox(height: 10),
              SizedBox(height: 54, child: ElevatedButton.icon(
                onPressed: agreed ? _start : null,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('SETUJU & MASUK', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: .8)),
              )),
              const SizedBox(height: 14),
              const Text('Tanpa backend wajib • BYO OpenRouter API key • by M4zk1pL4y',
                textAlign: TextAlign.center, style: TextStyle(color: Colors.white30, fontSize: 11)),
            ]),
          ),
        )),
      ),
    );
  }
}
