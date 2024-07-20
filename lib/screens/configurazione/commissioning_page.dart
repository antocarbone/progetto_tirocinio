import 'package:dashboard_tirocinio/screens/dashboard.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_esp_ble_prov/flutter_esp_ble_prov.dart';
import 'package:dashboard_tirocinio/presentation/custom_components.dart';

class CommissioningPage extends StatefulWidget {
  final Map<String, dynamic> nodeData;
  final String nodeName;
  final List<Map<String, dynamic>> allSensors;
  const CommissioningPage({super.key, required this.nodeData, required this.nodeName, required this.allSensors});

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
                failureMessage: 'Dispositivo non trovato!',
                futureFunction: scanBleDevices,
              ),
              if (_deviceScanned == true) ... [buildStatusIndicator(
                  status: _deviceConnected,
                  inProgressMessage: 'Mi sto connettendo al dispositivo...',
                  successMessage: 'Device connesso!',
                  failureMessage: 'Connessione non riuscita!',
                  futureFunction: connectBleDevice,
                )] else ... [const RowStatusIndicator(
                  indicator: Icon(Icons.circle_outlined),
                  info: 'Connessione al dispositivo',
                )],
              if (_deviceConnected == true) ... [buildStatusIndicator(
                  status: _brokerDataSent,
                  inProgressMessage: 'Sto inviando il broker al device...',
                  successMessage: 'Invio riuscito!',
                  failureMessage: 'Invio del broker fallito!',
                  futureFunction: sendBrokerData,
                )] else ... [const RowStatusIndicator(
                indicator: Icon(Icons.circle_outlined),
                info: 'Connessione del broker',
              )],
              if (_brokerDataSent == true) ... [buildStatusIndicator(
                  status: _wifiScanned,
                  inProgressMessage: 'Scansiono le reti wifi...',
                  successMessage: 'Reti trovate!',
                  failureMessage: 'Scansione delle reti wifi fallita!',
                  futureFunction: scanWifiNetworks,
                )] else ... [const RowStatusIndicator(
                indicator: Icon(Icons.circle_outlined),
                info: 'Scansione delle reti wifi',
              )],
              if (_wifiScanned == true) ... [
                  Expanded(
                  child: Container(
                    padding: EdgeInsets.all(defaultPadding),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: EdgeInsets.all(defaultPadding),
                          child: const Center(child: Text('Reti WiFi', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
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
                                        return WifiPasswordDialog(
                                          selectedSsid: selectedSsid,
                                          passwordController: _passwordController,
                                          provisionWifi: provisionWifi,
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
                ] else if (_deviceScanned == false || _deviceConnected == false || _brokerDataSent == false || _wifiScanned == false) ... [
                Container(
                  padding: EdgeInsets.all(defaultPadding),
                  child: const Center(child: Text('Inizializzazione fallita', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) =>
                                  HomePage()),
                              (Route<dynamic> route) =>
                          false);
                    },
                    child: const Text('Torna alla Home'),
                )
              ]
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
              indicator: const CircularProgressIndicator(color: Colors.black),
              info: inProgressMessage,
            );
          } else if (snapshot.hasData && snapshot.data == true) {
            return RowStatusIndicator(
              indicator: const Material(child: Icon(Icons.check_circle)),
              info: successMessage,
            );
          } else {
            return RowStatusIndicator(
              indicator: const Icon(Icons.error_rounded),
              info: failureMessage,
            );
          }
        },
      );
    } else if (status == true) {
      return RowStatusIndicator(
        indicator: const Material(child: Icon(Icons.check_circle)),
        info: successMessage,
      );
    } else {
      return RowStatusIndicator(
        indicator: const Icon(Icons.error_rounded),
        info: failureMessage,
      );
    }
  }
}

class WifiPasswordDialog extends StatefulWidget {
  final String selectedSsid;
  final TextEditingController passwordController;
  final Future<bool?> Function() provisionWifi;

  const WifiPasswordDialog({
    super.key,
    required this.selectedSsid,
    required this.passwordController,
    required this.provisionWifi,
  });

  @override
  _WifiPasswordDialogState createState() => _WifiPasswordDialogState();
}

class _WifiPasswordDialogState extends State<WifiPasswordDialog> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.selectedSsid),
      content: TextField(
        obscureText: _isObscured,
        controller: widget.passwordController,
        decoration: InputDecoration(
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                _isObscured = !_isObscured;
              });
            },
            icon: _isObscured ? const Icon(Icons.visibility_off) : const Icon(Icons.visibility),
          ),
          hintText: "Enter your input here",
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          child: const Text('Cancella'),
          onPressed: () {
            widget.passwordController.clear();
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: const Text('Conferma'),
          onPressed: () async {
            Navigator.of(context).pop();
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return FutureBuilder(
                  future: widget.provisionWifi(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return AlertDialog(
                        title: snapshot.data == true
                            ? const Center(
                          child: FittedBox(
                            child: Text('Dispositivo connesso!',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ),
                        )
                            : const Center(
                          child: FittedBox(
                            child: Text('Qualcosa è andato storto!',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        content: snapshot.data == true
                            ? const SizedBox(
                            height: 30,
                            width: 30,
                            child: FittedBox(child: Icon(Icons.check_circle)))
                            : const SizedBox(
                            height: 30,
                            width: 30,
                            child: FittedBox(child: Icon(Icons.error_rounded))),
                        actions: [
                          Center(
                            child: ElevatedButton(
                              child: const Text('Termina'),
                              onPressed: () async {
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (context) => HomePage()),
                                        (Route<dynamic> route) => false);
                              },
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const AlertDialog(
                        title: Center(
                            child: FittedBox(
                                child: Text('Attendi',
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))),
                        content: SizedBox(
                            height: 30,
                            width: 30,
                            child: FittedBox(child: CircularProgressIndicator(color: Colors.black))),
                      );
                    }
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}

