### README Documentation for `ebchat` Package

#### Overview
`ebchat` is a comprehensive Dart package for Flutter, designed to seamlessly integrate chat functionalities into your mobile applications. Leveraging Firebase's robust backend, it offers a real-time chat experience, complete with customizable UI components.

#### Features
- **Real-Time Chat:** Engage in instant messaging with real-time updates.
- **Firebase Integration:** Leverage the reliability and scalability of Firebase.
- **Customizable UI:** Tailor the chat interface to match your app's design.
- **Cross-Platform Support:** Compatible with both Android and iOS.

#### Prerequisites
- Flutter environment set up.
- A Firebase project for your app.
  
#### Installation
1. **Add `ebchat` to Your Project:**
   Edit your `pubspec.yaml`:
   ```yaml
   dependencies:
     ebchat: ^latest_version
   ```

2. **Install the Package:**
   ```bash
   flutter pub get
   ```

#### Firebase Setup
1. **Configure Firebase:**
   - Follow the [Firebase Flutter setup guide](https://firebase.google.com/docs/flutter/setup) to configure Firebase for your Flutter app.
   - Download your Firebase configuration files (`google-services.json` for Android and `GoogleService-Info.plist` for iOS) and add them to your project.

2. **Initialize Firebase:**
   In your main Dart file, initialize Firebase:
   ```dart
   import 'package:firebase_core/firebase_core.dart';
   import 'firebase_options.dart'; // Your Firebase configuration

   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp(
       options: DefaultFirebaseOptions.currentPlatform,
     );
     runApp(MyApp());
   }
   ```

#### Integration Steps
1. **Import `ebchat`:**
   ```dart
   import 'package:ebchat/ebchat.dart';
   ```

2. **Implement Chat Screen:**
   Create a screen to display the chat:
   ```dart
   class ChatScreen extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       return Scaffold(
         appBar: AppBar(
           title: Text('Chat'),
         ),
         body: EbChatScreen(),
       );
     }
   }
   ```

3. **Customize Chat UI:**
   Utilize `AsyncButtonWidget` and other UI components from `ebchat` to customize your chat interface.

#### Example Usage
Here's a complete example of a Flutter app using `ebchat`:
```dart
import 'package:flutter/material.dart';
import 'package:ebchat/ebchat.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyChatApp());
}

class MyChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EbChat Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: EbChatScreen(),
    );
  }
}
```

#### Contributing
We welcome contributions to `ebchat`. For guidelines on contributing, please refer to our contributing document.


