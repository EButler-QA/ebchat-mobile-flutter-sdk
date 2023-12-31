import 'dart:developer';

import 'package:ebchat/ebchat.dart';
import 'package:ebchat/src/lib/Theme/my_theme.dart';
import 'package:ebchat/src/lib/config/config.dart';
import 'package:ebchat/src/lib/pages/closed_channel_page.dart';
import 'package:ebchat/src/lib/widgets/display_error_message.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClosedChannelsListPages extends StatefulWidget {
  const ClosedChannelsListPages({Key? key}) : super(key: key);

  @override
  State<ClosedChannelsListPages> createState() =>
      _ClosedChannelsListPagesState();
}

String getDate(DateTime createdAt) {
  String date = "";
  final lastMessageAt = createdAt.toLocal();

  final now = DateTime.now();

  final startOfDay = DateTime(now.year, now.month, now.day);

  if (lastMessageAt.millisecondsSinceEpoch >=
      startOfDay.millisecondsSinceEpoch) {
    date = Jiffy.parseFromDateTime(lastMessageAt.toLocal()).jm;
  } else if (lastMessageAt.millisecondsSinceEpoch >=
      startOfDay.subtract(const Duration(days: 1)).millisecondsSinceEpoch) {
    date = 'Yesterday';
  } else if (startOfDay.difference(lastMessageAt).inDays < 7) {
    date = Jiffy.parseFromDateTime(lastMessageAt.toLocal()).EEEE;
  } else if (startOfDay.year - lastMessageAt.year <= 1) {
    date = Jiffy.parseFromDateTime(lastMessageAt.toLocal()).MMMd;
  } else {
    date = Jiffy.parseFromDateTime(lastMessageAt.toLocal()).yMd;
  }
  return date;
}

class _ClosedChannelsListPagesState extends State<ClosedChannelsListPages> {
  late final StreamChannelListController _streamChannelListController;
  @override
  void initState() {
    super.initState();
    _streamChannelListController = StreamChannelListController(
      client: EBChatService.client!,
      filter: Filter.and(
        [
          Filter.equal('type', 'messaging'),
          Filter.or([
            Filter.exists("intercom"),
            Filter.equal('frozen', true),
          ]),
          Filter.in_('members', [StreamChatCore.of(context).currentUser!.id])
        ],
      ),
      channelStateSort: const [SortOption('last_message_at')],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Text(
              getTranslated("History"),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 9),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8F8F8),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                  bottomRight: Radius.circular(0.0),
                  bottomLeft: Radius.circular(0.0),
                ),
                shape: BoxShape.rectangle,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 40,
                    ),
                    Expanded(
                      child: StreamChannelListView(
                        controller: _streamChannelListController,
                        // TODO: Check where is pull to refresh
                        itemBuilder: (context, channels, index, listTile) {
                          Channel channel = channels[index];
                          return InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClosedChannelPage(
                                  channel: channel,
                                ),
                              ),
                            ),
                            child: Card(
                              color: const Color(0xFFE1E1E1),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CircleAvatar(
                                      radius: 19,
                                      backgroundImage: const AssetImage(
                                        package: "ebchat",
                                        "assets/alfred.png",
                                      ),
                                      backgroundColor:
                                          Theme.of(context).cardColor,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Alfred",
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                          color: const Color(0xFF7B7B7B),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            channel.state!.lastMessage!.text!
                                                        .trimRight()
                                                        .length >
                                                    20
                                                ? "${channel.state!.lastMessage!.text!.substring(0, 16)} ..."
                                                : channel
                                                    .state!.lastMessage!.text!
                                                    .trimRight(),
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 13,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            ".${getDate(channel.state!.lastMessage!.createdAt)}",
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 11,
                                              color: const Color(0xFF838383),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                        emptyBuilder: (context) => Center(
                          child: Text(
                            getTranslated(
                              "No previous conversation. Send us a message",
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        errorBuilder: (context, error) {
                          log("Error", error: error);
                          return DisplayErrorMessage(
                            error: error,
                          );
                        },
                        loadingBuilder: (
                          context,
                        ) =>
                            const Center(
                          child: SizedBox(
                            height: 100,
                            width: 100,
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
