import 'dart:io';

import 'package:dashboard_tirocinio/presentation/custom_components.dart';
import 'package:dashboard_tirocinio/screens/autenticazione/login_page.dart';
import 'package:dashboard_tirocinio/screens/impostazioni/change_mail_page.dart';
import 'package:dashboard_tirocinio/screens/impostazioni/change_password_page.dart';
import 'package:dashboard_tirocinio/utility/api_helper.dart';
import 'package:dashboard_tirocinio/utility/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:encrypt_shared_preferences/provider.dart';

class UserDetailPage extends StatefulWidget {
  final User utente;
  const UserDetailPage({super.key, required this.utente});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  List<Area> allAreas = [];
  List<Area> userAreas = [];
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
      Utils.showSnackBar(context, 'OPS',
          'Qualcosa è andato storto, effettua nuovamente il login\n$e', true);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
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
    initAreas();
  }

  void initAreas() async {
    try {
      List<Area> tmpAllAreas = await getAllAreas(_token!);
      List<Area> tmpUserAreas =
          await getAllUserAreas(_token!, widget.utente.mail);

      setState(() {
        allAreas = tmpAllAreas;
        userAreas = tmpUserAreas;
      });
    } on HttpException catch (e) {
      await _prefs.remove('token');
      await _prefs.remove('tipo');
      Utils.showSnackBar(context, 'ERRORE', e.message, true);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false);
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
        centerTitle: true,
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
            constraints: const BoxConstraints(maxWidth: 500),
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
                          child: Icon(Icons.account_circle, size: 200)),
                      Flexible(
                        flex: 2,
                        child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text(
                                '${widget.utente.nome} ${widget.utente.cognome}',
                                style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold))),
                      ),
                      Flexible(
                        flex: 1,
                        child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text(widget.utente.mail,
                                style: const TextStyle(fontSize: 20))),
                      ),
                      Flexible(
                        flex: 1,
                        child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text(
                                'contatto primario: ${widget.utente.contatti[0]}',
                                style: const TextStyle(fontSize: 20))),
                      ),
                      if (widget.utente.contatti.length == 2) ...[
                        Flexible(
                          flex: 1,
                          child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Text(
                                  'contatto secondario: ${widget.utente.contatti[1]}',
                                  style: const TextStyle(fontSize: 20))),
                        )
                      ],
                      Flexible(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: ElevatedButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return modificaVisibilitaDialog(
                                          context,
                                          allAreas,
                                          userAreas,
                                          widget.utente,
                                          _token!,
                                          _prefs);
                                    });
                              },
                              child: const Text('Modifica vista')),
                        ),
                      ),
                      Flexible(
                        flex: 2,
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      ChangeMailPage(utente: widget.utente)));
                            },
                            child: const Text('Cambia e-mail')),
                      ),
                      Flexible(
                        flex: 2,
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ChangePasswordPage(
                                      utente: widget.utente)));
                            },
                            child: const Text('Cambia password')),
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

Widget modificaVisibilitaDialog(
    BuildContext context,
    List<Area> allAreas,
    List<Area> userAreas,
    User utente,
    String token,
    EncryptedSharedPreferences prefs) {
  List<bool> isCheckedList = List.generate(
      allAreas.length, (index) => userAreas.contains(allAreas[index]));

  return StatefulBuilder(
    builder: (context, setState) {
      return AlertDialog(
        title: const Center(
          child:
              Text('Visibilità', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        content: SizedBox(
          width: kIsWeb ? 800 : double.maxFinite,
          height: kIsWeb ? 600 : 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Seleziona le aree che l\'utente può visualizzare',
                  textAlign: TextAlign.center),
              Expanded(
                child: ListView.builder(
                  itemCount: allAreas.length,
                  itemBuilder: (context, index) {
                    return MyGenericListElement(
                      leading: const Icon(Icons.room),
                      title: allAreas[index].nome,
                      trailing: Checkbox(
                        value: isCheckedList[index],
                        onChanged: (value) {
                          setState(() {
                            isCheckedList[index] = value ?? false;
                            if (isCheckedList[index]) {
                              userAreas.add(allAreas[index]);
                            } else {
                              userAreas.remove(allAreas[index]);
                            }
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () async {
                List<String> newUserAreas = [];
                for (Area area in userAreas) {
                  newUserAreas.add(area.nome);
                }
                try {
                  String res =
                      await updateUserAreas(utente.mail, newUserAreas, token);
                  Navigator.of(context).pop();
                  Utils.showSnackBar(context, 'VISTA MODIFICATA', res, false);
                } on HttpException catch (e) {
                  await prefs.remove('token');
                  await prefs.remove('tipo');
                  Utils.showSnackBar(context, 'ERRORE', e.message, true);
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                      (Route<dynamic> route) => false);
                } catch (e) {
                  Navigator.of(context).pop();
                  Utils.showSnackBar(context, 'ERRORE', e.toString(), true);
                }
              },
              child: const Text('Conferma'),
            ),
          ),
        ],
      );
    },
  );
}
