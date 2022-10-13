
# ebchat-mobile-flutter-sdk

![Pub](https://img.shields.io/badge/pub-v0.1.0+1-informational)

Flutter chat screen for EBChat Andorid and IOS projects.

- Uses Android SDK Version `12.5.1`.
- The minimum Android SDK `minSdkVersion` required is 21.
- Uses iOS SDK Version `13.0.0`.
- The minimum iOS target version required is 13.

## Usage

Import `package:ebchat/ebchat.dart` and use the methods in `EBChatService` class.

Example:
main.dart:
```dart
import 'package:flutter/material.dart';
import 'ebchat_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EBCHAT Widget DEMO',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: Builder(builder: (context) {
          return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EbChatScreen()));
                    },
                    child: SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.chat),
                          SizedBox(
                            width: 7,
                          ),
                          Text("Open Chat",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13))
                        ],
                      ),
                    ),
                  ),
                )
              ]);
        }),
      ),
    );
  }
}
```
ebchat_screen.dart:
```dart
import 'package:ebchat/ebchat.dart';
import 'package:flutter/material.dart';

class EbChatScreen extends StatefulWidget {
  const EbChatScreen({Key? key}) : super(key: key);
  @override
  State<EbChatScreen> createState() => _EbChatScreenState();
}

class _EbChatScreenState extends State<EbChatScreen> {
  StreamChatClient? client;
  User? currentUser;
  String ebchatKey ="EBCHATKEY";

  String azureMapsApiKey = "AZUREMAPSKEY";
  @override
  void initState() {
    initilizeClient();
    currentUser = User(id: "johnnyTEST", name: "john", extraData: {
      //TODO: THIS FIELD IS REQUIRED
      "email": "john@john.com",
      //TODO: you can store your user extrats attribute
      "phone": "3933557",
    });
    super.initState();
  }

  Future<void> initilizeClient() async {
    String key = await EBChatService.getCompanyStreamAcess(ebchatKey);
    client = StreamChatClient(key);
    client!
        .on(
      EventType.messageNew,
      EventType.notificationMessageNew,
    )
        .listen((event) {
      showNotifcation(event, context);
    });
    if (mounted) {
      setState(() {
        client;
      });
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: const Color(0xff214496),
      ),
      body: client != null
          ? EBChatWidget(
              key: const Key("johnnyTEST"),
              ebchatToken: ebchatKey,
              client: client!,
              currentUser: currentUser!,
              azureMapsApiKey: azureMapsApiKey,
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  void showNotifcation(Event event, BuildContext context) {
    if (![
      EventType.messageNew,
      EventType.notificationMessageNew,
    ].contains(event.type)) {
      return;
    }
    if (event.message == null) return;
    //TODO: add your logic to handle notifications
  }
}
```


