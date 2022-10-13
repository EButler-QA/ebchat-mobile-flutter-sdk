import 'dart:convert';
import 'package:ebchat/src/lib/config/config.dart';
import 'package:http/http.dart';
import 'package:ebchat/src/lib/models/Company.dart';

class EBChatService {
  static Future<String> getCompanyStreamAcess(
      String ebchatkey, bool talkToEbutler) async {
    Response response = await get(
      Uri.parse('${Config.ebchat_saas_api_url}fdb/getCompanyInfo'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
        'EBCHATKEY': ebchatkey,
      },
    );
    Company tmp = Company.fromMap(json.decode(response.body));
    return tmp.streamkey!;
  }
}
