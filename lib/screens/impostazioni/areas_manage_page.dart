import 'package:dashboard_tirocinio/presentation/custom_components.dart';
import 'package:dashboard_tirocinio/screens/autenticazione/login_page.dart';
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
  List<String> aree = [];
  bool _isExpanded = false;
  final Utils utils = Utils();
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
      utils.showSnackBar(context, 'OPS', 'Qualcosa è andato storto, effettua nuovamente il login\n$e', true);
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
        backgroundColor: Colors.orangeAccent.shade200,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(20))),
        title: const Text('Gestione Aree'),
        actions: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: _isExpanded ? 80 : 0,
                  child: ListView(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 10, bottom: 10, right: 5),
                          child: FittedBox(
                              child: IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.settings))),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: FittedBox(
                              child: IconButton(
                                  onPressed: () async {
                                    await _prefs.clear();
                                    Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) => const LoginPage()),
                                            (Route<dynamic> route) => false);
                                  },
                                  icon: const Icon(Icons.exit_to_app_rounded))),
                        )
                      ]),
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: MyUserButton(onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            }),
          )
        ],
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
                                  title: aree[index],
                                  trailing: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        aree.removeAt(index);
                                      });
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
                                      valueController: _valueController,
                                      addNotifica: (String nome) {
                                        setState(() {
                                          aree.add(nome);
                                        });
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
  final void Function(String nome) addNotifica;
  const AddAreaDialog({super.key, required this.valueController, required this.addNotifica});

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
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                widget.addNotifica(widget.valueController.text);
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