import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';
import 'screens/intro.dart';
import 'screens/welcome.dart';
import 'screens/chat.dart';
import 'services/connectivity_service.dart';
import 'services/ghost_mode.dart';
import 'services/storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('store');
  await Hive.openBox('journal');
  await Hive.openBox('targets');
  await Store.init();
  runApp(const MazkiApp());
}

class MazkiApp extends StatelessWidget {
  const MazkiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: GhostMode.active,
      builder: (context, ghost, _) => MaterialApp(
        title: 'Mazkiplay AI',
        debugShowCheckedModeBanner: false,
        theme: ghost ? MzTheme.ghost : MzTheme.dark,
        home: NetGate.guard(
          FutureBuilder<SharedPreferences>(
            future: SharedPreferences.getInstance(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator(color: MzTheme.red)),
                );
              }
              final agreed = snap.data!.getBool('agreed') ?? false;
              return IntroScreen(
                next: agreed ? const ChatScreen() : const WelcomeScreen(),
              );
            },
          ),
        ),
      ),
    );
  }
}
