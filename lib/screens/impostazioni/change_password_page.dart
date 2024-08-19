import 'dart:io';

import 'package:dashboard_tirocinio/screens/autenticazione/login_page.dart';
import 'package:dashboard_tirocinio/utility/api_helper.dart';
import 'package:dashboard_tirocinio/utility/utils.dart';
import 'package:flutter/material.dart';
import 'package:encrypt_shared_preferences/provider.dart';

class ChangePasswordPage extends StatefulWidget {
  final User? utente;
  const ChangePasswordPage({super.key, this.utente});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  late EncryptedSharedPreferences _prefs;
  String? _token;
  String? _userType;
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  void initPreferences() async {
    EncryptedSharedPreferences tmp;
    String? tmpToken = '';
    String? tmpType = '';
    try {
      await EncryptedSharedPreferences.initialize(Utils.encryptingKey);
      tmp = EncryptedSharedPreferences.getInstance();

    } on Exception catch (e) {
      Utils.showSnackBar(context, 'OPS', 'Qualcosa è andato storto, effettua nuovamente il login\n$e', true);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => const LoginPage()),
              (Route<dynamic> route) => false);
      return;
    }

    setState(() {
      _prefs = tmp;
    });

    tmpToken = _prefs.getString('token');
    tmpType = _prefs.getString('tipo');

    setState(() {
      _token = tmpToken!;
      _userType = tmpType!;
    });
  }

  @override
  void initState() {
    super.initState();
    initPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Modifica'),
          ],
        ),
      ),

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
                maxWidth: 500
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Card(
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Modifica password', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                      Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: TextFormField(
                                      validator: (valore) {
                                        if (valore == null || valore.isEmpty) {
                                          return 'Inserisci la nuova password';
                                        }
                                        return null;
                                      },
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      controller: _passwordController
                                  ),
                                ),
                                TextFormField(
                                    validator: (valore) {
                                      if (valore == null || valore.isEmpty) {
                                        return 'Reinserisci la password';
                                      }
                                      if (valore != _passwordController.text) {
                                        return 'Le password non coincidono';
                                      }
                                      return null;
                                    },
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      labelText: 'Conferma la password',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    controller: _confirmController
                                ),
                              ],
                            )
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  try {
                                    String res = await changePassword(_token!, widget.utente?.mail, _passwordController.text);
                                    Utils.showSnackBar(context, 'PASSWORD MODIFICATA', res, false);
                                    Navigator.of(context).pop();
                                  } on HttpException catch (e) {
                                    await _prefs.clear();
                                    Utils.showSnackBar(context, 'ERRORE', e.message, true);
                                    Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) => const LoginPage()),
                                            (Route<dynamic> route) => false);
                                  } on Exception catch (e) {
                                    Utils.showSnackBar(context, 'ERRORE', e.toString(), true);
                                    Navigator.of(context).pop();
                                  }
                                }
                              },
                              child: const Text('Conferma')
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }
}
