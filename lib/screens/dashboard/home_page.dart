import 'dart:io';

import 'package:dashboard_tirocinio/screens/autenticazione/login_page.dart';
import 'package:dashboard_tirocinio/screens/impostazioni/settings_page.dart';
import 'package:dashboard_tirocinio/screens/configurazione/ble_connection_dialog.dart';
import 'package:dashboard_tirocinio/utility/api_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

import 'package:qr_bar_code_scanner_dialog/qr_bar_code_scanner_dialog.dart';
import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';

import 'package:dashboard_tirocinio/presentation/custom_components.dart';
import 'package:dashboard_tirocinio/screens/dashboard/dettaglio_area_page.dart';
import 'package:dashboard_tirocinio/utility/utils.dart';
import 'package:encrypt_shared_preferences/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _qrBarCodeScannerDialogPlugin = QrBarCodeScannerDialog();
  bool _isExpanded = false;
  late EncryptedSharedPreferences _prefs;
  String? _token;
  String? _userType;
  List<Area> userAreas = [];
  List<dynamic> offlineNodes = [];

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
      });
    }
    await initUserAreas();
  }

  Future<void> initUserAreas() async {
    List<Area> tmp;
    try {
      tmp = await getAllUserAreas(_token!, null);
      if (mounted) {
        setState(() {
          userAreas = tmp;
        });
      }
    } on HttpException catch (e) {
      await _prefs.remove('token');
      await _prefs.remove('tipo');
      Utils.showSnackBar(context, 'ERRORE', e.message, true);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false);
    }
    await initOfflineNodes();
  }

  Future<void> initOfflineNodes() async {
    try {
      List<dynamic> tmpOfflineNodes = await getAllUserOfflineNodes(_token!);
      setState(() {
        offlineNodes = tmpOfflineNodes;
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
        title: const Text('Home'),
        actions: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: _isExpanded
                      ? _userType == 'admin'
                          ? 80
                          : 40
                      : 0,
                  child: ListView(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      children: [
                        if (_userType == 'admin') ...[
                          Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, bottom: 10, right: 5),
                              child: FittedBox(
                                  child: IconButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const SettingsPage()));
                                      },
                                      icon: const Icon(Icons.settings))))
                        ],
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: FittedBox(
                              child: IconButton(
                                  onPressed: () async {
                                    await _prefs.remove('token');
                                    await _prefs.remove('tipo');
                                    Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginPage()),
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
                const Text('Menu',
                    style:
                        TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                if (!kIsWeb && _userType == "admin") ...[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _qrBarCodeScannerDialogPlugin.getScannedQrBarCode(
                          context: context,
                          onCode: (code) {
                            final Map<String, dynamic> nodeData;

                            try {
                              nodeData = json.decode(code!);
                            } on Exception catch (e) {
                              Utils.showSnackBar(
                                  context, 'OPS', 'QR code non valido!', true);
                              return;
                            }

                            if (nodeData['name'] == null ||
                                nodeData['pop'] == null) {
                              Utils.showSnackBar(
                                  context, 'OPS', 'QR code non valido!', true);
                              return;
                            } else {
                              BluetoothEnable.enableBluetooth.then((result) {
                                if (result == "false") {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return BleConnectionDialog(
                                          nodeData: nodeData);
                                    },
                                  );
                                }
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return BleConnectionDialog(
                                        nodeData: nodeData);
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
                Flexible(
                  flex: 6,
                  child: RefreshIndicator(
                    onRefresh: () async {
                      return await initUserAreas();
                    },
                    child: ListView.builder(
                      itemCount: userAreas.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) => DettaglioAreaPage(
                                            area: userAreas[index])),
                                    (Route<dynamic> route) => false);
                              },
                              child: ListTile(
                                  title: Center(
                                      child: Text(userAreas[index].nome)))),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            return await initOfflineNodes();
          },
          child: ListView(
            scrollDirection: Axis.vertical,
            children: [Padding(
              padding: const EdgeInsets.all(12),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 800,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyGenericListElement(
                        leading: offlineNodes.isEmpty
                            ? const Icon(Icons.wifi)
                            : const Icon(Icons.wifi_off_rounded),
                        title: offlineNodes.isNotEmpty
                            ? '${offlineNodes.length} ${offlineNodes.length == 1 ? 'Nodo':'Nodi'} Offline'
                            : 'Tutti i nodi sono online o in stato sconosciuto',
                      ),
                      if (offlineNodes.isNotEmpty) ...[
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 600,
                          ),
                          child: Card(
                            elevation: 10,
                            child: Padding(
                              padding: const EdgeInsets.all(25),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Expanded(
                                    child: RefreshIndicator(
                                      onRefresh: () async {
                                        await initUserAreas();
                                        await initOfflineNodes();
                                      },
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: offlineNodes.length,
                                        itemBuilder: (context, index) {
                                          return MyGenericListElement(
                                            title: offlineNodes[index]['node_name'],
                                            subtitle: offlineNodes[index]
                                                ['area_name'],
                                            leading: const Icon(Icons.room),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ],
                  ),
                ),
              ),
            )],
          ),
        ),
      ),
    );
  }
}
