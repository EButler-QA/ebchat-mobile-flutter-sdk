import 'package:ebchat/src/lib/config/config.dart';
import 'package:http/http.dart' as http;

class ChatService {
  //PUBLIC
  static Future<String> getStreamUserToken(
      String userId, String ebchatkey) async {
    http.Response response = await http.post(
        Uri.parse('${Config.ebchat_saas_api_url}getstream/getStreamUserToken'),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
          'EBCHATKEY': ebchatkey,
        },
        body: <String, String>{
          "user": userId,
        });
    return response.body;
  }

  static String? getEBchatWebSocket() {
    return Config.currentCompany?.streamkey;
  }

  static Future<void> startBotFlow(
      {required String language,
      required String botflowId,
      required String cid,
      required String nextNodeIndex}) async {
    try {
      http.Response response = await http.post(
          Uri.parse('${Config.ebchat_saas_api_url}botflow/startSequence'),
          headers: <String, String>{
            'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
            'EBCHATKEY': Config.currentCompany!.ebchatkey!,
          },
          body: {
            "lang": language,
            "botflowId": botflowId,
            "nodeIndex": nextNodeIndex,
            "cid": cid,
          });
    } catch (e) {
      print(e);
    }
    return;
  }

//PRIVATE
  Future<void> afterMidnight(String chId, String ebchatkey) async {
    await http.post(
        Uri.parse('${Config.ebchat_saas_api_url}botflow/afterMidnight'),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
          'EBCHATKEY': ebchatkey,
        },
        body: <String, dynamic>{
          "data": {"language": Config.languageCode}
        });
    return;
  }

  Future<dynamic> createChannelWithAlfred(String userId, ebchatkey) async {
    http.Response response = await http.post(
        Uri.parse(
            '${Config.ebchat_saas_api_url}botflow/createChannelWithAlfred'),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
          'EBCHATKEY': ebchatkey,
        },
        body: <String, String>{
          "userID": userId,
          "app_source": "guest_app",
          "language": Config.languageCode!
        });
    return response.body;
  }
}
