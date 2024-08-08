import 'package:dashboard_tirocinio/presentation/custom_components.dart';
import 'package:dashboard_tirocinio/screens/autenticazione/login_page.dart';
import 'package:dashboard_tirocinio/screens/autenticazione/registration_page.dart';
import 'package:dashboard_tirocinio/screens/impostazioni/user_detail_page.dart';
import 'package:dashboard_tirocinio/utility/api_helper.dart';
import 'package:dashboard_tirocinio/utility/utils.dart';
import 'package:flutter/material.dart';
import 'package:encrypt_shared_preferences/provider.dart';

class UsersManagePage extends StatefulWidget {
  const UsersManagePage({super.key});

  @override
  State<UsersManagePage> createState() => _UsersManagePageState();
}

class _UsersManagePageState extends State<UsersManagePage> {
  List<User> utenti = [];
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
    initUtenti();
  }

  void initUtenti() async {
    List<User> tmpUtenti;
    try {
      tmpUtenti = await getAllUsers(_token!);
    } on Exception catch (e) {
      Utils.showSnackBar(context, 'ERRORE', e.toString(), true);
      return;
    }

    setState(() {
      utenti = tmpUtenti;
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
        backgroundColor: Colors.orangeAccent.shade200,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(20))),
        title: const Text('Gestione Utenti'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                        child: Text('Utenti registrati',
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold))),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: utenti.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => UserDetailPage(utente: utenti[index])));
                                  },
                                  child: MyGenericListElement(
                                    leading: const Icon(Icons.person),
                                    title: '${utenti[index].nome} ${utenti[index].cognome}',
                                    subtitle: utenti[index].mail,
                                    trailing: IconButton(
                                      onPressed: () {
                                          showDialog(
                                              context: context, 
                                              builder: (context) {
                                                return ConfirmDelete(onConfirm: () async {
                                                  try {
                                                    String res = await deleteUser(_token!, utenti[index].mail);
                                                    Utils.showSnackBar(context, 'UTENTE ELIMINATO', res, false);
                                                    Navigator.of(context).pop();
                                                    setState(() {utenti.removeAt(index);});
                                                  } catch (e) {
                                                    Utils.showSnackBar(context, 'ERRORE', e.toString(), true);
                                                    Navigator.of(context).pop();
                                                  }
                                                });
                                              }
                                          );
                                      },
                                      icon: const Icon(Icons.delete_rounded),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(
                                    context)
                                    .push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                        const RegistrationPage()));
                              },
                              child: const Text('Registra un nuovo utente'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ConfirmDelete extends StatelessWidget {
  final VoidCallback onConfirm;
  const ConfirmDelete({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
          child: Text('Conferma', style: TextStyle(fontWeight: FontWeight.bold))
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancella')
            ),
            ElevatedButton(
                onPressed: onConfirm,
                child: const Text('Conferma')
            ),
          ],
        )
      ],
    );
  }
}
