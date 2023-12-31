import 'package:ebchat/src/lib/config/config.dart';
import 'package:ebchat/src/lib/providers/company_provider.dart';
import 'package:ebchat/src/lib/services/chat_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class EBchatProvider with ChangeNotifier {
  Channel? globalChannel;
  User? currentUser;
  final ChatSerivice chatSerivice = ChatSerivice();

//EBCHAT SAAS BACKEND

  startBotFlow(Map<String, String> body, String ebchatkey) {
    chatSerivice.startBotFlow(body, ebchatkey);
  }

  ///GETSTREAM
  void setChannel(Channel? tmp, bool mounted) {
    globalChannel = tmp;
    Config.globalChannel = globalChannel;
    if (mounted) notifyListeners();
  }

  void setCurrentUser(User? tmp, bool mounted) {
    currentUser = tmp;
    // if (mounted) notifyListeners();
  }

  Future<void> findAlfredChannel(BuildContext context, bool mounted) async {
    if (globalChannel != null) return;
    final StreamChatCoreState streamChatCore = StreamChatCore.of(context);
    final CompanyProvider companyProvider = context.read<CompanyProvider>();
    final client = streamChatCore.client;
    List<Channel> channels = await client
        .queryChannels(
          filter: Filter.and(
            [
              Filter.equal('type', 'messaging'),
              Filter.equal('frozen', false),
              Filter.equal('companyID', Config.currentCompany!.id!),
              Filter.in_("members", [
                StreamChatCore.of(context).currentUser!.id,
              ])
            ],
          ),
        )
        .first;
    if (channels.isEmpty) {
      await chatSerivice.createChannelWithAlfred(
        streamChatCore.currentUser!.id,
        companyProvider.company!.ebchatkey!,
      );
      channels = await client
          .queryChannels(
            filter: Filter.and(
              [
                Filter.equal('type', 'messaging'),
                Filter.equal('frozen', false),
                Filter.equal('companyID', Config.currentCompany!.id!),
                Filter.in_("members", [
                  streamChatCore.currentUser!.id,
                ])
              ],
            ),
          )
          .first;
    } else {
      globalChannel = channels.first;
      await globalChannel!.watch();
      /* if (mounted) {
        notifyListeners();
      }*/
    }
    Config.globalChannel = globalChannel;
  }

  void afterMidnight(String chID, String ebchatkey) {
    chatSerivice.afterMidnight(chID, ebchatkey);
  }

  Future<String> getStreamUserToken(String userID, String ebchatkey) async {
    String token = await ChatSerivice.getStreamUserToken(userID, ebchatkey);
    return token;
  }
}
