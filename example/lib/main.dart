import 'package:ebchat/ebchat.dart';
import 'package:flutter/material.dart';
import 'ebchat_screen.dart';

void main() async {
  String ebchatKey =
      "ASgcRTmEWR7iMCVDO62iMFQFD+E1QieRIFdz5Piia8LDZw45Mg0rEZQPKeZKmE6Vl7eezfjYhATd0gnGoeo4c7E2Wbw1SmFGJWdlCnFkQF/ilQfXA2l4lXvtjK329NSvJoPPPLHwIva/wW27mARlSgb+rpFHjclLu3uk5gGxGFk=";
  StreamChatClient? ebchatClient =
      await EBChatService.getWebsocketClient(ebchatKey);
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
