import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  static String virtual_intrest = "";
  static TextDirection textDirection = TextDirection.ltr;
  static String languageCode = "en";
//prod
//static String ebchat_saas_api_url = "https://ebchat-saas.e-butler.com/ebchat_api/";
//test
  static String ebchat_saas_api_url =
      "https://ebchat-saas-test.e-butler.com/ebchat_api/";
//localHost
  //static String ebchat_saas_api_url = "https://6f0e-41-228-223-212.ngrok.io/";
// "http://localhost:4001/";

  static void setConfig(bool arabicApp) {
    if (arabicApp) {
      languageCode = "ar";
      textDirection = TextDirection.rtl;
    }
  }
}
