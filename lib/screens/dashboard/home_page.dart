import 'package:dashboard_tirocinio/screens/impostazioni/settings_page.dart';
import 'package:dashboard_tirocinio/utility/ble_connection_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_esp_ble_prov/flutter_esp_ble_prov.dart';
import 'dart:convert';

import 'package:qr_bar_code_scanner_dialog/qr_bar_code_scanner_dialog.dart';
import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';

import 'package:dashboard_tirocinio/presentation/custom_components.dart';
import 'package:dashboard_tirocinio/screens/configurazione/node_init_page.dart';
import 'package:dashboard_tirocinio/screens/dashboard/dettaglio_area_page.dart';
import 'package:dashboard_tirocinio/utility/utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _qrBarCodeScannerDialogPlugin = QrBarCodeScannerDialog();
  final Utils utils = Utils();

  bool _isExpanded = false;

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
        title: const Text('Home'),
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
                        child: FittedBox(child: IconButton(onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsPage()));
                        }, icon: const Icon(Icons.settings))),
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
                  maxCrossAxisExtent: 300,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5),
              itemCount: 8,
              itemBuilder: (context, index) {
                return const GridTile(
                  child: MySensorInfo(sensorValue: 20.5, sensorName: 'temp')
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}