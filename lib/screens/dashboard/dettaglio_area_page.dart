import 'package:dashboard_tirocinio/screens/impostazioni/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:qr_bar_code_scanner_dialog/qr_bar_code_scanner_dialog.dart';
import 'package:flutter_esp_ble_prov/flutter_esp_ble_prov.dart';
import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';
import 'dart:convert';

import 'package:dashboard_tirocinio/presentation/custom_components.dart';
import 'package:dashboard_tirocinio/screens/configurazione/node_init_page.dart';
import 'package:dashboard_tirocinio/utility/utils.dart';
import 'package:dashboard_tirocinio/screens/dashboard/home_page.dart';

class DettaglioAreaPage extends StatefulWidget {
  const DettaglioAreaPage({super.key});

  @override
  State<DettaglioAreaPage> createState() => _DettaglioAreaPageState();
}

class _DettaglioAreaPageState extends State<DettaglioAreaPage> {
  final _qrBarCodeScannerDialogPlugin = QrBarCodeScannerDialog();
  final _flutterEspBleProvPlugin = FlutterEspBleProv();
  final Utils utils = Utils();

  double defaultPadding = 12;
  bool _isExpanded = false;
  bool? _deviceScanned;
  bool? _deviceConnected;
  bool? _gotInfos;
  bool? _brokerDataSent;

  Map<String, dynamic>? _deviceInfos;


  Future<bool> scanBleDevices(String name) async {
    final device = name;
    final List<String> scannedDevices;
    try {
      scannedDevices = await _flutterEspBleProvPlugin.scanBleDevices(device);
    } on Exception catch (e) {
      setState(() {
        _deviceScanned = false;
      });
      return false;
    }

    if (scannedDevices.isNotEmpty) {
      setState(() {
        _deviceScanned = true;
      });
      return true;
    } else {
      setState(() {
        _deviceScanned = false;
      });
      return false;
    }
  }

  Future<bool> connectBleDevice(String name, String pop) async {
    try {
      await _flutterEspBleProvPlugin.connectBleDevice(name, pop);
    } on Exception catch (e) {
      setState(() {
        _deviceConnected = false;
      });
      return false;
    }
    setState(() {
      _deviceConnected = true;
    });
    return true;
  }

  Future<bool> getDeviceInfos(String name, String pop) async {
    String? res;
    try {
      res = await _flutterEspBleProvPlugin.sendCustomData(
          'get-device-info',
          '',
          name,
          pop);
    } on Exception catch (e) {
      setState(() {
        _gotInfos = false;
      });
      return false;
    }
    if(res != null) {
      Map<String, dynamic> resJson = json.decode(res);
      if(resJson['status'] == 'success') {
        setState(() {
          _gotInfos = true;
          _deviceInfos = resJson;
        });
        return true;
      } else {
        setState(() {
          _gotInfos = false;
        });
        return false;
      }
    } else {
      setState(() {
        _gotInfos = false;
      });
      return false;
    }
  }

  Future<bool> sendBrokerData(String name, String pop) async {
    String? res;
    try {
      res = await _flutterEspBleProvPlugin.sendCustomData(
          'mqtt-data',
          '{"broker":"mqtt://cavuotohome.duckdns.org","username":"iot","password":"iotunisa","port":1883}',
          name,
          pop);
    } on Exception catch (e) {
      setState(() {
        _brokerDataSent = false;
      });
      return false;
    }
    if(res != null) {
      if(json.decode(res)['status'] == 'success') {
        setState(() {
          _brokerDataSent = true;
        });
        return true;
      } else {
        setState(() {
          _brokerDataSent = false;
        });
        return false;
      }
    } else {
      setState(() {
        _brokerDataSent = false;
      });
      return false;
    }
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
                          child: FittedBox(child: IconButton(onPressed: () {}, icon: const Icon(Icons.exit_to_app_rounded))),
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
                                      return AlertDialog(
                                        title: const Row(
                                          children: [
                                            Icon(Icons.warning),
                                            Center(child: Text('Attenzione!'))
                                          ],
                                        ),
                                        content: const Text(
                                            'Accendi il bluetooth prima di proseguire!',
                                            style: TextStyle(fontSize: 10),
                                            textAlign: TextAlign.center),
                                        actions: <Widget>[
                                          Center(
                                            child: ElevatedButton(
                                              child: const Text('Procedi'),
                                              onPressed: () async {
                                                Navigator.of(context).pop();

                                                _showInitializationDialog(nodeData);
                                              },
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                                _showInitializationDialog(nodeData);
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
                              builder: (context) => DettaglioAreaPage()),
                              (Route<dynamic> route) => false);
                    },
                    child: const ListTile(title: Center(child: Text('Area 1'))))
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
                return const GridTile(
                  child: FittedBox(child: MyNodeSummary(nodeName: 'Sicurezza')),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildStatusIndicator({
    required bool? status,
    required String inProgressMessage,
    required String successMessage,
    required String failureMessage,
    required Future<bool> futureFunction,
  }) {
    if (status == null) {
      return FutureBuilder(
        future: futureFunction,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return RowStatusIndicator(
              indicator: const CircularProgressIndicator(color: Colors.black),
              info: inProgressMessage,
            );
          } else if (snapshot.hasData && snapshot.data == true) {
            return RowStatusIndicator(
              indicator: const Material(child: Icon(Icons.check_circle)),
              info: successMessage,
            );
          } else {
            return RowStatusIndicator(
              indicator: const Icon(Icons.error_rounded),
              info: failureMessage,
            );
          }
        },
      );
    } else if (status == true) {
      return RowStatusIndicator(
        indicator: const Material(child: Icon(Icons.check_circle)),
        info: successMessage,
      );
    } else {
      return RowStatusIndicator(
        indicator: const Icon(Icons.error_rounded),
        info: failureMessage,
      );
    }
  }

  void _showInitializationDialog(Map<String, dynamic> nodeData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(

          title: const Center(
            child: FittedBox(
              child: Text('Inizializzazione dispositivo',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ),

          content: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildStatusIndicator(
                status: _deviceScanned,
                inProgressMessage: 'Sto cercando il device...',
                successMessage: 'Dispositivo trovato!',
                failureMessage: 'Dispositivo non trovato!',
                futureFunction: scanBleDevices(nodeData['name']),
              ),
              if (_deviceScanned == true) ... [buildStatusIndicator(
                status: _deviceConnected,
                inProgressMessage: 'Mi sto connettendo al dispositivo...',
                successMessage: 'Device connesso!',
                failureMessage: 'Connessione non riuscita!',
                futureFunction: connectBleDevice(nodeData['name'], nodeData['pop']),
              )] else ... [const RowStatusIndicator(
                indicator: Icon(Icons.circle_outlined),
                info: 'Connessione al dispositivo',
              )],
              if (_deviceConnected == true) ... [buildStatusIndicator(
                status: _brokerDataSent,
                inProgressMessage: 'Sto inviando il broker al device...',
                successMessage: 'Invio riuscito!',
                failureMessage: 'Invio del broker fallito!',
                futureFunction: sendBrokerData(nodeData['name'], nodeData['pop']),
              )] else ... [const RowStatusIndicator(
                indicator: Icon(Icons.circle_outlined),
                info: 'Invio dati del broker',
              )],
              if (_brokerDataSent == true) ... [buildStatusIndicator(
                status: _gotInfos,
                inProgressMessage: 'Sto richiedendo le info al device...',
                successMessage: 'Info ottenute!',
                failureMessage: 'Richiesta fallita!',
                futureFunction: getDeviceInfos(nodeData['name'], nodeData['pop']),
              )] else ... [const RowStatusIndicator(
                indicator: Icon(Icons.circle_outlined),
                info: 'Richiesta info al device',
              )],
              if (_checkJsonDeviceInfo(_deviceInfos)) ... [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) =>
                                NodeInitPage(nodeData: nodeData, deviceInfos: _deviceInfos!)),
                            (Route<dynamic>
                        route) =>
                        false);
                  },
                  child: const Text('Continua'),
                )
              ] else ... [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Chiudi'),
                )
              ]
            ],
          ),
        );
      },
    );
  }

  bool _checkJsonDeviceInfo(Map<String, dynamic>? jsonInfos) {
    if (_gotInfos == true){
      if (jsonInfos != null && jsonInfos['sensors'] != null && jsonInfos['binary_sensors'] != null) {
        for (Map<String, dynamic> sensor in jsonInfos['sensors']) {
          if (sensor['topic'] == null ||
              sensor['unit'] == null) {
            utils.showSnackBar(context, 'OPS', 'Info del device non corrette!', true);
            return false;
          }
        }

        for (Map<String, dynamic> binarySensor in jsonInfos['binary_sensors']) {
          if (binarySensor['topic'] == null ||
              binarySensor['device_class'] == null) {
            utils.showSnackBar(context, 'OPS', 'Info del device non corrette!', true);
            return false;
          }
        }

        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
}