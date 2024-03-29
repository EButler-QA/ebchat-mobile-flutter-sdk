import 'package:ebchat/src/lib/config/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatSerivice {
  Future<void> afterMidnight(String chId, String ebchatkey) async {
    await http.post(
      Uri.parse('${Config.ebchatSassApiUrl}getstream/afterMidnight'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
        'EBCHATKEY': ebchatkey,
      },
      body: {
        "data": {
          "language": Config.textDirection == TextDirection.ltr ? "en" : "ar"
        }
      },
    );
    return;
  }

  Future<int> createChannelWithAlfred(String userId, String ebchatkey) async {
    http.Response response = await http.post(
      Uri.parse(
        '${Config.ebchatSassApiUrl}getstream/createChannelWithAlfred',
      ),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
        'EBCHATKEY': ebchatkey,
      },
      body: <String, String>{
        "userID": userId,
        "app_source": "mobile_app",
        "language": Config.textDirection == TextDirection.ltr ? "en" : "ar"
      },
    );
    return response.statusCode;
  }

  static Future<String> getStreamUserToken(
      String userId, String ebchatkey) async {
    http.Response response = await http.post(
      Uri.parse('${Config.ebchatSassApiUrl}getstream/getStreamUserToken'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
        'EBCHATKEY': ebchatkey,
      },
      body: <String, String>{
        "user": userId,
      },
    );
    return response.body;
  }

  void startBotFlow(Map<String, String> body, String ebchatkey) {
    http.post(
      Uri.parse('${Config.ebchatSassApiUrl}botflow/startSequence'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
        'EBCHATKEY': ebchatkey,
      },
      body: body,
    );
  }
}
