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

    initAreas();
  }

  void initAreas() async {
    List<Area> tmp;
    try {
      tmp = await getAllAreas(_token!);
    } on Exception catch (e) {
      Utils.showSnackBar(context, 'ERRORE', e.toString(), true);
      return;
    }

    setState(() {
      aree = tmp;
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
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                        child: Text('Le tue aree',
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
                                );
                              },
                            ),
                          ),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AddAreaDialog extends StatefulWidget {
  final TextEditingController valueController;
  final VoidCallback addArea;
  final String token;
  const AddAreaDialog({super.key, required this.valueController, required this.addArea, required this.token});

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
                  print(res);
                  Utils.showSnackBar(context, 'AREA AGGIUNTA', res, false);
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