import 'package:dashboard_tirocinio/presentation/custom_components.dart';
import 'package:dashboard_tirocinio/screens/configurazione/commissioning_page.dart';
import 'package:flutter/material.dart';

class SensorsInitPage extends StatefulWidget {
  final Map<String, dynamic> nodeData;
  final Map<String, dynamic> deviceInfos;
  final String nodeName;
  final String nodeArea;


  const SensorsInitPage({super.key, required this.nodeData, required this.deviceInfos, required this.nodeName, required this.nodeArea});

  @override
  State<SensorsInitPage> createState() => _SensorsInitPageState();
}

class _SensorsInitPageState extends State<SensorsInitPage> {
  List<Map<String, dynamic>> sensors = [];
  List<Map<String, dynamic>> binarySensors = [];
  List<TextEditingController> sensorsControllers = [];
  List<TextEditingController> binarySensorsControllers = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final List<Map<String, dynamic>> tmpSensors = [];
    final List<Map<String, dynamic>> tmpBinarySensors = [];
    for(Map<String, dynamic> sensor in widget.deviceInfos['sensors']) {
      tmpSensors.add({'name':sensor['name']});
    }

    for(Map<String, dynamic> binarySensor in widget.deviceInfos['binary_sensors']) {
      tmpBinarySensors.add({'name':binarySensor['name']});
    }

    setState(() {
      sensors = tmpSensors;
      binarySensors = tmpBinarySensors;
      sensorsControllers = List<TextEditingController>.generate(tmpSensors.length, (index) => TextEditingController());
      binarySensorsControllers = List<TextEditingController>.generate(tmpBinarySensors.length, (index) => TextEditingController());
    });
  }

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
                      child: Text('Dai un nome ai sensori del nodo', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const Divider(),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 20),
                            child: Text('Sensori'),
                          ),
                          ListView.builder(
                            itemCount: sensors.length,
                            itemBuilder: (context, i) {
                              return MyTextField(hint: sensors[i]['name'], controller: sensorsControllers[i]);
                            },
                            shrinkWrap: true,
                          ),
                          const Divider(),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 20),
                            child: Text('Sensori Binari'),
                          ),
                          ListView.builder(
                            itemCount: binarySensors.length,
                            itemBuilder: (context, i) {
                              return MyTextField(hint: binarySensors[i]['name'], controller: binarySensorsControllers[i]);
                            },
                            shrinkWrap: true,
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                          for(int i=0; i<sensorsControllers.length; i++){
                            if (sensorsControllers[i].text.isNotEmpty) {
                              setState(() {
                                sensors[i]['name'] = sensorsControllers[i].text;
                              });
                            }
                          }
                          for(int i=0; i<binarySensorsControllers.length; i++){
                            if (binarySensorsControllers[i].text.isNotEmpty) {
                              setState(() {
                                binarySensors[i]['name'] = binarySensorsControllers[i].text;
                              });
                            }
                          }
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => CommissioningPage(nodeData: widget.nodeData, nodeArea: widget.nodeArea, nodeName: widget.nodeName, sensors: sensors, binarySensors: binarySensors)),
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

  @override
  void dispose() {
    super.dispose();
    for(TextEditingController controller in sensorsControllers) {
      controller.dispose();
    }
  }
}
