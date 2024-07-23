import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:qr_bar_code_scanner_dialog/qr_bar_code_scanner_dialog.dart';
import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';
import 'dart:convert';

import 'package:dashboard_tirocinio/presentation/custom_components.dart';
import 'package:dashboard_tirocinio/screens/configurazione/node_init_page.dart';
import 'package:dashboard_tirocinio/utility/utils.dart';
import 'package:dashboard_tirocinio/screens/autenticazione/login_page.dart';
import 'package:dashboard_tirocinio/screens/dashboard/home_page.dart';

class DettaglioAreaPage extends StatelessWidget {
  DettaglioAreaPage({super.key});

  final _qrBarCodeScannerDialogPlugin = QrBarCodeScannerDialog();
  final Utils utils = Utils();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent.shade200,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(20))),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Area 1'),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(
                    context)
                    .pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) =>
                            LoginPage()),
                        (Route<dynamic> route) =>
                    false);
              },
              icon: const Icon(Icons.person)
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
                      _qrBarCodeScannerDialogPlugin.getScannedQrBarCode(
                          context: context,
                          onCode: (code) {
                            final Map<String, dynamic> nodeData;

                            try {
                              nodeData = json.decode(code!);
                            } on Exception catch (e) {
                              utils.showSnackBar(
                                  context, 'OPS', 'QR code non valido!', true);
                              return;
                            }

                            if (nodeData['name'] == null ||
                                nodeData['pop'] == null ||
                                nodeData['sensors'] == null ||
                                nodeData['binary_sensors'] == null) {
                              utils.showSnackBar(
                                  context, 'OPS', 'QR code non valido!', true);
                              return;
                            } else {
                              for (Map<String, dynamic> sensor
                              in nodeData['sensors']) {
                                if (sensor['topic'] == null ||
                                    sensor['unit'] == null) {
                                  utils.showSnackBar(context, 'OPS',
                                      'QR code non valido!', true);
                                  return;
                                }
                              }

                              for (Map<String, dynamic> binarySensor
                              in nodeData['binary_sensors']) {
                                if (binarySensor['topic'] == null ||
                                    binarySensor['device_class'] == null) {
                                  utils.showSnackBar(context, 'OPS',
                                      'QR code non valido!', true);
                                  return;
                                }
                              }
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
                                                Navigator.of(context)
                                                    .pushAndRemoveUntil(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            NodeInitPage(
                                                                nodeData:
                                                                nodeData)),
                                                        (Route<dynamic>
                                                    route) =>
                                                    false);
                                              },
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                                Navigator.of(context)
                                    .pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            NodeInitPage(
                                                nodeData:
                                                nodeData)),
                                        (Route<dynamic>
                                    route) =>
                                    false);
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
                      Navigator.of(
                          context)
                          .pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) =>
                                  HomePage()),
                              (Route<dynamic> route) =>
                          false);
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
}