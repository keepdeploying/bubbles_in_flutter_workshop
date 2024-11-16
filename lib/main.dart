import 'package:bubbles_in_flutter/models/contact.dart';
import 'package:bubbles_in_flutter/screens/chat_screen.dart';
import 'package:bubbles_in_flutter/screens/home_screen.dart';
import 'package:bubbles_in_flutter/services/bubbles_service.dart';
import 'package:bubbles_in_flutter/services/chats_service.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ChatsService.instance.init();
  await BubblesService.instance.init();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final chats = ChatsService.instance;
    final bubbles = BubblesService.instance;

    return MaterialApp(
      initialRoute: '/',
      onGenerateInitialRoutes: (_) {
        return [
          if (!bubbles.isInBubble)
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          if (chats.launchContact != null)
            MaterialPageRoute(
              builder: (_) => ChatScreen(contact: chats.launchContact!),
            ),
        ];
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(
            builder: (_) => const HomeScreen(),
            settings: settings,
          );
        } else if (settings.name == '/chat') {
          final args = settings.arguments;
          if (args is Contact) {
            return MaterialPageRoute(
              builder: (_) => ChatScreen(contact: args),
              settings: settings,
            );
          }
        }
        return null;
      },
    );
  }
}
