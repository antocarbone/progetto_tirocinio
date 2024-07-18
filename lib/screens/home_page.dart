import 'package:dashboard_tirocinio/screens/commissioning/commissioning_page.dart';
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomRight: Radius.circular(20), bottomLeft: Radius.circular(20))),
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
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => CommissioningPage(nodeData: json.decode(code!))),
                        (Route<dynamic> route) => false);
              });
        },
        child: const Icon(Icons.qr_code_scanner_rounded),
      ),
    );
  }
}
