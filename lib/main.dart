import 'package:dashboard_tirocinio/screens/autenticazione/login_page.dart';
import 'package:dashboard_tirocinio/screens/dashboard/home_page.dart';
import 'package:dashboard_tirocinio/utility/utils.dart';
import 'package:flutter/material.dart';
import 'package:encrypt_shared_preferences/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late EncryptedSharedPreferences _prefs;
  String? _token;

  void initPreferences() async {
    await EncryptedSharedPreferences.initialize(Utils.encryptingKey);
    EncryptedSharedPreferences tmp = EncryptedSharedPreferences.getInstance();

    setState(() {
      _prefs = tmp;
    });

    String? tmpToken = _prefs.getString('token');

    setState(() {
      _token = tmpToken;
    });
  }

  @override
  void initState() {
    super.initState();
    initPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorSchemeSeed: Colors.orangeAccent,
      ),
      home: _token == null ? const LoginPage() : const HomePage(),
      //home: LoginPage(),
    );
  }
}