import 'package:ebchat/ebchat.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test/components/asyncButtonWidget.dart';
import 'package:test/ebchat_provider.dart';
import 'package:test/ebchat_screen.dart';
import 'package:test/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initNotifications();

  final ebchatProvider = EbchatProvider();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<EbchatProvider>(
        create: (context) => ebchatProvider,
      ),
    ],
    child: const MyApp(),
  ));
}

initNotifications() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');
    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print(message);
    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MyHomePage();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    context
        .read<EbchatProvider>()
        .setEbchatUser(User(id: "john", name: "jack", extraData: const {
          //TODO: THIS FIELD IS REQUIRED
          "email": "johnjack@ebchat.com",
          //TODO: you can store your user extrats attribute
          "phone": "9741111111",
        }));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EBCHAT Widget DEMO',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EBChatScreen(
          key: ValueKey(context.read<EbchatProvider>().ebchatKey),
          eButlerEBChatKey: context.read<EbchatProvider>().ebchatKey),
      builder: (context, child) {
        return Scaffold(
          body: context.watch<EbchatProvider>().ebchatClient != null &&
                  context.watch<EbchatProvider>().isEBChatOpened
              ? StreamChat(
                  client: context.read<EbchatProvider>().ebchatClient!,
                  streamChatThemeData: StreamChatThemeData(
                    messageListViewTheme: const StreamMessageListViewThemeData(
                      backgroundColor: Colors.white,
                    ),
                    channelHeaderTheme: const StreamChannelHeaderThemeData(
                      color: Color(0xFFF8F8F8),
                    ),
                  ),
                  child: child)
              : buildButtons(context),
        );
      },
    );
  }

  Widget buildButtons(BuildContext context) {
    return Builder(
      builder: (BuildContext innerContext) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AsyncButtonWidget(
                chatKey: context.read<EbchatProvider>().ebchatKey,
                buttonText: "Your company"),
            const SizedBox(height: 10),
            const AsyncButtonWidget(
                channelId: "thechannelId", buttonText: "Detect by channel"),
          ],
        );
      },
    );
  }
}
