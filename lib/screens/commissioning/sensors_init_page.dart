import 'package:dashboard_tirocinio/presentation/custom_components.dart';
import 'package:dashboard_tirocinio/screens/commissioning/commissioning_page.dart';
import 'package:flutter/material.dart';

class SensorsInitPage extends StatefulWidget {
  final Map<String, dynamic> nodeData;
  final String nodeName;

  const SensorsInitPage({super.key, required this.nodeData, required this.nodeName});

  @override
  State<SensorsInitPage> createState() => _SensorsInitPageState();
}

class _SensorsInitPageState extends State<SensorsInitPage> {
  List<Map<String, dynamic>> allSensors = [];
  List<TextEditingController> sensorsControllers = [];

  @override
  void initState() {
    super.initState();
    final List<Map<String, dynamic>> tmp = [];
    for(Map<String, dynamic> sensor in widget.nodeData['sensors']) {
      tmp.add({'name':'', 'topic' : sensor['topic'], 'unit' : sensor['unit']});
    }

    for(Map<String, dynamic> sensor in widget.nodeData['binary_sensors']) {
      tmp.add({'name':'', 'topic' : sensor['topic'], 'device_class' : sensor['device_class']});
    }

    setState(() {
      allSensors = tmp;
      sensorsControllers = List<TextEditingController>.generate(tmp.length, (index) => TextEditingController());
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
                      child: Text('Dai un nome ai sensori del nodo'),
                    ),
                    ListView.builder(
                      itemCount: allSensors.length,
                      itemBuilder: (context, i) {
                        return MyTextField(hint: allSensors[i]['topic'], controller: sensorsControllers[i]);
                      },
                      shrinkWrap: true,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        for(int i=0; i<sensorsControllers.length; i++){
                          setState(() {
                            allSensors[i]['name'] = sensorsControllers[i].text;
                          });
                        }
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => CommissioningPage(nodeData: widget.nodeData, nodeName: widget.nodeName, allSensors: allSensors)),
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
