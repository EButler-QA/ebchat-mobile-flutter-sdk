import 'package:ebchat/src/lib/Theme/my_theme.dart';
import 'package:ebchat/src/lib/config/config.dart';
import 'package:ebchat/src/lib/providers/company_provider.dart';
import 'package:ebchat/src/lib/providers/navigator_provider.dart';
import 'package:ebchat/src/lib/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'lib/components/ebutler_progress.dart';

class EBChatWidget extends StatefulWidget {
  const EBChatWidget(
      {Key? key,
      required this.companyLogo,
      required this.ebchatToken,
      required this.client,
      required this.currentUser,
      this.azureMapsApiKey,
      this.arabicApp = false,
      this.initialMessage})
      : super(key: key);

  /// Company Logo To Be Displayed in SPLASH
  /// if the companyLogo == 'default' means the Blue Mustache
  final String companyLogo;

  ///EBCHAT company Token
  final String ebchatToken;

  ///GetStream Client
  final StreamChatClient? client;

  ///GetStream User
  final User currentUser;

  ///Display the app in arabic
  final bool arabicApp;

  //Your azure maps key
  final String? azureMapsApiKey;

  //Initial Message Related to BotFlow ( To be sent automatically)
  final String? initialMessage;

  @override
  State<EBChatWidget> createState() => _EBChatScreenState();
}

class _EBChatScreenState extends State<EBChatWidget> {
  final AppTheme appTheme = AppTheme();
  bool moduleInitalized = false;

  Future<void> initPackage(BuildContext mcontext) async {
    final EBchatProvider eBchatProvider = mcontext.read<EBchatProvider>();
    final CompanyProvider companyProvider = mcontext.read<CompanyProvider>();
    Config.setConfig(widget.arabicApp, widget.azureMapsApiKey);
    companyProvider.setCompany(mounted);
    eBchatProvider.setCurrentUser(widget.currentUser, mounted);
    await loadTextString();
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
      child: Builder(
        builder: (context) {
          return FutureBuilder(
            future: initPackage(context),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Center(
                    child: EbutlerProgress(companyLogo: widget.companyLogo),
                  );
                default:
                  return SplashScreen(
                      companyLogo: widget.companyLogo,
                      initialMessage: widget.initialMessage,
                      ebchatKey: widget.ebchatToken);
              }
            },
          );
        },
      ),
    );
  }
}
