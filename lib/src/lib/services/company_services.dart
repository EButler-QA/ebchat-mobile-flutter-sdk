import 'dart:convert';
import 'package:ebchat/src/lib/config/config.dart';
import 'package:http/http.dart';

import 'package:ebchat/src/lib/models/Company.dart';

class CompanyService {
  Future<Company> getCompany(String ebchatkey) async {
    Response response = await get(
      Uri.parse('${Config.ebchat_saas_api_url}fdb/getCompanyInfo'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
        'EBCHATKEY': ebchatkey,
      },
    );
    return Company.fromMap(json.decode(response.body));
  }
}
