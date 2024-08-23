import 'package:dashboard_tirocinio/base_url_init.dart';
import 'package:dashboard_tirocinio/screens/autenticazione/login_page.dart';
import 'package:dashboard_tirocinio/screens/configurazione/base_api_url_set_page.dart';
import 'package:dashboard_tirocinio/screens/dashboard/home_page.dart';
import 'package:dashboard_tirocinio/utility/utils.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UrlInitImpl extends BaseUrlInit {
  late EncryptedSharedPreferences _prefs;
  String? _token;
  String? _baseApiUrl;

  Future<void> initEnv() async {
    await dotenv.load(fileName: "url.env");
    _baseApiUrl = dotenv.env['BASE_API_URL'];
    await initPreferences();
  }

  Future<void> initPreferences() async {
    await EncryptedSharedPreferences.initialize(Utils.encryptingKey);
    _prefs = EncryptedSharedPreferences.getInstance();
    await _prefs.setString('url', _baseApiUrl);
    _token = _prefs.getString('token');
  }

  @override
  Widget initUrl() {
    return FutureBuilder(
      future: initEnv(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
              width: 100, height: 100, child: CircularProgressIndicator());
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
