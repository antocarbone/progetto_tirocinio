import 'package:dashboard_tirocinio/presentation/custom_components.dart';
import 'package:dashboard_tirocinio/screens/commissioning/commissioning_page.dart';
import 'package:dashboard_tirocinio/screens/home_page.dart';
import 'package:flutter/material.dart';

class SensorsInitPage extends StatelessWidget {
  final Map<String, dynamic> nodeData;

  const SensorsInitPage({super.key, required this.nodeData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent.shade200,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomRight: Radius.circular(20), bottomLeft: Radius.circular(20))),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Configurazione Sensori'),
          ],
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Center(
            child: Card(
              elevation: 12,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Text('Dai un nome ai sensori del nodo'),
                    ),
                    ListView(
                      shrinkWrap: true,
                      children: [
                        MyTextField(hint: 'DHT11'),
                        MyTextField(hint: 'SENSORE FUMO'),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => CommissioningPage(nodeData: nodeData)),
                                (Route<dynamic> route) => false);
                      },
                      child: const Text('Continua'),
                    ),
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
