import 'package:dashboard_tirocinio/presentation/custom_components.dart';
import 'package:dashboard_tirocinio/screens/configurazione/sensors_init_page.dart';
import 'package:flutter/material.dart';

class NodeInitPage extends StatefulWidget {
  final Map<String, dynamic> nodeData;

  const NodeInitPage({super.key, required this.nodeData});

  @override
  State<NodeInitPage> createState() => _NodeInitPageState();
}

class _NodeInitPageState extends State<NodeInitPage> {
  final _nodeNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent.shade200,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomRight: Radius.circular(20), bottomLeft: Radius.circular(20))),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Configurazione Nodo'),
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
                      child: Text('Dai un nome al nodo'),
                    ),
                    Form(
                      key: _formKey,
                        child: MyTextField(hint: widget.nodeData['name'], controller: _nodeNameController)
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if(_formKey.currentState!.validate()) {
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => SensorsInitPage(nodeData: widget.nodeData, nodeName: _nodeNameController.text == '' ? widget.nodeData['name'] : _nodeNameController.text)),
                                  (Route<dynamic> route) => false);
                        }
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

  @override
  void dispose() {
    super.dispose();
    _nodeNameController.dispose();
  }
}
