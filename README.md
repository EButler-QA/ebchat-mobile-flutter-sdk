
# ebchat-mobile-flutter-sdk

![Pub](https://img.shields.io/badge/pub-v1.1.0+1-informational)
![Pub](https://img.shields.io/static/v1?label=EBchat-SDK&message=internal&color=red)

Flutter chat screen for EBChat Andorid and IOS projects.

- Uses Android SDK Version `12.5.1`.
- The minimum Android SDK `minSdkVersion` required is 21.
- Uses iOS SDK Version `13.0.0`.
- The minimum iOS target version required is 13.

## MAJOR UPDATES

THIS IS AN INTERNAL PACKAGE FOR EBUTLER DEV TEAM:
-THIS PACKAGE CONTAINS MULTIPLE CLIENTS AND MULTIPLE CHANNELS

## Usage

Import `package:ebchat/ebchat.dart` and use the methods in `EBChatService` class.



main.dart:
```dart
import 'package:ebchat/ebchat.dart';
import 'package:flutter/material.dart';
import 'ebchat_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MyHomePage();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //CLIENT
  String initalEbchatKey =
      "Wjmn+fr/NU1NKz3jU6h/lv3ib8hlDmKou2GM2qRHlYQepFq4rzK9fTPdp1OSd8XKWe4LSFpJCfYCLcLQy1LWurKYd3V9bZRWJ0Nby/uyF+HgOPjbY2N2L07wfckTYsHV3xkuMQxJ3tE8QAYp3SmE2OhH/zuj8bwtLOanXSd/XJk=";
  StreamChatClient? ebchatClient;

  Future<void> connectEBchatClient(
    String? ebchatKey,
  ) async {
    if (ebchatClient != null) {
      EBChatService.disposeEbchatClient();
    }
    ebchatClient = await EBChatService.getWebsocketClient(ebchatKey!);
    setState(() {
      ebchatClient;
    });
    return;
  }

  @override
  void didChangeDependencies() async {
    connectEBchatClient(initalEbchatKey);
    super.didChangeDependencies();
  }

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
                    String ebchatKey1 = initalEbchatKey;
                    await connectEBchatClient(ebchatKey1);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EbChatScreen(
                                ebchatClient: ebchatClient,
                                currentEbchatKey: ebchatKey1)));
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
                        Text("ABRAJ BAY RECEPTION ",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 13))
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    String ebchatKey2 =
                        "WZPQkSPP37RhgdNcvKPd3Z65YQh90QQkMcyyRlaatrfy9P8UN0lXupX96cwt/N3jDrq/ghOQz7wUjhjE39WxRO0gbeJuKC6XjFHgGXLMbfQPtNeYvlYcj6wC7IEWfTr4SmIGTqBIESF7vkuB7QAs21DVpXM1BhlvYkmYagtXoVs=";
                    await connectEBchatClient(ebchatKey2);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EbChatScreen(
                                ebchatClient: ebchatClient,
                                currentEbchatKey: ebchatKey2)));
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
                        Text("ABRAJ BAY SPA",
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
  EbChatScreen(
      {Key? key, required this.ebchatClient, required this.currentEbchatKey})
      : super(key: key);
  StreamChatClient? ebchatClient;
  String currentEbchatKey;
  @override
  State<EbChatScreen> createState() => _EbChatScreenState();
}

class _EbChatScreenState extends State<EbChatScreen> {
  User? currentUser;
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
    widget.ebchatClient!
        .on(
      EventType.messageNew,
      EventType.notificationMessageNew,
    )
        .listen((event) {
      showNotifcation(event, context);
    });

    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: const Color(0xff214496),
      ),
      body: widget.ebchatClient != null
          ? EBChatWidget(
              key: const Key("johnnyTEST"),
              ebchatToken: widget.currentEbchatKey,
              client: widget.ebchatClient!,
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
