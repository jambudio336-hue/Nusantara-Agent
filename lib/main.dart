import 'package:flutter/material.dart';

import 'screens/chat.dart';
import 'screens/settings.dart';
import 'screens/welcome.dart';
import 'services/storage.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = StorageService();
  await storage.init();

  runApp(
    StorageScope(
      storage: storage,
      child: const MazkiplayAIApp(),
    ),
  );
}

class MazkiplayAIApp extends StatelessWidget {
  const MazkiplayAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mazkiplay AI',
      debugShowCheckedModeBanner: false,
      theme: MazkiplayTheme.dark(),
      home: const WelcomeScreen(),
      routes: {
        '/chat': (_) => const ChatScreen(),
        '/settings': (_) => const SettingsScreen(),
      },
    );
  }
}
