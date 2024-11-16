import 'package:bubbles_in_flutter/models/contact.dart';
import 'package:bubbles_in_flutter/services/chats_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final chats = ChatsService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('People'),
        actions: [
          IconButton(onPressed: chats.clear, icon: const Icon(Icons.refresh))
        ],
      ),
      body: StreamBuilder<List<Contact>>(
        stream: chats.contacts,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final contacts = snapshot.data!;
          return ListView.builder(
            itemBuilder: (_, i) => ListTile(
              leading: CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage('assets/${contacts[i].name}.jpg'),
              ),
              title: Text(contacts[i].name),
              onTap: () {
                Navigator.of(context).pushNamed(
                  '/chat',
                  arguments: contacts[i],
                );
              },
            ),
            itemCount: contacts.length,
          );
        },
      ),
    );
  }
}
