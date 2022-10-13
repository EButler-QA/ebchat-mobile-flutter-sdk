import 'dart:async';
import 'package:ebchat/src/lib/config/config.dart';
import 'package:ebchat/src/lib/pages/chat_page_user.dart';
import 'package:ebchat/src/lib/pages/home_page_user.dart';
import 'package:ebchat/src/lib/providers/company_provider.dart';
import 'package:ebchat/src/lib/providers/navigator_provider.dart';
import 'package:ebchat/src/lib/services/chat_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class SplashScreen extends StatefulWidget {
  static Route get route => MaterialPageRoute(
        builder: (context) => const SplashScreen(),
      );
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool fromNotif = false;
  bool fromCategorie = false;
  int initalIndex = 0;
  int selectedIndex = 0;
  bool loading = false;
  String? cancellation_message;
  String? service_rating;
  String? reschedule_booking;
  late StreamChatClient client;
  StreamSubscription<bool>? subscription;
  final ChatSerivice chatSerivice = ChatSerivice();
  Future<void> _receiveFromHost(MethodCall call) async {
    dynamic recievedDataFromHost = call.arguments;

    if (call.method != "logout") {
      if (recievedDataFromHost.containsKey("notif") &&
          recievedDataFromHost["notif"] == true) {
        setState(() {
          loading = true;
          fromNotif = true;
          initalIndex = 0;
          selectedIndex = 0;
        });
      } else if (recievedDataFromHost.containsKey("virtual_intrest")) {
        setState(() {
          Config.virtual_intrest = recievedDataFromHost["virtual_intrest"];
          initalIndex = 2;
          selectedIndex = 2;
          fromCategorie = true;
          loading = true;
        });
      } else if (recievedDataFromHost.containsKey("service_rating")) {
        setState(() {
          service_rating = recievedDataFromHost["service_rating"];
          initalIndex = 3;
          selectedIndex = 3;
          fromCategorie = true;
          loading = true;
        });
      } else if (recievedDataFromHost.containsKey("cancellation_message")) {
        setState(() {
          cancellation_message = recievedDataFromHost["cancellation_message"];
          initalIndex = 4;
          selectedIndex = 4;
          fromCategorie = true;
          loading = true;
        });
      } else if (recievedDataFromHost.containsKey("reschedule_booking")) {
        setState(() {
          reschedule_booking = recievedDataFromHost["reschedule_booking"];
          initalIndex = 5;
          selectedIndex = 5;
          fromCategorie = true;
          loading = true;
        });
      } else {
        setState(() {
          initalIndex = 1;
          selectedIndex = 1;
        });
      }

      if (recievedDataFromHost.containsKey("language")) {
        switch (recievedDataFromHost["language"]) {
          case "ar":
            if (Config.textDirection != TextDirection.rtl) {
              Config.textDirection = TextDirection.rtl;
            }

            break;
          default:
            if (Config.textDirection != TextDirection.ltr) {
              Config.textDirection = TextDirection.ltr;
            }
        }
        // await loadTextString();
      }
      if (StreamChatCore.of(context).currentUser == null) {
        await client.connectUser(
          User(id: recievedDataFromHost["id"]),
          recievedDataFromHost["token"],
        );
      }
      if (Provider.of<EBchatProvider>(context, listen: false).globalChannel ==
          null) {
        await Provider.of<EBchatProvider>(context, listen: false)
            .findAlfredChannel(context);
        subscription = listenDataFreez();
      }

      setState(() {
        loading = false;
        Config.textDirection;
        selectedIndex;
      });
    } else {
      await logout();
    }
  }

  Future<void> logout() async {
    if (Provider.of<EBchatProvider>(context, listen: false).globalChannel !=
        null) {
      Provider.of<EBchatProvider>(context, listen: false)
          .globalChannel!
          .dispose();
      Provider.of<EBchatProvider>(context, listen: false)
          .setChannel(null, mounted);
    }

    await StreamChatCore.of(context).client.disconnectUser();
    StreamChatCore.of(context).dispose();
  }

  StreamSubscription<bool> listenDataFreez() {
    return Provider.of<EBchatProvider>(context, listen: false)
        .globalChannel!
        .frozenStream
        .listen((data) async {
      if (data) {
        setState(() {
          loading = true;
        });

        initalIndex = 1;
        selectedIndex = 1;
        Config.virtual_intrest = "";
        await Provider.of<EBchatProvider>(context, listen: false)
            .findAlfredChannel(context);
        subscription!.cancel();
        subscription = null;

        subscription = listenDataFreez();
        setState(() {
          loading = false;
        });
      }
    });
  }

  @override
  void initState() {
    client = StreamChatCore.of(context).client;
    //Config.platform.setMethodCallHandler(_receiveFromHost);
    initApp();
    super.initState();
  }

  void initApp() async {
    final client = StreamChatCore.of(context).client;
    if (StreamChatCore.of(context).currentUser == null) {
      loading = true;
      await client.connectUserWithProvider(
          Provider.of<EBchatProvider>(context, listen: false).currentUser!,
          (_) => Provider.of<EBchatProvider>(context, listen: false)
              .getStreamUserToken(
                  Provider.of<EBchatProvider>(context, listen: false)
                      .currentUser!
                      .id,
                  Provider.of<CompanyProvider>(context, listen: false)
                      .company!
                      .ebchatkey!));
    }
    if (Provider.of<EBchatProvider>(context, listen: false).globalChannel ==
        null) {
      await Provider.of<EBchatProvider>(context, listen: false)
          .findAlfredChannel(context);
    }
    setState(() {
      loading = false;
    });
    Provider.of<EBchatProvider>(context, listen: false)
        .globalChannel!
        .frozenStream
        .listen((data) async {
      if (data) {
        await Provider.of<EBchatProvider>(context, listen: false)
            .findAlfredChannel(context);
      }
    });
  }

  void navigate(index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return !loading
        ? _buildScreen(selectedIndex)
        : const Center(
            child: CircularProgressIndicator(),
          );
  }

  Widget _buildScreen(index) {
    switch (index) {
      case 0:
        return ChatPageUser();

      case 1:
        return HomeScreenUser(
          navigate,
        );
      //selecting a categorie
      case 2:
        if (!Provider.of<EBchatProvider>(context, listen: false)
            .globalChannel!
            .extraData
            .containsKey("initiated")) {
          Provider.of<EBchatProvider>(context, listen: false)
              .globalChannel!
              .sendMessage(
                  Message(text: "/bot ${Config.virtual_intrest};0", extraData: {
                "lang": Config.textDirection == TextDirection.ltr ? "en" : "ar",
              }))
              .then((value) async {
            Provider.of<EBchatProvider>(context, listen: false)
                .globalChannel!
                .updatePartial(set: {"initiated": false});

            navigate(0);
          });
        } else {
          if (Provider.of<EBchatProvider>(context, listen: false)
                  .globalChannel!
                  .extraData["initiated"] ==
              true) {
            Provider.of<EBchatProvider>(context, listen: false)
                .globalChannel!
                .sendMessage(Message(
                  text: getTranslated("I would like to request : ") +
                      "\n ${Config.virtual_intrest}",
                ))
                .then((value) async {
              navigate(0);
            });
          } else {
            List<Message> messages =
                Provider.of<EBchatProvider>(context, listen: false)
                    .globalChannel!
                    .state!
                    .messages;
            Provider.of<EBchatProvider>(context, listen: false)
                .globalChannel!
                .sendMessage(Message(
                    text: "/bot ${Config.virtual_intrest};cancel",
                    extraData: {
                      "choiceSelected":
                          getTranslated("I would like to request : ") +
                              "\n ${Config.virtual_intrest}",
                      "lang": Config.textDirection == TextDirection.ltr
                          ? "en"
                          : "ar",
                      "alfredMsgId": messages
                          .lastWhere((element) => element.user!.id == "alfred")
                          .id
                    }))
                .then((value) async {
              navigate(0);
            });
          }
        }
        break;

      ///servicerating
      case 3:
        String rating = service_rating!.split(";").first;
        String bookinNumber = service_rating!.split(";").last;
        Provider.of<EBchatProvider>(context, listen: false)
            .globalChannel!
            .sendMessage(Message(text: "/bot servicerating;0", extraData: {
              "choiceSelected":
                  "I've rated $rating stars on this booking with ID:$bookinNumber",
              "lang": Config.textDirection == TextDirection.ltr ? "en" : "ar",
              "rating": rating,
              "bookinNumber": bookinNumber
            }))
            .then((value) async {
          if (!Provider.of<EBchatProvider>(context, listen: false)
              .globalChannel!
              .extraData
              .containsKey("initiated")) {
            Provider.of<EBchatProvider>(context, listen: false)
                .globalChannel!
                .updatePartial(set: {"initiated": true});
          }
          navigate(0);
        });

        break;
      //cancellingbooking
      case 4:
        Provider.of<EBchatProvider>(context, listen: false)
            .globalChannel!
            .sendMessage(Message(text: "/bot cancellingbooking;0", extraData: {
              "choiceSelected": cancellation_message,
              "cancellation_message": true,
              "lang": Config.textDirection == TextDirection.ltr ? "en" : "ar",
            }))
            .then((value) async {
          if (!Provider.of<EBchatProvider>(context, listen: false)
              .globalChannel!
              .extraData
              .containsKey("initiated")) {
            Provider.of<EBchatProvider>(context, listen: false)
                .globalChannel!
                .updatePartial(set: {"initiated": true});
          }
          navigate(0);
        });
        break;
      //reschedulebooking
      case 5:
        Provider.of<EBchatProvider>(context, listen: false)
            .globalChannel!
            .sendMessage(Message(text: "/bot reschedulebooking;0", extraData: {
              "choiceSelected": reschedule_booking,
              "reschedule_booking": true,
              "lang": Config.textDirection == TextDirection.ltr ? "en" : "ar",
            }))
            .then((value) async {
          if (!Provider.of<EBchatProvider>(context, listen: false)
              .globalChannel!
              .extraData
              .containsKey("initiated")) {
            Provider.of<EBchatProvider>(context, listen: false)
                .globalChannel!
                .updatePartial(set: {"initiated": true});
          }
          navigate(0);
        });
        break;
    }

    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
