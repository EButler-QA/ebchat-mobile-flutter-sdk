
# ebchat-mobile-flutter-sdk

![Pub](https://img.shields.io/badge/pub-v3.0.0+1-informational)

Flutter chat screen for EBChat Andorid and IOS projects.

- Uses Android SDK Version `12.5.1`.
- The minimum Android SDK `minSdkVersion` required is 21.
- Uses iOS SDK Version `13.0.0`.
- The minimum iOS target version required is 13.

## Permission

Files, camera and micro must be inculded in the package. If you wich to allow your users to send their current location ask for location permission also

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
  String initalEbchatKey = "EBCHATKEY";
  StreamChatClient? ebchatClient;
  @override
  void didChangeDependencies() async {
    connectEBchatClient(initalEbchatKey);
    super.didChangeDependencies();
  }

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
                  onPressed: () => connectEBchatClient(initalEbchatKey).then(
                    (value) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EbChatScreen(
                            ebchatClient: ebchatClient,
                            currentEbchatKey: initalEbchatKey),
                      ),
                    ),
                  ),
                  child: SizedBox(
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.chat),
                        SizedBox(
                          width: 7,
                        ),
                        Text("EBCHAT WIDGET",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 13))
                      ],
                    ),
                  ),
                ),
              ),
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
  //VAR FOR NOTIFICATIONS
  bool isFlutterLocalNotificationsInitialized = false;
  var flutterLocalNotificationsPlugin;

  @override
  void initState() {
    initilizeClient();

    ///IF YOU ARE USING FIREBASE TO HANDLE NOTIFICATION
    ///
    ///initializeFirebaseNotification();
    ///
    super.initState();
  }

  Future<void> initilizeClient() async {
    //TODO: THIS is an example how to access the stream and the client anywhere in the code
    StreamChatCoreState ebchatStream = StreamChatCore.of(context);
    currentUser = User(id: "johnnyTEST", name: "john", extraData: const {
      //TODO: THIS FIELD IS REQUIRED
      "email": "john@john.com",
      //TODO: you can store your user extrat attribute
      "phone": "+9743333333",
    });
    String getStreamToken = await ChatSerivice.getStreamUserToken(
        currentUser!.id, widget.currentEbchatKey);

    await ebchatStream.client.connectUser(
      User(id: currentUser!.id),
      getStreamToken,
    );
    ebchatStream.client
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
      body: widget.ebchatClient != null && currentUser != null
          ? EBChatWidget(
              key: Key(currentUser!.id),
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

  //HANDLE NOTIFICATION

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

## IMPORTANT NOTES
1) Handle notification using firebase
```dart
 void initializeFirebaseNotification() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await setupLocalNotifications();
    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    setAppToken(messaging).then((value) => messageListener(context));
  }

  Future<void> setAppToken(FirebaseMessaging messaging) async {
    String? token;
    token = await messaging.getToken();
    if (token != null) {
      await widget.ebchatClient!.addDevice(token, PushProvider.firebase);
    }
  }

  void messageListener(BuildContext context) {
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        handleNotification(message, widget.ebchatClient!);
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen(onBackgroundMessageForMobile);
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessageForMobile);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      Map<String, dynamic> data = message.data;
      if (data.containsKey('stream')) {
        data = Map<String, dynamic>.from(data["stream"]);
      }
      String? messageId = data['messageId'];

      if (messageId != null) {
        handleNotification(message, widget.ebchatClient!);
      }
    });
  }

  void handleNotification(
    RemoteMessage message,
    StreamChatClient chatClient,
  ) async {
    Map<String, dynamic> data = message.data;
    if (data.containsKey('stream')) {
      data = Map<String, dynamic>.from(data["stream"]);
    }
    if (data['type'] == 'message.new') {
      final messageId = data['id'];
      final response = await chatClient.getMessage(messageId);

      Channel channel =
          chatClient.channel("messaging", id: response.channel!.id);
      await channel.watch();
      flutterLocalNotificationsPlugin.show(
        generateUniqueRoomChatId(response.channel!.id),
        'New message from ${response.message.user!.name}',
        response.message.text,
        const NotificationDetails(
            android: AndroidNotificationDetails(
          'new_message',
          'New message notifications channel',
        )),
      );
    }
  }

  Future<void> setupLocalNotifications() async {
    if (isFlutterLocalNotificationsInitialized) {
      return;
    }
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (payload) {},
    );
    isFlutterLocalNotificationsInitialized = true;
  }

  Future<void> onBackgroundMessageForMobile(RemoteMessage? message) async {
    //TODO: We suggest to store this key. This key is very important 
    String? get_stream_ebchat_key=ChatSerivice.getEBchatWebSocket();
    if(get_stream_ebchat_key!=null && get_stream_ebchat_key!="")
    {final chatClient = StreamChatClient(get_stream_ebchat_key);
    //TODO: don't forget to store user id and token so you could connect him when reciving a background notification
    List<String> infos = await Config.getInfoFromSharedPref();
    if (infos[0].isNotEmpty) {
      await chatClient.connectUser(
        User(id: infos[0]),
        infos[1],
      );
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      await setupLocalNotifications();
      handleNotification(message, chatClient);
    }}
  }

  void onDidReceiveLocalNotification(
      int? id, String? title, String? body, String? payload) async {
    // display a dialog with the notification details, tap ok to go to another page
  }

  int generateUniqueRoomChatId(String? a) {
    int length = a!.length;
    String? k = "";
    for (int x = 0; x < length - 1; x++) {
      if (int.tryParse(a[x].toString()) == null) {
        k = k! + a.codeUnitAt(x).toString();
      } else {
        k = k! + a[x].toString();
      }
    }
    return int.parse(k!.substring(1, 9));
  }
```
2) Dispose or disconnect when logging out

```dart
//TODO: to dispose the client when you are done
  @override
  void dispose() {
     if (widget.ebchatClient != null) {
      StreamChatCore.of(context).client.disconnectUser().then((value) {
        widget.ebchatClient!.dispose();
        StreamChatCore.of(context).dispose();
        EBChatService.disposeEbchatClient();
      });
    }
    super.dispose();
  }
}
```
