import 'package:dashboard_tirocinio/screens/autenticazione/login_page.dart';
import 'package:dashboard_tirocinio/screens/impostazioni/change_password_page.dart';
import 'package:dashboard_tirocinio/utility/api_helper.dart';
import 'package:dashboard_tirocinio/utility/utils.dart';
import 'package:flutter/material.dart';
import 'package:encrypt_shared_preferences/provider.dart';

class UserDetailPage extends StatefulWidget {
  final User utente;
  const UserDetailPage({super.key, required this.utente});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  late EncryptedSharedPreferences _prefs;
  String? _token;
  String? _userType;

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
        backgroundColor: Colors.orangeAccent.shade200,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomRight: Radius.circular(20), bottomLeft: Radius.circular(20))),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.utente.mail),
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
                      const Flexible(
                        flex: 5,
                          child: Icon(Icons.account_circle, size: 200)
                      ),
                      Flexible(
                        flex: 2,
                        child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text('${widget.utente.nome} ${widget.utente.cognome}',
                                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
                      ),
                      Flexible(
                        flex: 1,
                        child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text(widget.utente.mail, style: const TextStyle(fontSize: 20))),
                      ),
                      Flexible(
                        flex: 1,
                        child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text('contatto primario: ${widget.utente.contatti[0]}', style: const TextStyle(fontSize: 20))),
                      ),
                      if (widget.utente.contatti.length == 2) ... [Flexible(
                        flex: 1,
                        child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text('contatto secondario: ${widget.utente.contatti[1]}', style: const TextStyle(fontSize: 20))),
                      )],
                      Flexible(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: ElevatedButton(
                              onPressed: () {},
                              child: const Text('Modifica vista')
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 2,
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChangePasswordPage(utente: widget.utente)));
                            },
                            child: const Text('Cambia password')
                        ),
                      ),
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
