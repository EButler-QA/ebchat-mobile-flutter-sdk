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
  const EBChatWidget({
    Key? key,
    required this.ebchatToken,
    required this.client,
    required this.currentUser,
    this.azureMapsApiKey,
    this.arabicApp = false,
  }) : super(key: key);

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

  @override
  _EBChatScreenState createState() => _EBChatScreenState();
}

class _EBChatScreenState extends State<EBChatWidget> {
  final AppTheme appTheme = AppTheme();
  bool moduleInitalized = false;
  Future<void> initPackage(BuildContext mcontext) async {
    CompanyProvider companyProvider =
        Provider.of<CompanyProvider>(mcontext, listen: false);
    NavigatorProvider eBchatProvider =
        Provider.of<NavigatorProvider>(mcontext, listen: false);
    Config.setConfig(widget.arabicApp, widget.azureMapsApiKey);
    await loadTextString();
    companyProvider.setCompany(mounted);
    eBchatProvider.setCurrentUser(widget.currentUser, mounted);
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
          create: (gContext) => NavigatorProvider(),
        ),
        ChangeNotifierProvider(
          create: (gContext) => CompanyProvider(),
        ),
      ],
      child: Builder(builder: (context) {
        return FutureBuilder(
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
            });
      }),
    );
  }
}
