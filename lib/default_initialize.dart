import 'package:dashboard_tirocinio/base_url_init.dart';
import 'package:dashboard_tirocinio/screens/autenticazione/login_page.dart';
import 'package:dashboard_tirocinio/screens/wizard/base_api_url_set_page.dart';
import 'package:dashboard_tirocinio/screens/dashboard/home_page.dart';
import 'package:dashboard_tirocinio/utility/utils.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/material.dart';

class UrlInitImpl extends BaseUrlInit {
  late EncryptedSharedPreferences _prefs;
  String? _token;
  String? _baseApiUrl;

  Future<void> initPreferences() async {
    await EncryptedSharedPreferences.initialize(Utils.encryptingKey);
    _prefs = EncryptedSharedPreferences.getInstance();
    _token = _prefs.getString('token');
    _baseApiUrl = _prefs.getString('url');
  }

  @override
  Widget initUrl() {
    return FutureBuilder(
      future: initPreferences(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const BaseApiUrlSetPage();
        } else {
          if (_baseApiUrl == null) {
            return const BaseApiUrlSetPage();
          } else if (_token == null) {
            return const LoginPage();
          } else {
            return const HomePage();
          }
        }
      },
    );
  }
}
