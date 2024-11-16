# Bubbles In Flutter

Workshop for Android Conversation Bubbles in Flutter.

## Workshop Overview

The aim of this workshop is to get you started with showing Android
Conversation Bubbles in apps you build with Flutter.

In Android, Bubbles make it easier for users to see and participate in
conversations. To know more about Conversation Bubbles in Android, visit the
["Use bubbles for conversations" page in the Android Documentation](https://developer.android.com/develop/ui/views/notifications/bubbles).

This workshop uses the [conversation_bubbles](https://github.com/keepdeploying/conversation_bubbles)
Flutter package to show Bubbles.

## Workshop Requirements

- Have the [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
- Have your favorite Flutter IDE installed ([Android Studio](https://developer.android.com/studio)
  or [VS Code](https://code.visualstudio.com)) and properly configured for Flutter.
- Have an Android device or emulator running Android 11 or higher.

## Workshop Instructions

### A. Setup

1. Get the starter code for this workshop by cloning this repository:

```bash
git clone https://github.com/keepdeploying/bubbles_in_flutter_workshop
```

2. Change into the project directory:

```bash
cd bubbles_in_flutter_workshop
```

3. Checkout to the `starter` branch:

```bash
git checkout starter
```

4. Run `flutter pub get` to get the dependencies.

5. Open the project in your favorite Flutter IDE.

6. Run the app on an Android device or emulator and explore the "People" chat app.

### B. Notification Permissions

1. Add the following permission to the `AndroidManifest.xml` file, immediately after the opening `manifest` XML tag:

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

2. Install the [permission_handler](https://pub.dev/packages/permission_handler) package by running the following command:

```bash
flutter pub add permission_handler
```

3. Create a new Dart file called `notifications_permissions_service.dart` in the `lib/services` directory.

4. Add the following code to the `notifications_permissions_service.dart` file:

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Takes note of the number of times the notifications permission has been
/// requested. If it exceeds 2, the user is redirected to the app settings.
int _requestCount = 0;

class NotificationsPermissionService with WidgetsBindingObserver {
  final _ctrl = StreamController<bool>.broadcast()..add(false);

  static final instance = NotificationsPermissionService._();

  NotificationsPermissionService._() {
    check();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      check();
    }
  }

  Stream<bool> get isGrantedStream => _ctrl.stream;

  Future<void> check() async {
    _ctrl.add((await Permission.notification.status).isGranted);
  }

  Future<void> request() async {
    if (_requestCount > 2) {
      await openAppSettings();
      return;
    }
    _requestCount++;
    await Permission.notification.request();
    await check();
  }
}
```

5. In `lib/screens/home_screen.dart`, import the `notifications_permissions_service.dart` file:

```dart
import 'package:bubbles_in_flutter/services/notifications_permissions_service.dart';
```

6. In the `_HomeScreenState` class, declare a reference to the `NotificationsPermissionService` instance alongside the existing `chats` variable:

```dart
final notifService = NotificationsPermissionService.instance;
```

7. In the `actions` list of the `AppBar` widget, add a StreamBuilder on the `isGrantedStream` of the service, that shows an `IconButton` that to request permissions if not granted:

```dart
StreamBuilder(
  stream: notifService.isGrantedStream,
  builder: (context, snap) {
    // snap.data is nullable
    if (snap.data != true) {
      return IconButton(
        icon: const Icon(Icons.notifications_on_outlined),
        onPressed: notifService.request,
      );
    }
    return const SizedBox();
  },
),
```

8. If the Flutter app is running, stop it and run it again. Otherwise, just still run the app with these new changes. Request notification permissions by tapping the notification icon in the app bar.

### C. Bubbles

1. Add a new `intent-filter` to the MainActivity in the `AndroidManifest.xml` handle app opening from a Bubble or notification. Add the following code before the closing `</activity>` tag in the `AndroidManifest.xml` file:

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:host="bubbles_in_flutter.example.com"
        android:pathPattern="/chat/*"
        android:scheme="https" />
</intent-filter>
```

2. Create a new file called `BubbleActivity.kt` in the `android/app/src/main/kotlin/com/example/bubbles_in_flutter` directory alongside MainActivity.kt.

3. Add the following code to the `BubbleActivity.kt` file:

```kt
package com.example.bubbles_in_flutter

import io.flutter.embedding.android.FlutterActivity

class BubbleActivity: FlutterActivity()
```

4. Add the BubbleActivity to the `AndroidManifest.xml` with the "embeddable" and "resizeable" attributes required for Bubbles. Also add the `intent-filter` for getting the Bubble intent from the BubbleActivity at the same time. Paste the following code after the closing `</activity>` tag in the `AndroidManifest.xml` file:

```xml
<activity
    android:name=".BubbleActivity"
    android:exported="true"
    android:theme="@style/LaunchTheme"
    android:documentLaunchMode="always"
    android:allowEmbedded="true"
    android:resizeableActivity="true">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data
            android:host="bubbles_in_flutter.example.com"
            android:pathPattern="/chat/*"
            android:scheme="https" />
    </intent-filter>
</activity>
```

5. Install the [conversation_bubbles](https://github.com/keepdeploying/conversation_bubbles) package by adding it as a dependency (with git) in the `dependencies` section of the `pubspec.yaml` file:

```yaml
conversation_bubbles:
  git:
    url: https://github.com/keepdeploying/conversation_bubbles
```

6. Run `flutter pub get` to get the new dependency.

7. Create a new file called `bubbles_service.dart` in the `lib/services` directory.

8. Add the following code to the `bubbles_service.dart` file:

```dart
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
      fqBubbleActivity:
          'com.example.bubbles_in_flutter.BubbleActivity',
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
      contentUri:
          'https://bubbles_in_flutter.example.com/chat/$id',
      channel: const NotificationChannel(
          id: 'chat', name: 'Chat', description: 'Chat'),
      person: Person(id: '$id', name: name, icon: iconBytes),
      isFromUser: shouldAutoExpand,
      shouldMinimize: shouldAutoExpand,
    );
  }
}
```

9. In `lib/main.dart`, import the `bubbles_service.dart` file:

```dart
import 'package:bubbles_in_flutter/services/bubbles_service.dart';
```

10. Initialize the `BubblesService` alongside the existing `ChatsService` in the `main` function:

```dart
await BubblesService.instance.init();
```

11. In the `lib/services/chats_service.dart` file, import the `bubbles_service.dart` file:

```dart
import 'package:bubbles_in_flutter/services/bubbles_service.dart';
```

12. In the `send` method of the `ChatsService` file, add the following code to show a Bubble with the created reply message, after the reply has been saved to the local database:

```dart
await BubblesService.instance.show(contact, reply.text);
```

13. In the `lib/screens/chat_screen.dart` file, import the `bubbles_service.dart` file:

```dart
import 'package:bubbles_in_flutter/services/bubbles_service.dart';
```

14. In the `_ChatScreenState` class, declare a reference to the `BubblesService` instance alongside the existing `chats` variable:

```dart
final bubbles = BubblesService.instance;
```

15. Add an "Open In New" IconButton in the `actions` list of the AppBar to bubble the chat in focus.

```dart
  actions: [
    IconButton(
      icon: const Icon(Icons.open_in_new),
      onPressed: () =>
          bubbles.show(widget.contact, '',  shouldAutoExpand: true),
    ),
  ],
```

16. If the Flutter app is running, stop it and run it again. Otherwise, just still run the app with these new changes. Send a message to any animal and minimize the app. See the notification show and expand the bubble. Also, go back to the Chat Screen when in the full app, tap the "Open In New" button and see how it expands the bubble.

### D. Launch Contact

Our Bubbles now show but they always open to the HomeScreen with all the animals listed. We need to make the Bubble open to the ChatScreen of the animal it was sent to.

To achieve that, we have to obtain the `intentUri` from the package and use it to navigate to the appropriate ChatScreen.

1. In ChatsService, declare a private nullable Contact that could have been obtained from app launch. Also, add a getter to get the launch contact:

```dart
Contact? _launchContact;
Contact? get launchContact => _launchContact;
```

2. Import the `conversation_bubbles` package in the `chats_service.dart` file:

```dart
import 'package:conversation_bubbles/conversation_bubbles.dart';
```

3. In the `init` method of the ChatsService, after initializing the local database and setting up contacts, get the intentUri from the package and set the launch contact if it is not null:

```dart
  final intentUri = await ConversationBubbles().getIntentUri();
  if (intentUri != null) {
    final uri = Uri.tryParse(intentUri);
    if (uri != null) {
      final id = int.tryParse(uri.pathSegments.last);
      if (id != null) {
        _launchContact = await ChatsService.instance.getContact(id);
      }
    }
  }
```

4. In the build method of the MainApp widget in `lib/main.dart` file, declare a reference to the ChatsService instance before the top-level return statement:

```dart
final chats = ChatsService.instance;
```

5. In MaterialApp, set the onGenerateInitialRoutes property to a list that contains the ChatScreen of the launch contact if the contact is not null. We first put the HomeScreen to be sure that back button presses will work in the full app (that's if the app was opened from a notification and not a bubble).

```dart
 onGenerateInitialRoutes: (_) {
    return [
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      if (chats.launchContact != null)
        MaterialPageRoute(
          builder: (_) => ChatScreen(contact: chats.launchContact!),
        ),
    ];
  },
```

5. If the Flutter app is running, stop it and run it again. Otherwise, just still run the app with these new changes. Send a message to any animal and minimize the app. Tap the notification to open the app from the Bubble. The app should open to the ChatScreen of the animal the message was sent to.

### E. Is In Bubble

We need to know if the app is running in a Bubble or not. This is important for the app to know if it should modify its UI based on the Bubble view or not.

1. In the `bubbles_service.dart` file, declare a private bool to keep track of whether the app is in a Bubble or not. Also, add a getter to expose the value:

```dart
bool _isInBubble = false;
bool get isInBubble => _isInBubble;
```

2. In the `init` method of the `BubblesService` class, after initializing the package, set the `_isInBubble` value from the package's getter:

```dart
_isInBubble = await _conversationBubblesPlugin.isInBubble();
```

3. In the build method of the MainApp widget in `lib/main.dart` file, declare a reference to the BubblesService instance before the top-level return statement, alongside the already declared ChatsService instance:

```dart
final bubbles = BubblesService.instance;
```

4. In the `onGenerateInitialRoutes` property of the MaterialApp widget, put the HomeScreen first only if the app is not in a Bubble. This is to be sure that the user can't navigate backwards to the HomeScreen from the ChatScreen when the app is in a Bubble.

Add a negative if condition to the HomeScreen route to load HomeScreen if the app is not in a bubble:

```dart
  if (!bubbles.isInBubble)
    MaterialPageRoute(builder: (_) => const HomeScreen()),
```

5. In the `actions` list of the AppBar widget in the ChatScreen, add a condition to show the "Open In New" icon only if the app is not in a Bubble. This prevents the user from opening a Bubble from a Bubble:

```dart
if (!bubbles.isInBubble)
  IconButton(
    icon: const Icon(Icons.open_in_new),
    onPressed: () =>
        bubbles.show(widget.contact, '', shouldAutoExpand: true),
  ),
```

6. If the Flutter app is running, stop it and run it again. Otherwise, just still run the app with these new changes. Send a message to any animal and minimize the app. Tap the notification to open the app from the Bubble. The app should open to the ChatScreen of the animal the message was sent to. Try to navigate back to the HomeScreen from the ChatScreen. The bubble should simply close. Also notice that the AppBar back button and the "Open In New" icon for showing a bubble in the AppBar are not shown in the Bubble view.
