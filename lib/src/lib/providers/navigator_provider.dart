import 'package:ebchat/src/lib/config/config.dart';
import 'package:ebchat/src/lib/providers/company_provider.dart';
import 'package:ebchat/src/lib/services/chat_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class NavigatorProvider with ChangeNotifier {
  Channel? globalChannel;
  User? currentUser;
  final ChatService chatSerivice = ChatService();

//EBCHAT SAAS BACKEND

  ///GETSTREAM
  void setChannel(Channel? tmp, bool mounted) {
    globalChannel = tmp;
    if (mounted) notifyListeners();
  }

  void setCurrentUser(User? tmp, bool mounted) {
    currentUser = tmp;
    //  if (mounted) notifyListeners();
  }

  Future<void> findAlfredChannel(
    BuildContext context,
  ) async {
    final client = StreamChatCore.of(context).client;
    final CompanyProvider companyProvider =
        Provider.of<CompanyProvider>(context, listen: false);
    final streamChatCore = StreamChatCore.of(context);
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
          streamChatCore.currentUser!.id, companyProvider.company!.ebchatkey!);
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
    }

    if (channels.isNotEmpty) {
      globalChannel = channels.first;
      await globalChannel!.watch();
      // notifyListeners();
    }
    return;
  }

  void afterMidnight(String chID, String ebchatkey) {
    chatSerivice.afterMidnight(chID, ebchatkey);
  }

  Future<String> getStreamUserToken(String userID, String ebchatkey) async {
    String token = await ChatService.getStreamUserToken(userID, ebchatkey);
    return token;
  }

  Future<void> logout() async {
    if (globalChannel != null) {
      globalChannel!.dispose();
      setChannel(null, false);
    }
  }
}
