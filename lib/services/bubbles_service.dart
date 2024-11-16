import 'package:conversation_bubbles/conversation_bubbles.dart';
import 'package:bubbles_in_flutter/models/contact.dart';
import 'package:flutter/services.dart';

class BubblesService {
  final _conversationBubblesPlugin = ConversationBubbles();

  static final instance = BubblesService._();

  BubblesService._();

  Future<void> init() async {
    _conversationBubblesPlugin.init(
      appIcon: '@mipmap/ic_launcher',
      fqBubbleActivity: 'com.example.bubbles_in_flutter.BubbleActivity',
    );
  }

  Future<void> show(
    Contact contact,
    String messageText, {
    bool shouldAutoExpand = false,
  }) async {
    final Contact(:id, :name) = contact;
    final bytesData = await rootBundle.load('assets/$name.jpg');
    final iconBytes = bytesData.buffer.asUint8List();

    await _conversationBubblesPlugin.show(
      notificationId: id,
      body: messageText,
      contentUri: 'https://bubbles_in_flutter.example.com/chat/$id',
      channel: const NotificationChannel(
          id: 'chat', name: 'Chat', description: 'Chat'),
      person: Person(id: '$id', name: name, icon: iconBytes),
      isFromUser: shouldAutoExpand,
      shouldMinimize: shouldAutoExpand,
    );
  }
}
