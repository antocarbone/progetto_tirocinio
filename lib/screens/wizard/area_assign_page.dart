import 'dart:io';

import 'package:dashboard_tirocinio/screens/autenticazione/login_page.dart';
import 'package:dashboard_tirocinio/screens/wizard/node_init_page.dart';
import 'package:dashboard_tirocinio/utility/api_helper.dart';
import 'package:dashboard_tirocinio/utility/utils.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/material.dart';

class AreaAssignPage extends StatefulWidget {
  final Map<String, dynamic> nodeData;
  final Map<String, dynamic> deviceInfos;

  const AreaAssignPage(
      {super.key, required this.nodeData, required this.deviceInfos});

  @override
  State<AreaAssignPage> createState() => _AreaAssignPageState();
}

class _AreaAssignPageState extends State<AreaAssignPage> {
  List<Area> aree = [];
  String? selectedValue;
  late EncryptedSharedPreferences _prefs;
  String? _token;

  void initPreferences() async {
    EncryptedSharedPreferences tmp;
    String? tmpToken = '';
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
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Assegnazione area'),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Center(
            child: Card(
              elevation: 12,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child:
                          Text('Scegli l\'area alla quale assegnare il nodo'),
                    ),
                    DropdownButton<String>(
                      value: selectedValue,
                      onChanged: (selected) {
                        setState(() {
                          selectedValue = selected;
                        });
                      },
                      items: aree.map(
                        (item) {
                          return DropdownMenuItem(
                            value: item.nome,
                            child: Text(item.nome),
                          );
                        },
                      ).toList(),
                      hint: const Text('Select an area'),
                      icon: const Icon(Icons.arrow_drop_down),
                      iconSize: 42,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => NodeInitPage(
                              nodeData: widget.nodeData,
                              deviceInfos: widget.deviceInfos,
                              nodeArea: selectedValue ?? aree[1].nome,
                            ),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      },
                      child: const Text('Continua'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
