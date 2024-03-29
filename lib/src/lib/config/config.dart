import 'dart:convert';
import 'package:ebchat/src/lib/models/Company.dart';
import 'package:flutter/services.dart';
import 'package:stream_chat/src/client/channel.dart';

Map<String, dynamic> mappedTextStrings = {};
String getTranslated(String key) {
  return mappedTextStrings[key] ?? key;
}

Future<void> loadTextString() async {
  String languageCode = "en";
  if (Config.textDirection == TextDirection.ltr) {
    languageCode = "en";
  } else {
    languageCode = "ar";
  }
  String jsonStringValues =
      await rootBundle.loadString('packages/ebchat/assets/$languageCode.json');
  mappedTextStrings = json.decode(jsonStringValues);
  mappedTextStrings.map((key, value) => MapEntry(key, value.toString()));
}

class Config {
  static String alfredId = "alfred";
  static const platform = MethodChannel("EbutlerChat/user");
  static String virtualIntrest = "";
  static TextDirection textDirection = TextDirection.ltr;
  static String languageCode = "en";
  static String ebchatSassApiUrl =
      "https://ebchat-saas.e-butler.com/ebchat_api/";
  static String? azureMapsApiKey;
  static Company? currentCompany;
  static Channel? globalChannel;

  static void setConfig(bool arabicApp, String? azurMap) {
    if (arabicApp) {
      languageCode = "ar";
      textDirection = TextDirection.rtl;
    }
    azureMapsApiKey = azurMap;
  }
}
