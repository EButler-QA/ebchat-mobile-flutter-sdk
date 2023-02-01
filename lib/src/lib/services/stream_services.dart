import 'dart:convert';
import 'package:ebchat/src/lib/config/config.dart';
import 'package:http/http.dart';
import 'package:ebchat/src/lib/models/Company.dart';
import 'package:stream_chat/stream_chat.dart';

class EBChatService {
  static StreamChatClient? client;

  static void disposeEbchatClient() {
    if (client != null) {
      Config.currentCompany = null;
      client!.dispose();
      client = null;
    }
  }

  static Future<StreamChatClient?> getWebsocketClient(String ebchatkey) async {
    if (client == null && Config.currentCompany == null) {
      Response response = await get(
        Uri.parse('${Config.ebchat_saas_api_url}fdb/getCompanyInfo'),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
          'EBCHATKEY': ebchatkey,
        },
      );
      Config.currentCompany = Company.fromMap(json.decode(response.body));
    }
    if (Config.currentCompany == null ||
        Config.currentCompany!.streamkey == null) return null;
    client = StreamChatClient(Config.currentCompany!.streamkey!);
    return client;
  }
}
