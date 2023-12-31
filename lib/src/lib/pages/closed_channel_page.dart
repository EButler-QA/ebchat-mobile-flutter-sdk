import 'package:ebchat/src/lib/Theme/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:ebchat/src/lib/config/config.dart';
import 'package:ebchat/src/lib/widgets/audio_loading_message.dart';
import 'package:ebchat/src/lib/widgets/audio_play_message.dart';
import 'package:ebchat/src/lib/widgets/avatar.dart';
import 'package:ebchat/src/lib/widgets/getStream/custom_message_listview.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ClosedChannelPage extends StatelessWidget {
  const ClosedChannelPage({
    key,
    required this.channel,
  }) : super(key: key);
  final Channel? channel;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamChannel(
              channel: channel!,
              child: CustomMessageListView(
                adminPrivilege: false,
                messageBuilder: (context, details, messages, defaultMessage) {
                  return defaultMessage.copyWith(
                    customAttachmentBuilders: {
                      'voicenote': (context, defaultMessage, attachments) {
                        final url = attachments.first.assetUrl;
                        if (url == null) {
                          return const AudioLoadingMessage();
                        }
                        return AudioPlayerMessage(
                          source: AudioSource.uri(Uri.parse(url)),
                          fileSize: attachments.first.mimeType == "video/webm"
                              ? attachments.first.fileSize!
                              : 0,
                        );
                      }
                    },
                    userAvatarBuilder: (p0, p1) {
                      if (p1.id == Config.alfredId) {
                        return CircleAvatar(
                          radius: 18,
                          backgroundImage: const AssetImage(
                            package: "ebchat",
                            "assets/alfred.png",
                          ),
                          backgroundColor: Theme.of(context).cardColor,
                        );
                      }
                      return Avatar.small(
                        user: p1,
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Colors.black,
                    size: 25,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    getTranslated("this channel is closed"),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: const Color(0xFF5A5A5A),
                    ),
                  ),
                  const SizedBox(
                    height: 23,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: Center(
                        child: Text(
                          getTranslated("Start conversation"),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
