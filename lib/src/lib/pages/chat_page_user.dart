import 'dart:async';
import 'dart:io';

import 'package:ebchat/src/lib/Theme/my_theme.dart';
import 'package:ebchat/src/lib/components/getstream/custom_message_input.dart';
import 'package:ebchat/src/lib/components/getstream/custom_message_listview.dart';
import 'package:ebchat/src/lib/config/config.dart' as cf;
import 'package:ebchat/src/lib/providers/company_provider.dart';
import 'package:ebchat/src/lib/providers/navigator_provider.dart';
import 'package:ebchat/src/lib/services/chat_services.dart';
import 'package:ebchat/src/lib/widgets/audio_loading_message.dart';
import 'package:ebchat/src/lib/widgets/audio_play_message.dart';
import 'package:ebchat/src/lib/widgets/dialog/user_info_dialog.dart';
import 'package:ebchat/src/lib/widgets/getStream/custom_message_input.dart';
import 'package:ebchat/src/lib/widgets/getStream/custom_message_listview.dart';
import 'package:ebchat/src/lib/widgets/widgets.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';
import 'package:stream_chat/src/core/models/action.dart' as ac;
import 'package:stream_chat_flutter/scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ChatPageUser extends StatefulWidget {
  const ChatPageUser({
    Key? key,
  }) : super(key: key);

  @override
  State<ChatPageUser> createState() => _ChatPageUserState();
}

class _ChatPageUserState extends State<ChatPageUser> {
  final int pageIndex = 0;
  final String title = cf.getTranslated('Messages');
  FocusNode myFocusNode = FocusNode();
  final _audioRecorder = Record();
  Message? quotedMessage;
  bool emojiShowing = false;
  late StreamMessageInputController chatMsgTextController;
  late final ItemScrollController scroller;
  bool typing = false;
  User? typingUser;
  final ChatService chatSerivice = ChatService();
  Attachment? voiceNoteAttachement;
  bool recordingStarted = false;
  late User? currentUser;
  @override
  void initState() {
    chatMsgTextController = StreamMessageInputController(message: Message());
    scroller = ItemScrollController();
    currentUser = StreamChatCore.of(context).currentUser;
    initApp();
    super.initState();
  }

  @override
  void dispose() {
    chatMsgTextController.dispose();
    super.dispose();
  }

  void initApp() async {
    if (context.read<NavigatorProvider>().globalChannel == null) {
      await context.read<NavigatorProvider>().findAlfredChannel(context);
    }

    context
        .read<NavigatorProvider>()
        .globalChannel
        ?.on('typing.start')
        .listen((event) {
      if (mounted) {
        if (event.user!.id != currentUser!.id && !typing) {
          setState(() {
            typingUser = event.user;
            typing = true;
          });
        }
      }
    });

// add typing stop event handling
    context
        .read<NavigatorProvider>()
        .globalChannel
        ?.on('typing.stop')
        .listen((event) {
      if (mounted) {
        if (event.user!.id != currentUser!.id && typing) {
          setState(() {
            typing = false;
          });
          typingUser = null;
        }
      }
    });
  }

  void stopRecording() {
    setState(() {
      recordingStarted = false;
    });
  }

  void sendVoiceNote(Message initalMessage, [bool confirmed = false]) async {
    final client = StreamChatCore.of(context).client;
    final channel =
        Provider.of<NavigatorProvider>(context, listen: false).globalChannel!;
    // ignore: parameter_assignments
    if (!confirmed) {
      Message message = initalMessage.copyWith(
        //  text: "",
        createdAt: initalMessage.createdAt,
        user: client.state.currentUser,
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
      channel.state!.updateMessage(message);

      try {
        if (!message.attachments.first.uploadState.isSuccess) {
          final attachmentsUploadCompleter = Completer<Message>();
          channel.retryAttachmentUpload(
            message.id,
            message.attachments.first.id,
          );

          // ignore: parameter_assignments
          message = await attachmentsUploadCompleter.future;
        }

        final response = await client.sendMessage(
          message,
          channel.id!,
          channel.type,
        );

        channel.state!.updateMessage(response.message);
        if (context
                .read<NavigatorProvider>()
                .globalChannel
                ?.extraData
                .containsKey("initiated") ==
            false) {
          context
              .read<NavigatorProvider>()
              .globalChannel
              ?.updatePartial(set: {"initiated": true});
          chatSerivice.afterMidnight(
              context.read<NavigatorProvider>().globalChannel!.id!,
              context.read<CompanyProvider>().company!.ebchatkey!);
        }
      } catch (e) {
        print("//////////////");
        print(e);
      }
    } else {
      channel.state!.removeMessage(initalMessage);
      initalMessage.attachments.removeWhere(
          (element) => element.actions != null && element.actions!.isNotEmpty);
      channel.sendMessage(Message(
        attachments: initalMessage.attachments,
      ));
    }
  }

  Future<void> storeAnswerAndCallNextBot(
      String botflowId, String nextNodeIndex) async {
    String cid = context.read<NavigatorProvider>().globalChannel!.cid!;
    await ChatService.startBotFlow(
        language: cf.Config.languageCode!,
        cid: cid,
        botflowId: botflowId,
        nextNodeIndex: nextNodeIndex);
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Provider.of<NavigatorProvider>(context).globalChannel != null
        ? StreamChannel(
            channel: context.watch<NavigatorProvider>().globalChannel!,
            child: Container(
              color: StreamMessageListViewTheme.of(context).backgroundColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: CustomStreamMessageListView(
                      key: ValueKey(
                          context.watch<NavigatorProvider>().globalChannel!.id),
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
                                  final List<ac.Action>? actions =
                                      attachments.first.actions;

                                  Message messageWithChoicesAttachement =
                                      messages.firstWhere((msg) =>
                                          msg.attachments.any((attachment) =>
                                              attachment.type == 'choices'));
                                  List<Widget> actionsWidget = [];
                                  if (actions != null) {
                                    actionsWidget = actions
                                        .where((element) =>
                                            element.name != "EditText")
                                        .map((action) {
                                      return _buildActionButton(action,
                                          messageWithChoicesAttachement);
                                    }).toList();
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: actionsWidget,
                                    ),
                                  );
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
                                    key: const Key('username'),
                                    overflow: TextOverflow.ellipsis,
                                  );
                                }
                                return Text(
                                  message.user?.name ?? '',
                                  maxLines: 1,
                                  key: const Key('username'),
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
                                              (element) =>
                                                  element.actions != null &&
                                                  element
                                                      .actions!.isNotEmpty) !=
                                          -1)
                                        Row(
                                          children: [
                                            Expanded(
                                              child: SizedBox(
                                                height: 50,
                                                child: TextButton(
                                                  onPressed: () {
                                                    context
                                                        .read<
                                                            NavigatorProvider>()
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
                                  key: const Key('username'),
                                  overflow: TextOverflow.ellipsis,
                                );
                              }
                              return Text(
                                message.user?.name ?? '',
                                maxLines: 1,
                                key: const Key('username'),
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
                            Image.asset(
                              package: "ebchat",
                              "assets/blueMustache.png",
                              height: 25,
                              width: 25,
                              color: AppColors.primary,
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
                    Image.asset(
                      package: "ebchat",
                      "assets/recording.gif",
                      height: 30,
                      color: Colors.blue,
                      width: MediaQuery.of(context).size.width,
                    ),
                  if (voiceNoteAttachement != null)
                    Column(
                      children: [
                        AudioPlayerMessage(
                            source: AudioSource.uri(
                                voiceNoteAttachement!.localUri!),
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
                  const Divider(),
                  CustomStreamMessageInput(
                    showCommandsButton: false,
                    messageInputController: chatMsgTextController,
                    autofocus: false,
                    shouldKeepFocusAfterMessage: true,
                    preMessageSending: (p0) {
                      Message? newMessage;
                      chatMsgTextController.clear();
                      if (context
                          .read<NavigatorProvider>()
                          .globalChannel!
                          .extraData
                          .containsKey("dispatchTo")) {
                        Map<String, Object?> extraData = {...p0.extraData};
                        extraData['dispatchTo'] = context
                            .read<NavigatorProvider>()
                            .globalChannel!
                            .extraData['dispatchTo'];
                        newMessage = p0.copyWith(extraData: extraData);
                      }
                      setState(() {});
                      return newMessage ?? p0;
                    },
                    activeSendButton: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.send,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                    onMessageSent: (msg) async {
                      if (!context
                              .read<NavigatorProvider>()
                              .globalChannel!
                              .extraData
                              .containsKey("initiated") ||
                          context
                                  .read<NavigatorProvider>()
                                  .globalChannel!
                                  .extraData["initiated"] ==
                              false) {
                        await context
                            .read<NavigatorProvider>()
                            .globalChannel!
                            .updatePartial(set: {"initiated": true});
                      }
                      Message messageWithChoicesAttachement = context
                          .read<NavigatorProvider>()
                          .globalChannel!
                          .state!
                          .messages
                          .firstWhere((msg) =>
                              msg.attachments.indexWhere((attachment) =>
                                  attachment.type == 'choices') !=
                              -1);

                      if (messageWithChoicesAttachement.id.isNotEmpty) {
                        final actions = messageWithChoicesAttachement
                            .attachments.first.actions;
                        dynamic action =
                            actions?.firstWhere((e) => e.name == "EditText");
                        if (action != null && action.name == "EditText") {
                          List<String> parms =
                              (action.value as String).split(";");
                          await storeAnswerAndCallNextBot(parms[0], parms[1]);
                        }
                      }
                    },
                    onQuotedMessageCleared: () {
                      setState(() {
                        quotedMessage = null;
                      });
                    },
                    actions: [
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
                          !emojiShowing ? Icons.emoji_emotions : Icons.keyboard,
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
                              // showRecentsTab: true,
                              recentsLimit: 28,
                            ))),
                  ),
                ],
              ),
            ),
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }

  Widget _buildActionButton(
      ac.Action action, Message messageWithChoicesAttachement) {
    final actionIsCancel = action.value!.contains(";cancel");
    final buttonColor = actionIsCancel ? Colors.white : AppColors.secndaryLight;
    final textColor = actionIsCancel ? AppColors.secndaryLight : Colors.white;

    final buttonText = Text(
      action.text,
      textAlign: TextAlign.center,
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.w400,
        fontSize: 14,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: textColor,
          backgroundColor: buttonColor,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: AppColors.secndaryLight),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () =>
            _onActionButtonPressed(action, messageWithChoicesAttachement),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: Center(child: buttonText),
        ),
      ),
    );
  }

// Helper method to handle button press
  void _onActionButtonPressed(
      ac.Action action, Message messageWithChoicesAttachement) {
    String botflowId = messageWithChoicesAttachement
        .attachments.first.extraData["botFlowId"] as String;
    if (action.type == "form") {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return UserInfoDialog(
            questionType: action.name,
            question: messageWithChoicesAttachement.text ?? action.name,
          );
        },
      ).then((value) {
        if (value is String) {
          context
              .read<NavigatorProvider>()
              .globalChannel!
              .sendMessage(Message(text: value));
        } else if (value is Attachment) {
          context.read<NavigatorProvider>().globalChannel!.sendMessage(Message(
                attachments: [value],
              ));
        } else {
          context
              .read<NavigatorProvider>()
              .globalChannel!
              .sendMessage(Message(text: cf.getTranslated("Done")));
        }

        ChatService.startBotFlow(
            cid: context.read<NavigatorProvider>().globalChannel!.cid!,
            language: cf.Config.languageCode!,
            botflowId: botflowId,
            nextNodeIndex: action.value!.contains(";")
                ? action.value!.split(";")[1]
                : action.value!);
      });
    } else {
      context
          .read<NavigatorProvider>()
          .globalChannel!
          .sendMessage(Message(text: action.text));
      ChatService.startBotFlow(
          cid: context.read<NavigatorProvider>().globalChannel!.cid!,
          language: cf.Config.languageCode,
          botflowId: botflowId,
          nextNodeIndex: action.value!);
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

  _onBackspacePressed() {
    chatMsgTextController
      ..text = chatMsgTextController.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: chatMsgTextController.text.length));
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

  _onEmojiSelected(Emoji emoji) {
    chatMsgTextController
      ..text += emoji.emoji
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: chatMsgTextController.text.length));
  }

  void _recordingFinishedCallback(String path) {
    final uri = Uri.parse(path);
    File file = File(uri.path);
    file.length().then((fileSize) {
      setState(() {
        sendVoiceNote(Message(
          attachments: [
            Attachment(
              type: 'voicenote',
              file: AttachmentFile(
                size: fileSize,
                path: uri.path,
              ),
            )
          ],
        ));
      });
    });
  }
}
