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
  const DettaglioAreaPage({super.key});

  @override
  State<DettaglioAreaPage> createState() => _DettaglioAreaPageState();
}

class _DettaglioAreaPageState extends State<DettaglioAreaPage> {
  final _qrBarCodeScannerDialogPlugin = QrBarCodeScannerDialog();
  final Utils utils = Utils();

  double defaultPadding = 12;
  bool _isExpanded = false;

  List<Sensor> sensors = [
    Sensor(id: 0, nome: 'temp1', unitaMisura: '°C', lettura: 32.5),
    Sensor(id: 1, nome: 'temp2', unitaMisura: '°C', lettura: 32.5),
    Sensor(id: 2, nome: 'temp3', unitaMisura: '°C', lettura: 32.5),
    Sensor(id: 3, nome: 'temp4', unitaMisura: '°C', lettura: 32.5),
  ];

  List<BinarySensor> binarySensors = [
    BinarySensor(id: 0, nome: 'presenza1', valore: true, deviceClass: 'deviceClass', stringaTrue: 'presente', stringaFalse: 'non presente', codiceIcona: 'motion'),
    BinarySensor(id: 1, nome: 'presenza2', valore: true, deviceClass: 'deviceClass', stringaTrue: 'presente', stringaFalse: 'non presente', codiceIcona: 'motion'),
    BinarySensor(id: 2, nome: 'presenza3', valore: true, deviceClass: 'deviceClass', stringaTrue: 'presente', stringaFalse: 'non presente', codiceIcona: 'motion'),
    BinarySensor(id: 3, nome: 'presenza4', valore: true, deviceClass: 'deviceClass', stringaTrue: 'presente', stringaFalse: 'non presente', codiceIcona: 'motion'),
  ];

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
        title: const Text('Area 1'),
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
                          padding: const EdgeInsets.only(top: 10, bottom: 10, right: 5),
                          child: FittedBox(child: IconButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsPage()));
                                },
                              icon: const Icon(Icons.settings))
                          )
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: FittedBox(child: IconButton(
                              onPressed: () async {
                                await _prefs.clear();
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
              setState(() {
                _isExpanded = !_isExpanded;
              });
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
                if (!kIsWeb) ...[
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
                              utils.showSnackBar(context, 'OPS', 'QR code non valido!', true);
                              return;
                            }

                            if (nodeData['name'] == null || nodeData['pop'] == null) {
                              utils.showSnackBar(context, 'OPS', 'QR code non valido!', true);
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
                    child: const ListTile(leading: Icon(Icons.home), title: Center(child: Text('Home'))))
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Center(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 1200,
                  mainAxisExtent: kIsWeb ? 300 : 200,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 20
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return GridTile(
                  child: FittedBox(child: MyNodeSummary(
                    nodeName: 'Sicurezza',
                    nodeStatus: 'online',
                    sensors: sensors,
                    binarySensors: binarySensors,
                  )
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}