import 'package:ebchat/src/lib/Theme/my_theme.dart';
import 'package:ebchat/src/lib/config/config.dart';
import 'package:ebchat/src/lib/providers/company_provider.dart';
import 'package:ebchat/src/lib/providers/navigator_provider.dart';
import 'package:ebchat/src/lib/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import 'lib/components/ebutler_progress.dart';

class EBChatScreen extends StatefulWidget {
  const EBChatScreen({
    Key? key,
    required this.ebchatToken,
    required this.client,
    required this.currentUser,
    this.arabicApp = false,
    this.rederictMessagesToEbutlerOperators = false,
  }) : super(key: key);

  ///EBCHAT company Token
  final String ebchatToken;

  ///GetStream Client
  final StreamChatClient? client;

  ///GetStream User
  final User currentUser;

  ///Display the app in arabic
  final bool arabicApp;

  ///If this value is set to true, the conversations and it's messages will be handled by EButler LifeStyle managers
  final bool rederictMessagesToEbutlerOperators;

  @override
  _EBChatScreenState createState() => _EBChatScreenState();
}

class _EBChatScreenState extends State<EBChatScreen> {
  final AppTheme appTheme = AppTheme();
  bool moduleInitalized = false;
  Future<void> initPackage(BuildContext mcontext) async {
    Config.setConfig(widget.arabicApp);
    await loadTextString();
    Provider.of<EBchatProvider>(mcontext, listen: false)
        .setRedirectToEbutler(widget.rederictMessagesToEbutlerOperators);
    await Provider.of<CompanyProvider>(mcontext, listen: false).setCompany(
        widget.ebchatToken, widget.rederictMessagesToEbutlerOperators);
    Provider.of<EBchatProvider>(mcontext, listen: false)
        .setCurrentUser(widget.currentUser, mounted);
    return;
  }

  @override
  Widget build(BuildContext gContext) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeModel(),
        ),
        ChangeNotifierProvider(
          create: (gContext) => EBchatProvider(),
        ),
        ChangeNotifierProvider(
          create: (gContext) => CompanyProvider(),
        ),
      ],
      child: Builder(builder: (context) {
        return widget.client != null
            ? StreamChat(
                client: widget.client!,
                streamChatThemeData: StreamChatThemeData(
                  messageListViewTheme: const StreamMessageListViewThemeData(
                    backgroundColor: Color(0xFFF8F8F8),
                  ),
                  channelListViewTheme: const StreamChannelListViewThemeData(
                    backgroundColor: Color(0xFFF8F8F8),
                  ),
                ),
                child: FutureBuilder(
                    future: initPackage(context),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return Center(
                            child: EbutlerProgress(),
                          );
                        default:
                          return const SplashScreen();
                      }
                    }),
              )
            : Center(
                child: EbutlerProgress(),
              );
      }),
    );
  }
}
