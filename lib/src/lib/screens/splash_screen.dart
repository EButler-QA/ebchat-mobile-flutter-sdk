import 'dart:async';
import 'package:ebchat/ebchat.dart';
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
  Route get route => MaterialPageRoute(
        builder: (context) => SplashScreen(
            companyLogo: companyLogo,
            initialMessage: initialMessage,
            ebchatKey: ebchatKey),
      );
  const SplashScreen(
      {Key? key,
      required this.ebchatKey,
      required this.companyLogo,
      required this.initialMessage})
      : super(key: key);
  final String ebchatKey;
  final String companyLogo;
  final String? initialMessage;

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

  Future<void> logout() async {
    final EBchatProvider eBchatProvider = context.read<EBchatProvider>();
    final StreamChatCoreState streamChatCore = StreamChatCore.of(context);
    if (eBchatProvider.globalChannel != null) {
      eBchatProvider.globalChannel!.dispose();
      eBchatProvider.setChannel(null, mounted);
    }

    await streamChatCore.client.disconnectUser();
    streamChatCore.dispose();
  }

  @override
  void dispose() {
    subscription?.cancel();
    // any other disposing actions
    super.dispose();
  }

  StreamSubscription<bool> listenDataFreez() {
    return context
        .read<EBchatProvider>()
        .globalChannel!
        .frozenStream
        .listen((data) async {
      if (data) {
        if (mounted) {
          setState(() {
            loading = true;
          });
        }

        initalIndex = 1;
        selectedIndex = 1;
        Config.virtualIntrest = "";
        await context
            .read<EBchatProvider>()
            .findAlfredChannel(context, mounted);
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
    super.initState();
    client = StreamChatCore.of(context).client;
    initApp();
  }

  void initApp() async {
    final StreamChatCoreState streamChatCore = StreamChatCore.of(context);
    final EBchatProvider eBchatProvider = context.read<EBchatProvider>();
    final client = streamChatCore.client;

    if (streamChatCore.currentUser == null) {
      loading = true;
      await client.connectUserWithProvider(
        eBchatProvider.currentUser!,
        (_) => eBchatProvider.getStreamUserToken(
          eBchatProvider.currentUser!.id,
          widget.ebchatKey,
        ),
      );
    }
    if (eBchatProvider.globalChannel == null) {
      await eBchatProvider.findAlfredChannel(context, false);
      setState(() {
        loading = false;
        channelId = eBchatProvider.globalChannel!.id;
      });
    }

    eBchatProvider.globalChannel!.frozenStream.listen((data) async {
      if (data) {
        await eBchatProvider.findAlfredChannel(context, mounted);
        setState(() {
          channelId = eBchatProvider.globalChannel!.id;
        });
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
        : Center(
            child: EbutlerProgress(companyLogo: widget.companyLogo),
          );
  }

  Widget _buildScreen(index) {
    switch (index) {
      case 0:
        return ChatPageUser(
          initialMessage: widget.initialMessage,
        );

      case 1:
        return HomeScreenUser(
          navigate,
        );
    }

    return Center(
      child: EbutlerProgress(companyLogo: widget.companyLogo),
    );
  }
}
