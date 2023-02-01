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
