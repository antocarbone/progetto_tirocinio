import 'package:dashboard_tirocinio/presentation/custom_components.dart';
import 'package:dashboard_tirocinio/screens/dashboard/home_page.dart';
import 'package:dashboard_tirocinio/utility/api_helper.dart';
import 'package:dashboard_tirocinio/utility/utils.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:encrypt_shared_preferences/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Utils utils = Utils();
  late EncryptedSharedPreferences _prefs;
  final _formKey = GlobalKey<FormState>();
  final _mailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscured = true;

  void initPreferences() async {
    try {
      await EncryptedSharedPreferences.initialize(Utils.encryptingKey);
      EncryptedSharedPreferences tmp = EncryptedSharedPreferences.getInstance();
      setState(() {
        _prefs = tmp;
      });
    } catch (e) {
      utils.showSnackBar(context, 'ERRORE', 'Errore durante l\'inizializzazione delle preferenze crittografate: $e', true);
    }
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
        backgroundColor: Colors.orangeAccent.shade200,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomRight: Radius.circular(20), bottomLeft: Radius.circular(20))),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('LogIn'),
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
                      const Text('Accedi', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
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
                                    AuthUser loginData = await logIn(_mailController.text, _passwordController.text);
                                    if(await _prefs.setString('token', loginData.token, notify: false) && await _prefs.setString('tipo', loginData.isAdmin, notify: false)) {
                                      Navigator.of(
                                          context)
                                          .pushAndRemoveUntil(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                              const HomePage()),
                                              (Route<dynamic> route) =>
                                          false);
                                    }
                                  } on Exception catch (e) {
                                    utils.showSnackBar(context, 'ERRORE', e.toString(), true);
                                    return;
                                  }
                                }
                              },
                              child: const Text('LogIn')
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
}
