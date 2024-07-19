import 'package:dashboard_tirocinio/screens/commissioning/node_init_page.dart';
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
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
        child: const Icon(Icons.qr_code_scanner_rounded),
      ),
    );
  }
}
