import 'dart:io';

import 'package:dashboard_tirocinio/screens/autenticazione/login_page.dart';
import 'package:dashboard_tirocinio/screens/dashboard/home_page.dart';
import 'package:dashboard_tirocinio/screens/impostazioni/settings_page.dart';
import 'package:dashboard_tirocinio/screens/configurazione/ble_connection_dialog.dart';
import 'package:dashboard_tirocinio/utility/api_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:qr_bar_code_scanner_dialog/qr_bar_code_scanner_dialog.dart';
import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';
import 'dart:convert';

import 'package:dashboard_tirocinio/presentation/custom_components.dart';
import 'package:dashboard_tirocinio/utility/utils.dart';
import 'package:encrypt_shared_preferences/provider.dart';

class DettaglioAreaPage extends StatefulWidget {
  final Area area;
  const DettaglioAreaPage({super.key, required this.area});

  @override
  State<DettaglioAreaPage> createState() => _DettaglioAreaPageState();
}

class _DettaglioAreaPageState extends State<DettaglioAreaPage> {
  final _qrBarCodeScannerDialogPlugin = QrBarCodeScannerDialog();

  double defaultPadding = 12;
  bool _isExpanded = false;

  List<Area> userAreas = [];
  List<Nodo> areaNodes = [];
  List<Map<String, dynamic>> nodeSensors = [];

  late EncryptedSharedPreferences _prefs;
  bool isPrefsInit = false;
  bool isNodesInit = false;
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

    if (mounted) {
      setState(() {
        _prefs = tmp;
      });
    }

    tmpToken = _prefs.getString('token');
    tmpType = _prefs.getString('tipo');

    if (mounted) {
      setState(() {
        _token = tmpToken!;
        _userType = tmpType!;
        isPrefsInit = true;
      });
    }

    initUserAreas();
  }

  void initUserAreas() async {
    try {
      List<Area> tmp = await getAllUserAreas(_token!);
      if (mounted) {
        setState(() {
          userAreas = tmp;
        });
      }
    } on HttpException catch (e) {
      await _prefs.clear();
      Utils.showSnackBar(context, 'ERRORE', e.message, true);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => const LoginPage()),
              (Route<dynamic> route) => false);
    }
    initAreaNodes();
  }

  void initAreaNodes() async {
    try {
      List<Nodo> tmp = await getAllAreaNodes(widget.area.nome, _token!);
      if (mounted) {
        setState(() {
          areaNodes = tmp;
        });
      }
    } on HttpException catch (e) {
      await _prefs.clear();
      Utils.showSnackBar(context, 'ERRORE', e.message, true);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => const LoginPage()),
              (Route<dynamic> route) => false);
    }
    initNodeSensors();
  }

  void initNodeSensors() async {
    List<Map<String, dynamic>> tmpNodeSensors = [];
    try {
      for(Nodo nodo in areaNodes) {
        tmpNodeSensors.add(await getAllNodeSensors(nodo.id, _token!));
      }
      if (mounted) {
        setState(() {
          nodeSensors = tmpNodeSensors;
          isNodesInit = true;
        });
      }
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
        title: Text(widget.area.nome),
        actions: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: _isExpanded ? isPrefsInit && _userType == 'admin' ? 80 : 40 : 0,
                  child: ListView(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      children: [
                        if (_userType == 'admin') ... [Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 10, right: 5),
                            child: FittedBox(child: IconButton(
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsPage()));
                                },
                                icon: const Icon(Icons.settings))
                            )
                        )],
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: FittedBox(child: IconButton(
                              onPressed: () async {
                                await _prefs.remove('token');
                                await _prefs.remove('tipo');
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) => const LoginPage()),
                                        (Route<dynamic> route) => false);
                              },
                              icon: const Icon(Icons.exit_to_app_rounded))),
                        )
                      ]
                  ),
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: MyUserButton(onPressed: () {
              if (mounted) {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              }
            }),
          )
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text('Menu', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                if (isPrefsInit && !kIsWeb && _userType == "admin") ...[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _qrBarCodeScannerDialogPlugin.getScannedQrBarCode(
                          context: context,
                          onCode: (code) {
                            final Map<String, dynamic> nodeData;

                            try {
                              nodeData = json.decode(code!);
                            } catch (e) {
                              Utils.showSnackBar(context, 'OPS', 'QR code non valido!', true);
                              return;
                            }

                            if (nodeData['name'] == null || nodeData['pop'] == null) {
                              Utils.showSnackBar(context, 'OPS', 'QR code non valido!', true);
                              return;
                            } else {
                              BluetoothEnable.enableBluetooth.then((result) {
                                if (result == "false") {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return BleConnectionDialog(nodeData: nodeData);
                                    },
                                  );
                                }
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return BleConnectionDialog(nodeData: nodeData);
                                  },
                                );
                              });
                            }
                          });
                    },
                    child: const ListTile(
                        leading: Icon(Icons.qr_code_scanner_rounded),
                        title:
                        FittedBox(child: Text('Aggiungi un dispositivo'))),
                  ),
                  const Divider(),
                ],
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const HomePage()),
                              (Route<dynamic> route) => false);
                    },
                    child: const ListTile(leading: Icon(Icons.home), title: Center(child: Text('Home')))
                ),
                const Divider(),
                Flexible(
                  flex: 6,
                  child: ListView.builder(
                    itemCount: userAreas.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: ElevatedButton(
                            autofocus: (widget.area.nome == userAreas[index].nome),
                            onPressed: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => DettaglioAreaPage(area: userAreas[index])),
                                      (Route<dynamic> route) => false);
                            },
                            child: ListTile(title: Center(child: Text(userAreas[index].nome)))
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Center(
            child: !isNodesInit ? const CircularProgressIndicator() : areaNodes.isNotEmpty ? GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 1200,
                  mainAxisExtent: kIsWeb ? 300 : 200,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 20
              ),
              itemCount: areaNodes.length,
              itemBuilder: (context, index) => GridTile(
                child: FittedBox(child: MyNodeSummary(
                  nodo: areaNodes[index],
                  sensors: nodeSensors.isEmpty ? [] : nodeSensors[index]['sensors'],
                  binarySensors: nodeSensors.isEmpty ? [] : nodeSensors[index]['binary_sensors'],
                  token: _token!,
                  onCancel: () async {
                    try {
                      String res = await deleteNode(areaNodes[index].id, _token!);
                      Utils.showSnackBar(context, 'NODO ELIMINATO', res, false);
                      Navigator.of(context).pop();
                      initAreaNodes();
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
                  },
                )
                ),
              ),
            ) : const Text('Nessun nodo è collegato a quest\'area\nUsa la versione android dell\'app per aggiungerne uno', textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}