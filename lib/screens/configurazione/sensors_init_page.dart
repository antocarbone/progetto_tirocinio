import 'dart:convert';

import 'package:dashboard_tirocinio/presentation/custom_components.dart';
import 'package:dashboard_tirocinio/screens/configurazione/commissioning_page.dart';
import 'package:dashboard_tirocinio/utility/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_esp_ble_prov/flutter_esp_ble_prov.dart';

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

  final _flutterEspBleProvPlugin = FlutterEspBleProv();

  Future<String?> getDeviceInfos(String name, String pop, int index, int operation) async {
    String? res;
    try {
      res = await _flutterEspBleProvPlugin.sendCustomData(
          'get-device-info', '{"index":$index,"operation":$operation}', name, pop);
      if (res != null) {
        Map<String, dynamic> resJson = jsonDecode(res);
        if (resJson['status'] == 'success' && _checkJsonDeviceInfo(resJson, operation == 1 ? 'sensor' : 'binary_sensor')) {
          return resJson['name'];
        } else {
          return null;
        }
      }
    } catch (e) {
      Utils.showSnackBar(
          context, 'Errore', 'Richiesta info dispositivo fallita!', true);
    }
    return null;
  }

  void initSensors() async {
    for(int i = 0; i < widget.deviceInfos['num_of_sensors']; i++) {
      String? defaultName = await getDeviceInfos(widget.nodeData['name'], widget.nodeData['pop'], i, 1);
      if (defaultName != null) {
        setState(() {
          sensors.add({'name': defaultName});
        });
      } else {
        Utils.showSnackBar(context, 'ERRORE', 'si è verificaato un problema nei dati dei sensori', true);
      }
    }

    for(int i = 0; i < widget.deviceInfos['num_of_binary_sensors']; i++) {
      String? defaultName = await getDeviceInfos(widget.nodeData['name'], widget.nodeData['pop'], i, 2);
      if (defaultName != null) {
        setState(() {
          binarySensors.add({'name': defaultName});
        });
      } else {
        Utils.showSnackBar(context, 'ERRORE', 'si è verificaato un problema nei dati sei sensori binari', true);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    initSensors();
    setState(() {
      sensorsControllers = List<TextEditingController>.generate(widget.deviceInfos['num_of_sensors'], (index) => TextEditingController());
      binarySensorsControllers = List<TextEditingController>.generate(widget.deviceInfos['num_of_binary_sensors'], (index) => TextEditingController());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
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
          child: SingleChildScrollView(
            child: Card(
              elevation: 12,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Text('Dai un nome ai sensori del nodo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
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
                              return MyTextField(hint: sensors[i]['name'], controller: sensorsControllers[i], onlyNumbers: false);
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
                              return MyTextField(hint: binarySensors[i]['name'], controller: binarySensorsControllers[i], onlyNumbers: false);
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

  bool _checkJsonDeviceInfo(Map<String, dynamic>? jsonInfos, String type) {
    if (jsonInfos != null) {
      if(type == 'sensor'){
        if (jsonInfos['name'] != null &&
            jsonInfos['topic_suffix'] != null &&
            jsonInfos['type_of_measurement'] != null) {
          return true;
        } else {
          return false;
        }
      } else if(type=='binary_sensor') {
        if (jsonInfos['name'] != null &&
            jsonInfos['topic_suffix'] != null &&
            jsonInfos['device_class'] != null) {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

}
