import 'package:dashboard_tirocinio/base_url_init.dart';
import 'package:dashboard_tirocinio/screens/autenticazione/login_page.dart';
import 'package:dashboard_tirocinio/screens/configurazione/base_api_url_set_page.dart';
import 'package:dashboard_tirocinio/screens/dashboard/home_page.dart';
import 'package:dashboard_tirocinio/utility/utils.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/material.dart';

class UrlInitImpl extends BaseUrlInit {
  late EncryptedSharedPreferences _prefs;
  String? _token;
  String? _baseUrl;

  UrlInitImpl() {
    initPreferences();
  }

  void initPreferences() async {
    await EncryptedSharedPreferences.initialize(Utils.encryptingKey);
    _prefs = EncryptedSharedPreferences.getInstance();
    _token = _prefs.getString('token');
    _baseUrl = _prefs.getString('url');
  }

  @override
  Widget initUrl() {
    return _baseUrl == null ? const BaseApiUrlSetPage() : _token == null ? const LoginPage() : const HomePage();
  }
}