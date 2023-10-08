import 'package:ebchat/src/lib/providers/navigator_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ebchat/src/lib/Theme/my_theme.dart';
import 'package:ebchat/src/lib/config/config.dart';
import 'package:ebchat/src/lib/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import '../widgets/ripple_animation.dart';
import 'closed_channels_list_page.dart';

class HomeScreenUser extends StatefulWidget {
  HomeScreenUser(this.navigate, {Key? key}) : super(key: key);

  void Function(int index) navigate;

  @override
  State<HomeScreenUser> createState() => _HomeScreenUserState();
}

class _HomeScreenUserState extends State<HomeScreenUser> {
  @override
  void initState() {
    StreamChat.of(context)
        .client
        .on(
          EventType.messageNew,
          EventType.notificationMessageNew,
        )
        .listen((event) {
      if (![
        EventType.messageNew,
        EventType.notificationMessageNew,
      ].contains(event.type)) {
        return;
      }
      if (event.message == null) return;
      if (mounted) setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Config.textDirection,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0.0),
                  topRight: Radius.circular(0.0),
                  bottomRight: Radius.circular(30.0),
                  bottomLeft: Radius.circular(30.0),
                ),
                shape: BoxShape.rectangle,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${getTranslated("Hello")}${StreamChatCore.of(context).currentUser!.name.length < 15 ? " ${StreamChatCore.of(context).currentUser!.name}" : ""} !",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 24,
                          color: Colors.white),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Provider.of<NavigatorProvider>(context).globalChannel !=
                            null
                        ? StreamChannel(
                            channel: Provider.of<NavigatorProvider>(context,
                                    listen: false)
                                .globalChannel!,
                            child: ElevatedButton(
                              onPressed: () async {
                                widget.navigate(0);
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.white,
                                onPrimary: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: SizedBox(
                                  width: double.infinity,
                                  height: 55,
                                  child: Center(
                                      child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Provider.of<NavigatorProvider>(context,
                                                      listen: false)
                                                  .globalChannel
                                                  ?.state
                                                  ?.messages
                                                  .length ==
                                              1
                                          ? Text(
                                              getTranslated(
                                                  "Start conversation"),
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15,
                                                  color: AppColors.primary),
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                  package: "ebchat",
                                                  "assets/play.png",
                                                ),
                                                const SizedBox(
                                                  width: 14,
                                                ),
                                                Text(
                                                  getTranslated(
                                                      "Continue Conversation"),
                                                  style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 15,
                                                      color: AppColors.primary),
                                                ),
                                              ],
                                            ),
                                      if (Provider.of<NavigatorProvider>(
                                                  context,
                                                  listen: false)
                                              .globalChannel!
                                              .state!
                                              .unreadCount >
                                          0)
                                        SizedBox(
                                          height: 30,
                                          child: CircleAvatar(
                                            backgroundColor: Colors.red,
                                            child: Padding(
                                              padding: const EdgeInsets.all(3),
                                              child: Text(
                                                '${Provider.of<NavigatorProvider>(context, listen: false).globalChannel!.state!.unreadCount}',
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ))),
                            ))
                        : const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextButton(
                        onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ClosedChannelsListPages()),
                            ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Color(0xFFDBDBDB),
                              size: 20,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              getTranslated("See previous messages"),
                              style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: const Color(0xFFDBDBDB),
                                  fontWeight: FontWeight.w400),
                            )
                          ],
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),
            const Spacer()
          ],
        ),
      ),
    );
  }
}
