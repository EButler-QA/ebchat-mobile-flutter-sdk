
# ebchat-mobile-flutter-sdk

![Pub](https://img.shields.io/badge/pub-v1.0.0+1-informational)

Flutter chat screen for EBChat Andorid and IOS projects.

- Uses Android SDK Version `12.5.1`.
- The minimum Android SDK `minSdkVersion` required is 21.
- Uses iOS SDK Version `13.0.0`.
- The minimum iOS target version required is 13.

## MAJOR UPDATES

New major version update: 1.0.1+1

## Usage

Import `package:ebchat/ebchat.dart` and use the methods in `EBChatService` class.



main.dart:
```dart
import 'package:ebchat/ebchat.dart';
import 'package:flutter/material.dart';
import 'ebchat_screen.dart';

void main() async {
  String ebchatKey =
      "EBCHATKEY";
  StreamChatClient? ebchatClient= await EBChatService.getWebsocketClient(ebchatKey);
  runApp(MyApp(ebchatClient: ebchatClient));
}

class MyApp extends StatelessWidget {
  MyApp({Key? key, required this.ebchatClient}) : super(key: key);
  StreamChatClient? ebchatClient;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EBCHAT Widget DEMO',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      builder: (context, child) {
        return Scaffold(
          body: ebchatClient != null
              ? StreamChat(
                  client: ebchatClient!,
                  streamChatThemeData: StreamChatThemeData(
                    messageListViewTheme: const StreamMessageListViewThemeData(
                      backgroundColor: Color(0xFFF8F8F8),
                    ),
                    channelListViewTheme: const StreamChannelListViewThemeData(
                      backgroundColor: Color(0xFFF8F8F8),
                    ),
                  ),
                  child: child,
                )
              : const Center(
                  child: Text("Please double check you EBCHATKEY"),
                ),
        );
      },
      home: Builder(builder: (context) {
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
  StreamChatClient? ebchatClient;
  User? currentUser;
  String ebchatKey = "EBCHATKEY";

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
    ebchatClient = await EBChatService.getWebsocketClient(ebchatKey);
    ebchatClient!
        .on(
      EventType.messageNew,
      EventType.notificationMessageNew,
    )
        .listen((event) {
      showNotifcation(event, context);
    });
    if (mounted) {
      setState(() {
        ebchatClient;
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
      body: ebchatClient != null
          ? EBChatWidget(
              key: const Key("johnnyTEST"),
              ebchatToken: ebchatKey,
              client: ebchatClient!,
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

  @override
  void dispose() {
    EBChatService.disposeEbchatClient();
    super.dispose();
  }
}

```
## IMPORTANT NOTES
1) If you have initialized "ebchatClient", you can call the method "EBChatService.getWebsocketClient(ebchatKey);" anywhere in your code to call the ebchatClient.
2) Don't forget to dispose "ebchatClient" when you disconnect.

```dart
 @override
  void dispose() {
    EBChatService.disposeEbchatClient();
    super.dispose();
  }
```
