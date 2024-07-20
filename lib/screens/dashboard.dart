import 'package:dashboard_tirocinio/presentation/custom_components.dart';
import 'package:dashboard_tirocinio/screens/configurazione/node_init_page.dart';
import 'package:flutter/material.dart';
import 'package:qr_bar_code_scanner_dialog/qr_bar_code_scanner_dialog.dart';
import 'dart:convert';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final _qrBarCodeScannerDialogPlugin = QrBarCodeScannerDialog();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent.shade200,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomRight: Radius.circular(20), bottomLeft: Radius.circular(20))),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Home'),
          ],
        ),
      ),

      drawer: Drawer(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ElevatedButton(
                    onPressed: () {
                      _qrBarCodeScannerDialogPlugin.getScannedQrBarCode(
                          context: context,
                          onCode: (code) {
                            final Map<String, dynamic> nodeData = json.decode(code!);
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Center(child: Text('Nuovo Nodo')),
                                  content: const Icon(Icons.question_mark_rounded),
                                  actions: <Widget>[
                                    Center(
                                      child: ElevatedButton(
                                        child: const Text('Configura'),
                                        onPressed: () async {
                                          Navigator.of(context)
                                              .pushAndRemoveUntil(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      NodeInitPage(nodeData: nodeData)),
                                                  (Route<dynamic> route) =>
                                              false);
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          });
                    },
                    child: const ListTile(
                      leading: Icon(Icons.qr_code_scanner_rounded),
                      title: FittedBox(child: Text('Aggiungi un dispositivo'))
                    ),
                ),
                const Divider(),
                ElevatedButton(onPressed: () {}, child: const ListTile(title: Center(child: Text('Nodo 1'))))
              ],
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500,
            ),
            child: const FittedBox(
              child: Card(
                child: Stack(
                  children: [
                    Positioned.fill(
                        child: Center(child: Text('20°C', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)))
                    ),
                    RadiusChart(),
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
