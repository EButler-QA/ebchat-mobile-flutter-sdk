import 'dart:async';
import 'package:ebchat/src/lib/components/ebutler_progress.dart';
import 'package:ebchat/src/lib/config/config.dart';
import 'package:ebchat/src/lib/pages/chat_page_user.dart';
import 'package:ebchat/src/lib/pages/home_page_user.dart';
import 'package:ebchat/src/lib/providers/company_provider.dart';
import 'package:ebchat/src/lib/providers/navigator_provider.dart';
import 'package:ebchat/src/lib/services/chat_services.dart';
import 'package:flutter/material.dart';
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
  late StreamChatClient client;
  StreamSubscription<bool>? subscription;
  final ChatSerivice chatSerivice = ChatSerivice();

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
    super.initState();
  }

  @override
  void didChangeDependencies() {
    initApp();
    super.didChangeDependencies();
  }

  void initApp() async {
    final client = StreamChatCore.of(context).client;
    EBchatProvider eBchatProvider =
        Provider.of<EBchatProvider>(context, listen: false);
    if (StreamChatCore.of(context).currentUser == null) {
      loading = true;

      await Future.delayed(const Duration(seconds: 1));

      if (client.wsConnectionStatus == ConnectionStatus.disconnected) {
        await client
            .connectUserWithProvider(
                eBchatProvider.currentUser!,
                (_) => eBchatProvider.getStreamUserToken(
                    eBchatProvider.currentUser!.id,
                    Provider.of<CompanyProvider>(context, listen: false)
                        .company!
                        .ebchatkey!))
            .catchError(() => print(
                "LOG: EBChatChatLogger(message: User already getting connected)"));
      }
    }
    if (eBchatProvider.globalChannel == null) {
      await getUserOpenConversation();
    }
    setState(() {
      loading = false;
    });
    eBchatProvider.globalChannel!.frozenStream.listen((data) async {
      if (data) {
        await getUserOpenConversation();
      }
    });
  }

  Future<void> getUserOpenConversation() {
    return Provider.of<EBchatProvider>(context, listen: false)
        .findAlfredChannel(context);
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
        : Center(
            child: EbutlerProgress(),
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
    }

    return Center(
      child: EbutlerProgress(),
    );
  }
}
