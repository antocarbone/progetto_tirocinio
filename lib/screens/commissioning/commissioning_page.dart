import 'package:dashboard_tirocinio/screens/commissioning/node_init_page.dart';
import 'package:dashboard_tirocinio/screens/home_page.dart';
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

    if (scannedDevices.isNotEmpty) {
      setState(() {
        _deviceScanned = true;
      });
      return true;
    } else {
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
    if (networks.isNotEmpty) {
      setState(() {
        _wifiScanned = true;
      });
      return true;
    } else {
      setState(() {
        _wifiScanned = false;
      });
      return false;
    }
  }

  Future<bool?> provisionWifi() async {
    final proofOfPossession = widget.nodeData['pop'];
    final passphrase = _passwordController.text;
    return await _flutterEspBleProvPlugin.provisionWifi(widget.nodeData['name'], proofOfPossession, selectedSsid, passphrase);
  }

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
            Text('Commissioning'),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildStatusIndicator(
                status: _deviceScanned,
                inProgressMessage: 'Sto cercando il device...',
                successMessage: 'Dispositivo trovato!',
                failureMessage: 'Qualcosa è andato storto!',
                futureFunction: scanBleDevices,
              ),
              if (_deviceScanned != null)
                buildStatusIndicator(
                  status: _deviceConnected,
                  inProgressMessage: 'Mi sto connettendo al device...',
                  successMessage: 'Device connesso!',
                  failureMessage: 'Qualcosa è andato storto!',
                  futureFunction: connectBleDevice,
                ),
              if (_deviceConnected != null)
                buildStatusIndicator(
                  status: _brokerDataSent,
                  inProgressMessage: 'Sto inviando il broker al device...',
                  successMessage: 'Invio riuscito!',
                  failureMessage: 'Qualcosa è andato storto!',
                  futureFunction: sendBrokerData,
                ),
              if (_brokerDataSent != null)
                buildStatusIndicator(
                  status: _wifiScanned,
                  inProgressMessage: 'Scansiono le reti wifi...',
                  successMessage: 'Reti trovate!',
                  failureMessage: 'Qualcosa è andato storto!',
                  futureFunction: scanWifiNetworks,
                ),
              if (_wifiScanned != null)
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
                                                Navigator.of(context).pop;

                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                      content: FutureBuilder(
                                                          future: provisionWifi(),
                                                          builder: (context, snapshot) {
                                                            if (snapshot.hasData) {
                                                              return snapshot.data == true ? const Icon(Icons.check_circle) : const Icon(Icons.error_rounded);
                                                          } else {
                                                              return const CircularProgressIndicator();
                                                            }
                                                          }
                                                      ),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          child: const Text('Termina'),
                                                          onPressed: () async {
                                                            Navigator.of(context)
                                                                .pushAndRemoveUntil(
                                                                MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        HomePage()),
                                                                    (Route<dynamic> route) =>
                                                                false);
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
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
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _passwordController.dispose();
  }

  Widget buildStatusIndicator({
    required bool? status,
    required String inProgressMessage,
    required String successMessage,
    required String failureMessage,
    required Future<bool> Function() futureFunction,
  }) {
    if (status == null) {
      return FutureBuilder(
        future: futureFunction(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return RowStatusIndicator(
              indicator: const CircularProgressIndicator(),
              info: inProgressMessage,
            );
          } else if (snapshot.hasData && snapshot.data == true) {
            return RowStatusIndicator(
              indicator: const Icon(Icons.check_circle),
              info: successMessage,
            );
          } else {
            return RowStatusIndicator(
              indicator: const Icon(Icons.close_rounded),
              info: failureMessage,
            );
          }
        },
      );
    } else if (status == true) {
      return RowStatusIndicator(
        indicator: const Icon(Icons.check_circle),
        info: successMessage,
      );
    } else {
      return RowStatusIndicator(
        indicator: const Icon(Icons.close_rounded),
        info: failureMessage,
      );
    }
  }
}
