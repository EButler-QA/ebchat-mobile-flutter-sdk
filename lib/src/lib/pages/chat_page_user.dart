import 'dart:async';
import 'dart:io';
import 'package:ebchat/src/lib/providers/company_provider.dart';
import 'package:ebchat/src/lib/providers/navigator_provider.dart';
import 'package:ebchat/src/lib/services/chat_services.dart';
import 'package:ebchat/src/lib/widgets/dialog/user_info_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';
import 'package:stream_chat_flutter/scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:ebchat/src/lib/Theme/my_theme.dart';
import 'package:ebchat/src/lib/config/config.dart' as cf;
import 'package:ebchat/src/lib/widgets/audio_loading_message.dart';
import 'package:ebchat/src/lib/widgets/audio_play_message.dart';
import 'package:ebchat/src/lib/widgets/getStream/custom_message_listview.dart';
import 'package:ebchat/src/lib/widgets/getStream/custom_message_input.dart';
import 'package:ebchat/src/lib/widgets/widgets.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:stream_chat/src/core/models/action.dart' as ac;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as fn;
import 'package:just_audio/just_audio.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:http/http.dart' as http;

class ChatPageUser extends StatefulWidget {
  ChatPageUser({Key? key}) : super(key: key);

  @override
  State<ChatPageUser> createState() => _ChatPageUserState();
}

class _ChatPageUserState extends State<ChatPageUser> {
  final int pageIndex = 0;
  final String title = cf.getTranslated('Messages');
  FocusNode myFocusNode = FocusNode();
  Message? quotedMessage;
  bool recordingStarted = false;
  bool emojiShowing = false;
  late final TextEditingController chatMsgTextController;
  late final ItemScrollController scroller;
  bool typing = false;
  User? typingUser;
  bool showMessageInput = false;
  Attachment? voiceNoteAttachement;
  late final AudioPlayer _audioPlayer;
  final ChatSerivice chatSerivice = ChatSerivice();
  final _audioRecorder = Record();
  void displayTypingSound() async {
    RingerModeStatus ringerStatus = await SoundMode.ringerModeStatus;

    if (ringerStatus == RingerModeStatus.normal) {
      _audioPlayer.setAsset("assets/typing.mp3");
      _audioPlayer.play();
    }
  }

  @override
  void initState() {
    // myFocusNode = FocusNode(descendantsAreFocusable: false);

    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        if (mounted) {
          setState(() {
            emojiShowing = false;
          });
        }
      }
    });
    chatMsgTextController = TextEditingController();
    scroller = ItemScrollController();
    _audioPlayer = AudioPlayer();
    initApp();
    super.initState();
  }

  void initApp() async {
    if (Provider.of<EBchatProvider>(context, listen: false).globalChannel ==
        null) {
      await Provider.of<EBchatProvider>(context, listen: false)
          .findAlfredChannel(context);
    }
    Provider.of<EBchatProvider>(context, listen: false)
        .globalChannel!
        .on('typing.start')
        .listen((event) {
      if (mounted) {
        if (event.user!.id != StreamChat.of(context).currentUser!.id &&
            !typing) {
          displayTypingSound();

          setState(() {
            typingUser = event.user;
            typing = true;
          });
        }
      }
    });

// add typing stop event handling
    Provider.of<EBchatProvider>(context, listen: false)
        .globalChannel!
        .on('typing.stop')
        .listen((event) {
      if (mounted) {
        if (event.user!.id != StreamChat.of(context).currentUser!.id &&
            typing) {
          setState(() {
            typing = false;
          });
          typingUser = null;
        }
      }
    });
    showMessageInput = !(Provider.of<EBchatProvider>(context, listen: false)
                .globalChannel!
                .state!
                .messages
                .lastWhere((element) => element.user!.id == cf.Config.alfredId)
                .extraData["finalBotMessage"] ==
            false) ||
        Provider.of<EBchatProvider>(context, listen: false)
                .globalChannel!
                .extraData["assigned"] ==
            true;
    //display input message input
    Provider.of<EBchatProvider>(context, listen: false)
        .globalChannel!
        .on(EventType.messageNew)
        .listen((event) {
      if (event.message!.user!.id == cf.Config.alfredId) {
        showMessageInput =
            !(event.message!.extraData["finalBotMessage"] == false);
      }

      if (Provider.of<EBchatProvider>(context, listen: false)
              .globalChannel!
              .extraData["assigned"] ==
          true) {
        showMessageInput = true;
      }
      setState(() {
        showMessageInput;
      });
    });
  }

  _onEmojiSelected(Emoji emoji) {
    chatMsgTextController
      ..text += emoji.emoji
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: chatMsgTextController.text.length));
  }

  _onBackspacePressed() {
    chatMsgTextController
      ..text = chatMsgTextController.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: chatMsgTextController.text.length));
  }

  void sendVoiceNote(Message initalMessage, [bool confirmed = false]) async {
    final _client = StreamChatCore.of(context).client;
    final _channel =
        Provider.of<EBchatProvider>(context, listen: false).globalChannel!;
    // ignore: parameter_assignments
    if (!confirmed) {
      Message message = initalMessage.copyWith(
        //  text: "",
        createdAt: initalMessage.createdAt,
        user: _client.state.currentUser,
        status: MessageSendingStatus.sending,
        attachments: initalMessage.attachments.map(
          (it) {
            if (it.uploadState.isSuccess) return it;
            return it.copyWith(uploadState: const UploadState.preparing());
          },
        ).toList(),
      );
      message.attachments.add(Attachment(actions: [
        ac.Action(
          type: "button",
          name: "action",
          value: "confirm",
          text: "Confirm",
          style: "primary",
        )
      ]));
      _channel.state!.messages.add(message);

      try {
        if (!message.attachments.first.uploadState.isSuccess) {
          final attachmentsUploadCompleter = Completer<Message>();
          _channel.retryAttachmentUpload(
            message.id,
            message.attachments.first.id,
          );

          // ignore: parameter_assignments
          message = await attachmentsUploadCompleter.future;
        }

        final response = await _client.sendMessage(
          message,
          _channel.id!,
          _channel.type,
        );

        _channel.state!.messages.add(response.message);
        if (!_channel.extraData.containsKey("initiated")) {
          _channel.updatePartial(set: {"initiated": true});
          /*  chatSerivice.afterMidnight(
              _channel.id!,
              Provider.of<CompanyProvider>(context, listen: false)
                  .company!
                  .ebchatkey!);*/
        }
      } catch (e) {
        print(e);
      }
    } else {
      _channel.state!.removeMessage(initalMessage);
      initalMessage.attachments
          .removeWhere((element) => element.actions!.isNotEmpty);
      _channel.sendMessage(Message(
        attachments: initalMessage.attachments,
      ));
    }
  }

  void _recordingFinishedCallback(String path) {
    final uri = Uri.parse(path);
    File file = File(uri.path);
    file.length().then(
      (fileSize) {
        setState(() {
          voiceNoteAttachement = Attachment(
            type: 'voicenote',
            extraData: {"uri": uri},
            file: AttachmentFile(
              size: fileSize,
              path: uri.path,
            ),
          );
        });
        /*  sendVoiceNote(Message(
          attachments: [
            Attachment(
              type: 'voicenote',
              file: AttachmentFile(
                size: fileSize,
                path: uri.path,
              ),
            )
          ],
        ));*/
      },
    );
  }

  /* @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    myFocusNode.dispose();
    super.dispose();
  }*/

  @override
  Widget build(BuildContext context) {
    return Provider.of<EBchatProvider>(context, listen: false).globalChannel !=
            null
        ? StreamChannel(
            channel: Provider.of<EBchatProvider>(context, listen: false)
                .globalChannel!,
            child: Container(
              color: MessageListViewTheme.of(context).backgroundColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: CustomMessageListView(
                      adminPrivilege: false,
                      key: ValueKey(
                          Provider.of<EBchatProvider>(context, listen: false)
                              .globalChannel!
                              .id),
                      scrollController: scroller,
                      messageBuilder:
                          (context, details, messages, defaultMessage) {
                        if (details.message.attachments.indexWhere(
                                (attachment) => attachment.type == 'choices') !=
                            -1) {
                          return defaultMessage.copyWith(
                              textBuilder: (context, message) {
                                return Row(
                                  children: [
                                    const Spacer(),
                                    Expanded(
                                      flex: 10,
                                      child: Text(
                                        message.text!,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                            color: Colors.black),
                                      ),
                                    ),
                                    const Spacer()
                                  ],
                                );
                              },
                              borderSide: const BorderSide(
                                color: AppColors.secondary,
                              ),
                              customAttachmentBuilders: {
                                'choices':
                                    (context, defaultMessage, attachments) {
                                  final actions = attachments.first.actions;
                                  Message messageWithChoicesAttachement =
                                      messages.firstWhere((msg) =>
                                          msg.attachments.indexWhere(
                                              (attachment) =>
                                                  attachment.type ==
                                                  'choices') !=
                                          -1);

                                  List<Widget> actionsWidget =
                                      actions!.map((e) {
                                    switch (e.type) {
                                      case "form":
                                        return Row(
                                          children: [
                                            const Spacer(),
                                            ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  primary: e.value!
                                                          .contains(";cancel")
                                                      ? Colors.white
                                                      : AppColors.secndaryLight,
                                                  onPrimary: e.value!
                                                          .contains(";cancel")
                                                      ? AppColors.secndaryLight
                                                      : Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    side: const BorderSide(
                                                      color: AppColors
                                                          .secndaryLight,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return UserInfoDialog(
                                                        questionType: e.name,
                                                        question:
                                                            messageWithChoicesAttachement
                                                                        .text ==
                                                                    null
                                                                ? e.name
                                                                : messageWithChoicesAttachement
                                                                    .text!,
                                                      );
                                                    },
                                                  ).then((value) {
                                                    if (value != null &&
                                                        value is String) {
                                                      Provider.of<EBchatProvider>(
                                                              context,
                                                              listen: false)
                                                          .globalChannel!
                                                          .sendMessage(Message(
                                                              text: value));
                                                      Provider.of<EBchatProvider>(
                                                              context,
                                                              listen: false)
                                                          .startBotFlow(
                                                              {
                                                            "cid": Provider.of<
                                                                        EBchatProvider>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .globalChannel!
                                                                .cid!,
                                                            "args": e.value!
                                                                .replaceAll(
                                                                    "/bot ", "")
                                                                .toLowerCase(),
                                                            "lang": cf.Config
                                                                        .textDirection ==
                                                                    TextDirection
                                                                        .ltr
                                                                ? "en"
                                                                : "ar",
                                                            "idMsgWithChoices":
                                                                messageWithChoicesAttachement
                                                                    .id
                                                          },
                                                              Provider.of<CompanyProvider>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .company!
                                                                  .ebchatkey!);
                                                    } else if (value != null &&
                                                        value == true) {
                                                      Provider.of<EBchatProvider>(
                                                              context,
                                                              listen: false)
                                                          .globalChannel!
                                                          .sendMessage(Message(
                                                              text: cf
                                                                  .getTranslated(
                                                                      "Done")));
                                                      Provider.of<EBchatProvider>(
                                                              context,
                                                              listen: false)
                                                          .startBotFlow(
                                                              {
                                                            "cid": Provider.of<
                                                                        EBchatProvider>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .globalChannel!
                                                                .cid!,
                                                            "choiceSelected": cf
                                                                .getTranslated(
                                                                    "Done"),
                                                            "args": e.value!
                                                                .replaceAll(
                                                                    "/bot ", "")
                                                                .toLowerCase(),
                                                            "lang": cf.Config
                                                                        .textDirection ==
                                                                    TextDirection
                                                                        .ltr
                                                                ? "en"
                                                                : "ar",
                                                            "idMsgWithChoices":
                                                                messageWithChoicesAttachement
                                                                    .id
                                                          },
                                                              Provider.of<CompanyProvider>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .company!
                                                                  .ebchatkey!);
                                                    } else if (value
                                                        is Attachment) {
                                                      Provider.of<EBchatProvider>(
                                                              context,
                                                              listen: false)
                                                          .globalChannel!
                                                          .sendMessage(Message(
                                                            attachments: [
                                                              value
                                                            ],
                                                          ))
                                                          .then((value) =>
                                                              Provider.of<EBchatProvider>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .startBotFlow(
                                                                      {
                                                                    "cid": Provider.of<EBchatProvider>(
                                                                            context,
                                                                            listen:
                                                                                false)
                                                                        .globalChannel!
                                                                        .cid!,
                                                                    "args": e
                                                                        .value!
                                                                        .replaceAll(
                                                                            "/bot ",
                                                                            "")
                                                                        .toLowerCase(),
                                                                    "lang": cf.Config.textDirection ==
                                                                            TextDirection.ltr
                                                                        ? "en"
                                                                        : "ar",
                                                                    "idMsgWithChoices":
                                                                        messageWithChoicesAttachement
                                                                            .id
                                                                  },
                                                                      Provider.of<CompanyProvider>(
                                                                              context,
                                                                              listen: false)
                                                                          .company!
                                                                          .ebchatkey!));
                                                    }
                                                  });
                                                },
                                                child: SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width -
                                                            200,
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 3.0),
                                                      child: Center(
                                                          child: Text(
                                                        e.text,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 14,
                                                        ),
                                                      )),
                                                    ))),
                                            const Spacer()
                                          ],
                                        );

                                      default:
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5.0),
                                          child: Row(
                                            children: [
                                              const Spacer(),
                                              ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    primary: e.value!
                                                            .contains(";cancel")
                                                        ? Colors.white
                                                        : AppColors
                                                            .secndaryLight,
                                                    onPrimary: e.value!
                                                            .contains(";cancel")
                                                        ? AppColors
                                                            .secndaryLight
                                                        : Colors.white,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      side: const BorderSide(
                                                        color: AppColors
                                                            .secndaryLight,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    Provider.of<EBchatProvider>(
                                                            context,
                                                            listen: false)
                                                        .globalChannel!
                                                        .sendMessage(Message(
                                                            text: e.text));
                                                    Provider.of<EBchatProvider>(
                                                            context,
                                                            listen: false)
                                                        .startBotFlow(
                                                            {
                                                          "cid": Provider.of<
                                                                      EBchatProvider>(
                                                                  context,
                                                                  listen: false)
                                                              .globalChannel!
                                                              .cid!,
                                                          "args": e.value!
                                                              .replaceAll(
                                                                  "/bot ", "")
                                                              .toLowerCase(),
                                                          "lang": cf.Config
                                                                      .textDirection ==
                                                                  TextDirection
                                                                      .ltr
                                                              ? "en"
                                                              : "ar",
                                                          "idMsgWithChoices":
                                                              messageWithChoicesAttachement
                                                                  .id
                                                        },
                                                            Provider.of<CompanyProvider>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .company!
                                                                .ebchatkey!);
                                                  },
                                                  child: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              200,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 3.0),
                                                        child: Center(
                                                            child: Text(
                                                          e.text,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: GoogleFonts
                                                              .poppins(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 14,
                                                          ),
                                                        )),
                                                      ))),
                                              const Spacer()
                                            ],
                                          ),
                                        );
                                    }
                                  }).toList();

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: Column(
                                      children: actionsWidget,
                                    ),
                                  );
                                }
                              },
                              userAvatarBuilder: (p0, p1) {
                                if (p1.id == cf.Config.alfredId) {
                                  return CircleAvatar(
                                    radius: 18,
                                    backgroundImage: NetworkImage(
                                        Provider.of<CompanyProvider>(context,
                                                listen: false)
                                            .company!
                                            .mascotte!
                                            .image!),
                                    backgroundColor:
                                        Theme.of(context).cardColor,
                                  );
                                }
                                return Avatar.small(
                                  user: p1,
                                );
                              },
                              usernameBuilder: (_, message) {
                                if (message.user!.id == cf.Config.alfredId) {
                                  return Text(
                                    Provider.of<CompanyProvider>(context,
                                            listen: false)
                                        .company!
                                        .mascotte!
                                        .name!,
                                    maxLines: 1,
                                    key: Key('username'),
                                    overflow: TextOverflow.ellipsis,
                                  );
                                }
                                return Text(
                                  message.user?.name ?? '',
                                  maxLines: 1,
                                  key: Key('username'),
                                  overflow: TextOverflow.ellipsis,
                                );
                              });
                        }
                        return defaultMessage.copyWith(
                            customAttachmentBuilders: {
                              'voicenote':
                                  (context, defaultMessage, attachments) {
                                final url = attachments.first.assetUrl;

                                if (url == null) {
                                  return const AudioLoadingMessage();
                                }
                                return Card(
                                    elevation: 0,
                                    color: Colors.grey.shade300,
                                    child: Column(children: [
                                      if (defaultMessage.attachments.indexWhere(
                                              (element) => element
                                                  .actions!.isNotEmpty) !=
                                          -1)
                                        Row(
                                          children: [
                                            Expanded(
                                              child: SizedBox(
                                                height: 50,
                                                child: TextButton(
                                                  onPressed: () {
                                                    Provider.of<EBchatProvider>(
                                                            context,
                                                            listen: false)
                                                        .globalChannel!
                                                        .state!
                                                        .removeMessage(
                                                            defaultMessage);
                                                  },
                                                  child: Text(
                                                    "Cancel",
                                                    style: StreamChatTheme.of(
                                                            context)
                                                        .textTheme
                                                        .bodyBold
                                                        .copyWith(
                                                          color: StreamChatTheme
                                                                  .of(context)
                                                              .colorTheme
                                                              .textHighEmphasis
                                                              .withOpacity(0.5),
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 0.5,
                                              color: StreamChatTheme.of(context)
                                                  .colorTheme
                                                  .textHighEmphasis
                                                  .withOpacity(0.2),
                                              height: 50,
                                            ),
                                            Expanded(
                                              child: SizedBox(
                                                height: 50,
                                                child: TextButton(
                                                  onPressed: () {
                                                    sendVoiceNote(
                                                        defaultMessage, true);
                                                  },
                                                  child: Text(
                                                    "Send",
                                                    style: TextStyle(
                                                      color: StreamChatTheme.of(
                                                              context)
                                                          .colorTheme
                                                          .accentPrimary,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      AudioPlayerMessage(
                                          source:
                                              AudioSource.uri(Uri.parse(url)),
                                          fileSize:
                                              attachments.first.mimeType ==
                                                      "video/webm"
                                                  ? attachments.first.fileSize!
                                                  : 0),
                                    ]));
                              },
                            },
                            userAvatarBuilder: (p0, p1) {
                              if (p1.id == cf.Config.alfredId) {
                                return CircleAvatar(
                                  radius: 18,
                                  backgroundImage: NetworkImage(
                                      Provider.of<CompanyProvider>(context,
                                              listen: false)
                                          .company!
                                          .mascotte!
                                          .image!),
                                  backgroundColor: Theme.of(context).cardColor,
                                );
                              }
                              return Avatar.small(
                                user: p1,
                              );
                            },
                            usernameBuilder: (_, message) {
                              if (message.user!.id == cf.Config.alfredId) {
                                return Text(
                                  Provider.of<CompanyProvider>(context,
                                          listen: false)
                                      .company!
                                      .mascotte!
                                      .name!,
                                  maxLines: 1,
                                  key: Key('username'),
                                  overflow: TextOverflow.ellipsis,
                                );
                              }
                              return Text(
                                message.user?.name ?? '',
                                maxLines: 1,
                                key: Key('username'),
                                overflow: TextOverflow.ellipsis,
                              );
                            });
                      },
                      onMessageSwiped: (message) {
                        setState(() {
                          quotedMessage = message;
                        });
                      },
                    ),
                  ),
                  (typing && typingUser != null)
                      ? Column(
                          children: [
                            Row(
                              children: [
                                const SizedBox(
                                  width: 20,
                                ),
                                const Icon(
                                  Icons.edit,
                                  color: AppColors.archive,
                                  size: 10,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Avatar.verySmall(user: typingUser!),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  typingUser!.name,
                                  style: GoogleFonts.poppins(
                                      color: AppColors.archive,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10),
                                ),
                                Text(
                                  " is Typing...",
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey, fontSize: 10),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: Image.asset(
                                  package: "ebchat", "assets/blueMustache.png"),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Text("Powered By EB Chat",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 11,
                                )),
                          ],
                        ),
                  if (recordingStarted)
                    GestureDetector(
                      onTap: () => stop(),
                      child: Image.asset(
                        package: "ebchat",
                        "assets/recording.gif",
                        height: 30,
                        color: Colors.blue,
                        width: MediaQuery.of(context).size.width,
                      ),
                    ),
                  if (voiceNoteAttachement != null)
                    Column(
                      children: [
                        AudioPlayerMessage(
                            /*    source: AudioSource.uri(
                                voiceNoteAttachement!.localUri!),*/
                            source: AudioSource.uri(
                                voiceNoteAttachement!.extraData["uri"] as Uri),
                            fileSize:
                                voiceNoteAttachement!.mimeType == "video/webm"
                                    ? voiceNoteAttachement!.fileSize!
                                    : 0),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      voiceNoteAttachement = null;
                                    });
                                  },
                                  child: Text(
                                    "Cancel",
                                    style: StreamChatTheme.of(context)
                                        .textTheme
                                        .bodyBold
                                        .copyWith(
                                          color: StreamChatTheme.of(context)
                                              .colorTheme
                                              .textHighEmphasis
                                              .withOpacity(0.5),
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 0.5,
                              color: StreamChatTheme.of(context)
                                  .colorTheme
                                  .textHighEmphasis
                                  .withOpacity(0.2),
                              height: 50,
                            ),
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: TextButton(
                                  onPressed: () {
                                    sendVoiceNote(
                                        Message(attachments: [
                                          voiceNoteAttachement!
                                              .copyWith(extraData: {})
                                        ]),
                                        true);
                                    setState(() {
                                      voiceNoteAttachement = null;
                                    });
                                  },
                                  child: Text(
                                    "Send",
                                    style: TextStyle(
                                      color: StreamChatTheme.of(context)
                                          .colorTheme
                                          .accentPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  CustomMessageInput(
                    showCommandsButton: false,
                    textEditingController: chatMsgTextController,
                    autofocus: true,
                    disable: !showMessageInput,
                    disableAttachments: !showMessageInput,
                    quotedMessage: quotedMessage,
                    focusNode: myFocusNode,
                    onMessageSent: (_) async {
                      if (!Provider.of<EBchatProvider>(context, listen: false)
                          .globalChannel!
                          .extraData
                          .containsKey("initiated")) {
                        Provider.of<EBchatProvider>(context, listen: false)
                            .globalChannel!
                            .updatePartial(set: {"initiated": true});
                        /* Provider.of<EBchatProvider>(context, listen: false)
                            .afterMidnight(
                                Provider.of<EBchatProvider>(context,
                                        listen: false)
                                    .globalChannel!
                                    .id!,
                                Provider.of<CompanyProvider>(context,
                                        listen: false)
                                    .company!
                                    .ebchatkey!);*/
                      }
                      Future.delayed(const Duration(milliseconds: 5), () {
                        if (!myFocusNode.hasFocus) {
                          //     FocusScope.of(context).requestFocus(myFocusNode);
                          myFocusNode.requestFocus();
                        }
                      });
                    },
                    shouldKeepFocusAfterMessage: true,
                    onQuotedMessageCleared: () {
                      setState(() {
                        quotedMessage = null;
                      });
                    },
                    actions: !showMessageInput
                        ? []
                        : [
                            GestureDetector(
                              onTap: () {
                                recordingStarted ? stop() : start();
                              },
                              child: Icon(
                                recordingStarted ? Icons.stop : Icons.mic,
                                color: recordingStarted
                                    ? Colors.red.withOpacity(0.3)
                                    : StreamChatTheme.of(context)
                                        .primaryIconTheme
                                        .color,
                              ),
                            ),
                            InkWell(
                              child: Icon(
                                !emojiShowing
                                    ? Icons.emoji_emotions
                                    : Icons.keyboard,
                                //Icons.emoji_emotions,
                                color: Colors.grey.shade600,
                                size: 20.0,
                              ),
                              onTap: () {
                                setState(() {
                                  emojiShowing = !emojiShowing;
                                });
                                emojiShowing
                                    ? FocusScope.of(context).unfocus()
                                    : FocusScope.of(context)
                                        .requestFocus(myFocusNode);
                              },
                            ),
                          ],
                  ),
                  Offstage(
                    offstage: !emojiShowing,
                    child: SizedBox(
                        height: 270,
                        child: EmojiPicker(
                            onEmojiSelected: (category, emoji) {
                              _onEmojiSelected(emoji);
                            },
                            onBackspacePressed: _onBackspacePressed,
                            config: const Config(
                              columns: 7,
                              emojiSizeMax: 32.0,
                              verticalSpacing: 0,
                              horizontalSpacing: 0,
                              initCategory: Category.RECENT,
                              bgColor: Color(0xFFF2F2F2),
                              indicatorColor: Colors.blue,
                              iconColor: Colors.grey,
                              iconColorSelected: Colors.blue,
                              backspaceColor: Colors.blue,
                              showRecentsTab: true,
                              recentsLimit: 28,
                            ))),
                  ),
                ],
              ),
            ),
          )
        : const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
  }

  void _recordingWebFinishedCallback(AttachmentFile file) {
    setState(() {
      voiceNoteAttachement = Attachment(
          type: 'voicenote',
          file: file,
          extraData: const {'mime_type': "video/webm"});
    });
    /*  sendVoiceNote(
      Message(
        command: "voicenote",
        attachments: [
          Attachment(
              type: 'voicenote',
              file: file,
              extraData: const {'mime_type': "video/webm"})
        ],
      ),
    );*/
  }

  Future<void> start() async {
    try {
      setState(() {
        recordingStarted = true;
      });
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> stop() async {
    final path = await _audioRecorder.stop();
    /*fn.kIsWeb
          ? _recordingWebFinishedCallback(path!)
          :*/
    _recordingFinishedCallback(path!);

    setState(() {
      recordingStarted = false;
    });
  }
}
