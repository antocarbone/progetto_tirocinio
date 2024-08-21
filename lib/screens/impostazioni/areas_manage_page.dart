import 'dart:io';

import 'package:dashboard_tirocinio/presentation/custom_components.dart';
import 'package:dashboard_tirocinio/screens/autenticazione/login_page.dart';
import 'package:dashboard_tirocinio/utility/api_helper.dart';
import 'package:dashboard_tirocinio/utility/utils.dart';
import 'package:flutter/material.dart';
import 'package:encrypt_shared_preferences/provider.dart';

class AreasManagePage extends StatefulWidget {
  const AreasManagePage({super.key});

  @override
  State<AreasManagePage> createState() => _AreasManagePageState();
}

class _AreasManagePageState extends State<AreasManagePage> {
  final TextEditingController _valueController = TextEditingController();
  List<Area> aree = [];
  late EncryptedSharedPreferences _prefs;
  String? _token;
  bool isAreasInit = false;

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

    initAreas();
  }

  void initAreas() async {
    try {
      List<Area> tmp = await getAllAreas(_token!);

      setState(() {
        aree = tmp;
        isAreasInit = true;
      });
    } on HttpException catch (e) {
      await _prefs.clear();
      Utils.showSnackBar(context, 'ERRORE', e.message, true);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => const LoginPage()),
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
        title: const Text('Gestione Aree'),
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
                  if (!isAreasInit ) ... [
                    const CircularProgressIndicator()
                  ] else if(aree.isNotEmpty) ... [const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                        child: Text('Le tue aree',
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold))),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: aree.length,
                      itemBuilder: (context, index) {
                        return MyGenericListElement(
                          leading: const Icon(Icons.room),
                          title: aree[index].nome,
                          trailing: IconButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return ConfirmDelete(onConfirm: () async {
                                      try {
                                        String res = await deleteArea(aree[index].nome, _token!);
                                        Utils.showSnackBar(context, 'AREA ELIMINATA', res, false);
                                        Navigator.of(context).pop();
                                        initAreas();
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
                                    });
                                  }
                              );
                            },
                            icon: const Icon(Icons.delete_rounded),
                          ),
                        );
                      },
                    ),
                  )] else ... [
                    const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: Text('Non sono presenti aree'),
                        )
                    )
                  ],
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AddAreaDialog(
                              token: _token!,
                              valueController: _valueController,
                              addArea: () {
                                initAreas();
                              },
                              prefs: _prefs,
                            );
                          },
                        );
                      },
                      child: const Text('Aggiungi un\'area'),
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

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }
}

class AddAreaDialog extends StatefulWidget {
  final TextEditingController valueController;
  final VoidCallback addArea;
  final String token;
  final EncryptedSharedPreferences prefs;
  const AddAreaDialog({super.key, required this.valueController, required this.addArea, required this.token, required this.prefs});

  @override
  State<AddAreaDialog> createState() => _AddAreaDialogState();
}

class _AddAreaDialogState extends State<AddAreaDialog> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
          child: Text('Dai un nome all\'area',
              style: TextStyle(fontWeight: FontWeight.bold))),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Form(
                key: _formKey,
                child: MyTextField(
                  validator: (valore) {
                    if (valore == null || valore.isEmpty) {
                      return 'Inserisci un nome!';
                    }
                    if(valore.length > 20) {
                      return 'Massimo 20 caratteri!';
                    }
                    return null;
                  },
                  hint: 'Inserisci qui il nome',
                  controller: widget.valueController,
                  onlyNumbers: false,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Center(
          child: ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  String res = await addArea(widget.valueController.text  , widget.token);
                  Utils.showSnackBar(context, 'AREA AGGIUNTA', res, false);
                } on HttpException catch (e) {
                  await widget.prefs.clear();
                  Utils.showSnackBar(context, 'ERRORE', e.message, true);
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                          (Route<dynamic> route) => false);
                } on Exception catch (e) {
                  Utils.showSnackBar(context, 'ERRORE', e.toString(), true);
                }
                widget.addArea();
                Navigator.of(context).pop();
              }
            },
            child: const Text('Aggiungi'),
          ),
        ),
      ],
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