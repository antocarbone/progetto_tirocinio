import 'package:dashboard_tirocinio/presentation/custom_components.dart';
import 'package:dashboard_tirocinio/screens/dashboard/home_page.dart';
import 'package:dashboard_tirocinio/screens/impostazioni/settings_page.dart';
import 'package:dashboard_tirocinio/screens/impostazioni/users_manage_page.dart';
import 'package:dashboard_tirocinio/utility/api_helper.dart';
import 'package:dashboard_tirocinio/utility/utils.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  Utils utils = Utils();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _mailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isAdmin = false;
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent.shade200,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomRight: Radius.circular(20), bottomLeft: Radius.circular(20))),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Registrazione'),
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
                                      return null;
                                    },
                                    hint: 'Cognome',
                                    controller: _surnameController,
                                    onlyNumbers: false
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
                                  String res = await register(_nameController.text, _surnameController.text, _mailController.text, _passwordController.text, _isAdmin ? 'admin':'user');
                                  utils.showSnackBar(context, 'REGISTRAZIONE EFFETTUATA', res, false);
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
                                } on Exception catch (e) {
                                  utils.showSnackBar(context, 'ERRORE', e.toString(), true);
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
    );
  }
}
