import 'package:ebchat/src/lib/models/Company.dart';
import 'package:ebchat/src/lib/services/company_services.dart';
import 'package:flutter/material.dart';

class CompanyProvider extends ChangeNotifier {
  Company? company;
  final CompanyService companyService = CompanyService();

  Future<Company> setCompany(
      String ebchatkey, bool rederictMessagesToEbutlerOperators) async {
    if (!rederictMessagesToEbutlerOperators) {
      company = await companyService.getCompany(ebchatkey);
    } else {
      company = await companyService.getEbutlerCompany();
    }
    return company!;
  }
}
