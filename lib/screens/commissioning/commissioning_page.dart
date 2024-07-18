import 'package:dashboard_tirocinio/screens/commissioning/node_init_page.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_esp_ble_prov/flutter_esp_ble_prov.dart';
import 'package:dashboard_tirocinio/presentation/custom_components.dart';

class CommissioningPage extends StatefulWidget {
  final Map<String, dynamic> nodeData;
  const CommissioningPage({super.key, required this.nodeData});

  @override
  State<CommissioningPage> createState() => _CommissioningPageState();
}

class _CommissioningPageState extends State<CommissioningPage> {
  final _flutterEspBleProvPlugin = FlutterEspBleProv();

  final defaultPadding = 12.0;

  List<String> networks = [];

  String selectedSsid = '';
  String feedbackMessage = '';

  final _passwordController = TextEditingController();

  bool? _deviceScanned;
  bool? _deviceConnected;
  bool? _wifiScanned;
  bool? _brokerDataSent;

  Future<bool> scanBleDevices() async {
    final device = widget.nodeData['name'];
    final scannedDevices =
        await _flutterEspBleProvPlugin.scanBleDevices(device);

    if (scannedDevices != []) {
      pushFeedback('Success: scanned BLE devices');
      pushFeedback('${scannedDevices.toString()} found');
      setState(() {
        _deviceScanned = true;
      });
      return true;
    } else {
      pushFeedback('Error: scanned BLE devices');
      setState(() {
        _deviceScanned = false;
      });
      return false;
    }
  }

  Future<bool> connectBleDevice() async {
    try {
      await _flutterEspBleProvPlugin.connectBleDevice(
          widget.nodeData['name'], widget.nodeData['pop']);
    } on Exception catch (e) {
      setState(() {
        _deviceConnected = false;
      });
      pushFeedback('Exception during connection: ${e.toString()}');
      return false;
    }
    setState(() {
      _deviceConnected = true;
    });
    return true;
  }

  Future<bool> sendBrokerData() async {
    try {
      await _flutterEspBleProvPlugin.sendCustomData(
          'custom-data',
          '{"broker":"mqtt://cavuotohome.duckdns.org","username":"iot","password":"iotunisa","port":1883}',
          widget.nodeData['name'],
          widget.nodeData['pop']);
    } on Exception catch (e) {
      setState(() {
        _brokerDataSent = false;
      });
      pushFeedback('Exception during broker info send: ${e.toString()}');
      return false;
    }
    setState(() {
      _brokerDataSent = true;
    });
    return true;
  }

  Future<bool> scanWifiNetworks() async {
    final scannedNetworks = await _flutterEspBleProvPlugin.scanWifiNetworks(
        widget.nodeData['name'], widget.nodeData['pop']);
    setState(() {
      networks = scannedNetworks;
    });
    if (networks != []) {
      pushFeedback('Success: scanned WiFi on ${widget.nodeData['name']}');
      setState(() {
        _wifiScanned = true;
      });
      return true;
    } else {
      pushFeedback('Error no network found');
      setState(() {
        _wifiScanned = false;
      });
      return false;
    }
  }

  Future provisionWifi() async {
    final proofOfPossession = widget.nodeData['pop'];
    final passphrase = _passwordController.text;
    await _flutterEspBleProvPlugin.provisionWifi(
        widget.nodeData['name'], proofOfPossession, selectedSsid, passphrase);
    pushFeedback(
        'Success: provisioned WiFi ${widget.nodeData['name']} on $selectedSsid');
  }

  pushFeedback(String msg) {
    setState(() {
      feedbackMessage = '$feedbackMessage\n$msg';
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
            Text('Commissioning'),
          ],
        ),
      ),
      bottomSheet: SafeArea(
        child: Container(
          width: double.infinity,
          color: Colors.black87,
          padding: EdgeInsets.all(defaultPadding),
          child: Text(
            feedbackMessage,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.green.shade600),
          ),
        ),
      ),
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _deviceScanned == null
                ? FutureBuilder(
                    future: scanBleDevices(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data == true) {
                          return const RowStatusIndicator(
                              indicator: Icon(Icons.check_circle),
                              info: 'Dispositivo trovato!');
                        } else {
                          return const RowStatusIndicator(
                              indicator: Icon(Icons.close_rounded),
                              info: 'Qualcosa è andato storto!');
                        }
                      } else {
                        return const RowStatusIndicator(
                            indicator: CircularProgressIndicator(),
                            info: 'Sto cercando il device...');
                      }
                    })
                : _deviceScanned == true
                    ? const RowStatusIndicator(
                        indicator: Icon(Icons.check_circle),
                        info: 'Device trovato!')
                    : const RowStatusIndicator(
                        indicator: Icon(Icons.close_rounded),
                        info: 'Qualcosa è andato storto!'),
            if (_deviceScanned != null) ...[
              _deviceConnected == null
                  ? FutureBuilder(
                      future: connectBleDevice(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data == true) {
                            return const RowStatusIndicator(
                                indicator: Icon(Icons.check_circle),
                                info: 'Device connesso!');
                          } else {
                            return const RowStatusIndicator(
                                indicator: Icon(Icons.close_rounded),
                                info: 'Qualcosa è andato storto!');
                          }
                        } else {
                          return const RowStatusIndicator(
                              indicator: CircularProgressIndicator(),
                              info: 'Mi sto connettendo al device...');
                        }
                      })
                  : _deviceConnected == true
                      ? const RowStatusIndicator(
                          indicator: Icon(Icons.check_circle),
                          info: 'Device connesso!')
                      : const RowStatusIndicator(
                          indicator: Icon(Icons.close_rounded),
                          info: 'Qualcosa è andato storto!'),
            ],
            if (_deviceConnected != null) ...[
              _brokerDataSent == null
                  ? FutureBuilder(
                      future: sendBrokerData(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data == true) {
                            return const RowStatusIndicator(
                                indicator: Icon(Icons.check_circle),
                                info: 'Invio riuscito!');
                          } else {
                            return const RowStatusIndicator(
                                indicator: Icon(Icons.close_rounded),
                                info: 'Qualcosa è andato storto!');
                          }
                        } else {
                          return const RowStatusIndicator(
                              indicator: CircularProgressIndicator(),
                              info: 'Sto inviando il broker al device...');
                        }
                      })
                  : _brokerDataSent == true
                      ? const RowStatusIndicator(
                          indicator: Icon(Icons.check_circle),
                          info: 'Invio riuscito!')
                      : const RowStatusIndicator(
                          indicator: Icon(Icons.close_rounded),
                          info: 'Qualcosa è andato storto!'),
            ],
            if (_brokerDataSent != null) ...[
              _wifiScanned == null
                  ? FutureBuilder(
                      future: scanWifiNetworks(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data == true) {
                            return const RowStatusIndicator(
                                indicator: Icon(Icons.check_circle),
                                info: 'Reti trovate!');
                          } else {
                            return const RowStatusIndicator(
                                indicator: Icon(Icons.close_rounded),
                                info: 'Qualcosa è andato storto!');
                          }
                        } else {
                          return const RowStatusIndicator(
                              indicator: FittedBox(
                                  fit: BoxFit.cover,
                                  child: CircularProgressIndicator()),
                              info: 'Scansiono le reti wifi...');
                        }
                      })
                  : _wifiScanned == true
                      ? const RowStatusIndicator(
                          indicator: Icon(Icons.check_circle),
                          info: 'Reti trovate!')
                      : const RowStatusIndicator(
                          indicator: Icon(Icons.close_rounded),
                          info: 'Qualcosa è andato storto!'),
            ],
            if (_wifiScanned != null) ...[
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.all(defaultPadding),
                          child: const Text('WiFi networks'),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: networks.length,
                          itemBuilder: (context, i) {
                            return Card(
                              child: ListTile(
                                leading: const Icon(Icons.wifi),
                                title: Text(
                                  networks[i],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                onTap: () async {
                                  selectedSsid = networks[i];
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(selectedSsid),
                                        content: TextField(
                                          controller: _passwordController,
                                          decoration: const InputDecoration(
                                              hintText:
                                                  "Enter your input here"),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('Cancella'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: const Text('Conferma'),
                                            onPressed: () async {
                                              Navigator.of(context).pushAndRemoveUntil(
                                                  MaterialPageRoute(builder: (context) => NodeInitPage()),
                                                      (Route<dynamic> route) => false);
                                              await provisionWifi();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]
          ],
        ),
      )),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _passwordController.dispose();
  }
}
