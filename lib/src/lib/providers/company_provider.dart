import 'package:ebchat/src/lib/config/config.dart';
import 'package:ebchat/src/lib/models/Company.dart';
import 'package:flutter/material.dart';

class CompanyProvider extends ChangeNotifier {
  Company? company;

  void setCompany(bool mounted) {
    company = Config.currentCompany;
    // if (mounted) notifyListeners();
  }
}
