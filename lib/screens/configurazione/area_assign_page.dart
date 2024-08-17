import 'package:dashboard_tirocinio/screens/configurazione/node_init_page.dart';
import 'package:flutter/material.dart';

class AreaAssignPage extends StatefulWidget {
  final Map<String, dynamic> nodeData;
  final Map<String, dynamic> deviceInfos;

  const AreaAssignPage({super.key, required this.nodeData, required this.deviceInfos});

  @override
  State<AreaAssignPage> createState() => _AreaAssignPageState();
}

class _AreaAssignPageState extends State<AreaAssignPage> {
  final List<String> items = ['uno', 'due', 'tre', 'quattro'];
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Assegnazione area'),
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
                      child: Text('Scegli l\'area alla quale assegnare il nodo'),
                    ),
                    DropdownButton<String>(
                      value: selectedValue,
                      onChanged: (selected) {
                        setState(() {
                          selectedValue = selected;
                        });
                      },
                      items: items.map(
                            (item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(item),
                          );
                        },
                      ).toList(),
                      hint: const Text('Select an area'),
                      icon: const Icon(Icons.arrow_drop_down),
                      iconSize: 42,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => NodeInitPage(
                              nodeData: widget.nodeData,
                              deviceInfos: widget.deviceInfos,
                              nodeArea: selectedValue ?? widget.deviceInfos['area_of_installation'],
                            ),
                          ),
                              (Route<dynamic> route) => false,
                        );
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
