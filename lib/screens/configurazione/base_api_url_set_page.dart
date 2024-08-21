import 'package:dashboard_tirocinio/screens/autenticazione/login_page.dart';
import 'package:dashboard_tirocinio/utility/api_helper.dart';
import 'package:dashboard_tirocinio/utility/utils.dart';
import 'package:flutter/material.dart';
import 'package:encrypt_shared_preferences/provider.dart';

class BaseApiUrlSetPage extends StatefulWidget {
  const BaseApiUrlSetPage({super.key});

  @override
  State<BaseApiUrlSetPage> createState() => _BaseApiUrlSetPageState();
}

class _BaseApiUrlSetPageState extends State<BaseApiUrlSetPage> {
  late EncryptedSharedPreferences _prefs;
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();

  void initPreferences() async {
    EncryptedSharedPreferences tmp;
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
            Text('Base Api Url'),
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
                      const FittedBox(child: Text('Inserisci il base url dell\'api', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
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
                                          return 'Inserisci l\'URL';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'URL',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      controller: _urlController
                                  ),
                                )
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
                                    if (await _prefs.setString('url', _urlController.text)) {
                                      await checkBaseUrl();
                                      Utils.showSnackBar(context, 'BASE URL IMPOSTATO', 'Procedi al log-In', false);
                                      Navigator.of(context).pushAndRemoveUntil(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const LoginPage()),
                                          (Route<dynamic> route) => false);
                                    } else {
                                      Utils.showSnackBar(context, 'ERRORE', 'Riavvia l\'app e riprova!', true);
                                    }
                                  } on Exception catch (e) {
                                    await _prefs.remove('url');
                                    Utils.showSnackBar(context, 'ERRORE', e.toString(), true);
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
    _urlController.dispose();
    super.dispose();
  }
}
