import 'dart:convert';
import 'package:ebchat/src/lib/config/config.dart';
import 'package:http/http.dart';
import 'package:ebchat/src/lib/models/Company.dart';
import 'package:stream_chat/stream_chat.dart';

String? channelId;

class EBChatService {
  static StreamChatClient? client;

  static Future<void> disposeEbchatClient(
      {bool disposeCompany = false, bool disposeUser = true}) async {
    if (client != null) {
      if (disposeUser) {
        await client!.disconnectUser();
      }

      Config.globalChannel = null;
      if (disposeCompany) {
        Config.currentCompany = null;
      }
    }
  }

  static Future<StreamChatClient?> getWebsocketClient(String ebchatkey) async {
    Response response = await get(
      Uri.parse('${Config.ebchatSassApiUrl}fdb/getCompanyInfo'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
        'EBCHATKEY': ebchatkey,
      },
    );
    Config.currentCompany = Company.fromMap(json.decode(response.body));
    if (Config.currentCompany == null ||
        Config.currentCompany!.streamkey == null) return null;
    client = StreamChatClient(Config.currentCompany!.streamkey!);
    return client;
  }

  static Future<String?> getFcmTokenForEbchat(
      String ebchatkey, String userId) async {
    Response response = await get(
      Uri.parse(
          '${Config.ebchatSassApiUrl}auth/getFcmTokenForForignApps/$userId'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
        'EBCHATKEY': ebchatkey,
      },
    );

    return response.body;
  }

  static String? getChannelId() {
    return channelId;
  }

}
