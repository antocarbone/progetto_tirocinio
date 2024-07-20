import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:qr_bar_code_scanner_dialog/qr_bar_code_scanner_dialog.dart';
import 'dart:convert';

import 'package:dashboard_tirocinio/presentation/custom_components.dart';
import 'package:dashboard_tirocinio/screens/configurazione/node_init_page.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final _qrBarCodeScannerDialogPlugin = QrBarCodeScannerDialog();

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
                if (!kIsWeb) ...[
                  ElevatedButton(
                    onPressed: () {
                      _qrBarCodeScannerDialogPlugin.getScannedQrBarCode(
                          context: context,
                          onCode: (code) {
                            final Map<String, dynamic> nodeData =
                                json.decode(code!);
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title:
                                      const Center(child: Text('Nuovo Nodo')),
                                  content:
                                      const Icon(Icons.question_mark_rounded),
                                  actions: <Widget>[
                                    Center(
                                      child: ElevatedButton(
                                        child: const Text('Configura'),
                                        onPressed: () async {
                                          Navigator.of(
                                                  context)
                                              .pushAndRemoveUntil(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          NodeInitPage(
                                                              nodeData:
                                                                  nodeData)),
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
                        title:
                            FittedBox(child: Text('Aggiungi un dispositivo'))),
                  ),
                  const Divider(),
                ],
                ElevatedButton(
                    onPressed: () {},
                    child: const ListTile(title: Center(child: Text('Nodo 1'))))
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 500,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: 5,
          itemBuilder: (context, index) {
            return GridTile(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 500,
                  ),
                  child: FittedBox(
                    child: Card(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Positioned.fill(
                                  child: Center(
                                      child: Text('$index',
                                          style: const TextStyle(
                                              fontSize: 40,
                                              fontWeight: FontWeight.bold)))),
                              const RadiusChart(),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: Text('Nome Sensore',
                                style: TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
