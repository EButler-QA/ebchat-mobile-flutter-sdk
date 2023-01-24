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
