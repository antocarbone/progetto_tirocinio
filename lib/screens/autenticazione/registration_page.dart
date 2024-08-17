import 'dart:io';

import 'package:dashboard_tirocinio/presentation/custom_components.dart';
import 'package:dashboard_tirocinio/screens/autenticazione/login_page.dart';
import 'package:dashboard_tirocinio/screens/dashboard/home_page.dart';
import 'package:dashboard_tirocinio/screens/impostazioni/settings_page.dart';
import 'package:dashboard_tirocinio/screens/impostazioni/users_manage_page.dart';
import 'package:dashboard_tirocinio/utility/api_helper.dart';
import 'package:dashboard_tirocinio/utility/utils.dart';
import 'package:email_validator/email_validator.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/material.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _firstNumberController = TextEditingController();
  final _secondNumberController = TextEditingController();
  final _mailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isAdmin = false;
  bool _isObscured = true;

  late EncryptedSharedPreferences _prefs;
  String? _token;

  void initPreferences() async {
    EncryptedSharedPreferences tmp;
    String? tmpToken = '';
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

    setState(() {
      _token = tmpToken!;
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
        title: const Text('Registrazione'),
      ),

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
                maxWidth: 500
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: SingleChildScrollView(
                child: Card(
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Registra un nuovo utente', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                        Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: Form(
                            key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  MyTextField(
                                      validator: (valore) {
                                        if (valore == null || valore.isEmpty) {
                                          return 'Inserisci un nome!';
                                        }
                                        if(valore.length > 15) {
                                          return 'Massimo 20 caratteri!';
                                        }
                                        return null;
                                      },
                                      hint: 'Nome',
                                      controller: _nameController,
                                      onlyNumbers: false
                                  ),
                                  MyTextField(
                                      validator: (valore) {
                                        if (valore == null || valore.isEmpty) {
                                          return 'Inserisci un cognome!';
                                        }
                                        if(valore.length > 15) {
                                          return 'Massimo 20 caratteri!';
                                        }
                                        return null;
                                      },
                                      hint: 'Cognome',
                                      controller: _surnameController,
                                      onlyNumbers: false
                                  ),
                                  MyTextField(
                                      validator: (valore) {
                                        if (valore == null || valore.isEmpty) {
                                          return 'Inserisci un contatto!';
                                        }
                                        if(valore.length != 10) {
                                          return 'Inserisci un contatto valido!\n(10 cifre)';
                                        }
                                        return null;
                                      },
                                      hint: 'Contatto principale',
                                      controller: _firstNumberController,
                                      onlyNumbers: true
                                  ),
                                  MyTextField(
                                      validator: (valore) {
                                        if (valore != null && valore.isNotEmpty) {
                                          if(valore.length != 10) {
                                            return 'Inserisci un contatto valido!\n(10 cifre)';
                                          }
                                        }
                                        return null;
                                      },
                                      hint: 'Contatto secondario (Opzionale)',
                                      controller: _secondNumberController,
                                      onlyNumbers: true
                                  ),
                                  MyTextField(
                                      validator: (valore) {
                                        if (valore == null || valore.isEmpty) {
                                          return 'Inserisci una mail!';
                                        }
                                        if (!EmailValidator.validate(valore)) {
                                          return 'Inserisci una mail valida!';
                                        }
                                        return null;
                                      },
                                      hint: 'E-Mail',
                                      controller: _mailController,
                                      onlyNumbers: false
                                  ),
                                  TextFormField(
                                      validator: (valore) {
                                        if (valore == null || valore.isEmpty) {
                                          return 'Inserisci una password!';
                                        }
                                        return null;
                                      },
                                      obscureText: _isObscured,
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        suffixIcon: IconButton(
                                            onPressed: () => setState(() {
                                              _isObscured = !_isObscured;
                                            }),
                                            icon: _isObscured ? const Icon(Icons.visibility_off) : const Icon(Icons.visibility)
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      controller: _passwordController
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        const Text('Admin: '),
                                        Switch(
                                            value: _isAdmin,
                                            onChanged: (value) {
                                              setState(() {
                                                _isAdmin = value;
                                              });
                                            }
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              )
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  try {
                                    String res = await register(_token!, _nameController.text, _surnameController.text, int.parse(_firstNumberController.text), _secondNumberController.text.isEmpty ? null:int.parse(_secondNumberController.text), _mailController.text, _passwordController.text, _isAdmin ? 'admin':'user');
                                    Utils.showSnackBar(context, 'REGISTRAZIONE EFFETTUATA', res, false);
                                    Navigator.of(
                                        context)
                                        .pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                            const HomePage()),
                                            (Route<dynamic> route) =>
                                        false);
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsPage()));
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const UsersManagePage()));
                                  } on HttpException catch (e){
                                    await _prefs.clear();
                                    Utils.showSnackBar(context, 'ERRORE', e.message, true);
                                    Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) => const LoginPage()),
                                            (Route<dynamic> route) => false);
                                  } on Exception catch (e) {
                                    Utils.showSnackBar(context, 'ERRORE', e.toString(), true);
                                    return;
                                  }
                                }
                              },
                              child: const Text('Registra')
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
      ),
    );
  }
}
