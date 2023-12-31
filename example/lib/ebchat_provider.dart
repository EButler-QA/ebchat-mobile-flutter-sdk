import 'package:ebchat/ebchat.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class EbchatProvider with ChangeNotifier {
  String ebchatKey = "ebchatkey";
  StreamChatClient? ebchatClient;
  User? currentConnectedUser;
  String? currentSelectedEbchatKey;
  bool isEBChatOpened = false;
  bool failedtoloadStream = false;

  Future<void> setEbchatUser(User user) async {
    currentConnectedUser = user;
  }

  Future<void> getEbchatClient(String selectedEbchatKey) async {
    try {
      if (currentSelectedEbchatKey != selectedEbchatKey ||
          ebchatClient == null) {
        if (ebchatClient != null) {
          await EBChatService.disposeEbchatClient(
              disposeCompany: true, disposeUser: false);
        }
        ebchatClient =
            await EBChatService.getWebsocketClient(selectedEbchatKey);
      }
      currentSelectedEbchatKey = selectedEbchatKey;
    } catch (e) {
      print(e);
    }

    if (ebchatClient == null) {
      failedtoloadStream = true;
      print("failedtoloadStream");
    }
    notifyListeners();
  }

  Future<void> connectUserToEbchat(
      BuildContext context, String eButlerEBChatKey) async {
    if (ebchatClient == null) return;
    if (currentConnectedUser == null) return;
    try {
      print('get Stream Token');
      String getStreamToken = await ChatSerivice.getStreamUserToken(
          currentConnectedUser!.id, eButlerEBChatKey);

      await ebchatClient!.connectUser(currentConnectedUser!, getStreamToken);
    } catch (e) {
      // Handle exception if connectUser fails
      print('Error connecting user: $e');
      return;
    }

    await setAppToken();
    print('saved app device token to ebchat backend');
    ebchatClient!
        .on(
      EventType.messageNew,
      EventType.notificationMessageNew,
    )
        .listen((event) {
      if (event.message == null) return;
    });
  }

  Future<void> setAppToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;
    await ebchatClient!.addDevice(token, PushProvider.firebase,
        pushProviderName: "yourCompanyIdentifier");
  }

  Future<void> handlStreamNotification(
      BuildContext context, String channelId) async {
    if (isEBChatOpened) return;

    if (ebchatClient == null) {
      //INFO: Here we just need to connect with stream to know wich channel we are talking about
      await getEbchatClient(currentSelectedEbchatKey ?? ebchatKey);
    }

    //INFO: here we will try to navigate to know which company this channel came from
    final channelOfTheMessageNotification =
        ebchatClient!.channel('messaging', id: channelId);
    await channelOfTheMessageNotification.watch();
    final String? companyID =
        channelOfTheMessageNotification.extraData['companyID'] as String?;
    if (companyID == null) {
      print("companyId not detected");
      return;
    }
    if (companyID == "companyId" && currentSelectedEbchatKey != ebchatKey) {
      await getEbchatClient(ebchatKey);
    }
    isEBChatOpened = true;
    //INFO: you can return this if you need it in the app, it's not needed in the exemple
    /* Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => EBChatScreen(
        eButlerEBChatKey: currentSelectedEbchatKey!,
      ),
    ));*/

    notifyListeners();
  }

  void navigateEbchat(bool newState) {
    isEBChatOpened = newState;
    notifyListeners();
  }
}
