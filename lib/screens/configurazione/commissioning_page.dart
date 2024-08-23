import 'dart:io';
import 'package:dashboard_tirocinio/screens/autenticazione/login_page.dart';
import 'package:dashboard_tirocinio/screens/dashboard/home_page.dart';
import 'package:dashboard_tirocinio/utility/api_helper.dart';
import 'package:dashboard_tirocinio/utility/utils.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_esp_ble_prov/flutter_esp_ble_prov.dart';
import 'package:dashboard_tirocinio/presentation/custom_components.dart';

class CommissioningPage extends StatefulWidget {
  final Map<String, dynamic> nodeData;
  final String uniqueDeviceId;
  final String nodeArea;
  final String nodeName;
  final List<Map<String, dynamic>> sensors;
  final List<Map<String, dynamic>> binarySensors;
  const CommissioningPage(
      {super.key,
      required this.nodeData,
      required this.uniqueDeviceId,
      required this.nodeArea,
      required this.nodeName,
      required this.sensors,
      required this.binarySensors});

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

  bool? _wifiScanned;

  late EncryptedSharedPreferences _prefs;
  String? _token;

  Future<void> initPreferences() async {
    EncryptedSharedPreferences tmp;
    String? tmpToken = '';
    try {
      await EncryptedSharedPreferences.initialize(Utils.encryptingKey);
      tmp = EncryptedSharedPreferences.getInstance();
    } on Exception catch (e) {
      Utils.showSnackBar(context, 'OPS',
          'Qualcosa è andato storto, effettua nuovamente il login\n$e', true);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false);
      return;
    }

    setState(() {
      _prefs = tmp;
    });

    tmpToken = _prefs.getString('token');

    setState(() {
      _token = tmpToken!;
    });
  }

  Future<bool> scanWifiNetworks() async {
    final scannedNetworks = await _flutterEspBleProvPlugin.scanWifiNetworks(
        widget.nodeData['name'], widget.nodeData['pop']);
    setState(() {
      networks = [];
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
    try {
      return await _flutterEspBleProvPlugin.provisionWifi(
          widget.nodeData['name'], proofOfPossession, selectedSsid, passphrase);
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
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
                status: _wifiScanned,
                inProgressMessage: 'Scansiono le reti wifi...',
                successMessage: 'Reti trovate!',
                failureMessage: 'Scansione delle reti wifi fallita!',
                futureFunction: scanWifiNetworks,
              ),
              if (_wifiScanned == true) ...[
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(defaultPadding),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(defaultPadding),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Reti WiFi',
                                  style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold)),
                              IconButton(
                                  onPressed: () async {
                                    Utils.showSnackBar(
                                        context,
                                        'Attendi',
                                        'Sto scansionando le reti wifi disponibili...',
                                        false);
                                    if (await scanWifiNetworks()) {
                                      Utils.showSnackBar(context, 'Fatto!',
                                          'Scansione terminata', false);
                                    } else {
                                      Utils.showSnackBar(context, 'Ops',
                                          'Qualcosa è andato storto', true);
                                    }
                                  },
                                  icon: const Icon(Icons.refresh))
                            ],
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
                                        return WifiPasswordDialog(
                                          selectedSsid: selectedSsid,
                                          passwordController:
                                              _passwordController,
                                          provisionWifi: provisionWifi,
                                          onComplete: () async {
                                            await initPreferences();
                                            late String res;
                                            try {
                                              Map<String, dynamic> data = {
                                                'id_node':
                                                    widget.uniqueDeviceId,
                                                'node_name': widget.nodeName,
                                                'area_name': widget.nodeArea,
                                                'sensors': widget.sensors,
                                                'binary_sensors':
                                                    widget.binarySensors
                                              };
                                              res =
                                                  await addNode(data, _token!);
                                              if (mounted) {
                                                Utils.showSnackBar(
                                                    super.context,
                                                    'NODO AGGIUNTO',
                                                    res,
                                                    false);
                                              }
                                            } on HttpException catch (e) {
                                              await _prefs.remove('token');
                                              await _prefs.remove('tipo');
                                              Utils.showSnackBar(context,
                                                  'ERRORE', e.message, true);
                                              Navigator.of(context)
                                                  .pushAndRemoveUntil(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const LoginPage()),
                                                      (Route<dynamic> route) =>
                                                          false);
                                              if (mounted) {
                                                Utils.showSnackBar(
                                                    super.context,
                                                    'ERRORE',
                                                    e.message,
                                                    true);
                                              }
                                            } on Exception catch (e) {
                                              if (mounted) {
                                                Utils.showSnackBar(
                                                    super.context,
                                                    'ERRORE',
                                                    e.toString(),
                                                    true);
                                              }
                                            }
                                          },
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
              ] else if (_wifiScanned == false) ...[
                Container(
                  padding: EdgeInsets.all(defaultPadding),
                  child: const Center(
                      child: Text('Inizializzazione fallita',
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold))),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const HomePage()),
                        (Route<dynamic> route) => false);
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
  final VoidCallback onComplete;

  const WifiPasswordDialog({
    super.key,
    required this.selectedSsid,
    required this.passwordController,
    required this.provisionWifi,
    required this.onComplete,
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
            icon: _isObscured
                ? const Icon(Icons.visibility_off)
                : const Icon(Icons.visibility),
          ),
          hintText: "Inserisci quì la password",
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
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                ),
                              )
                            : const Center(
                                child: FittedBox(
                                  child: Text('Qualcosa è andato storto!',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                        content: snapshot.data == true
                            ? const SizedBox(
                                height: 30,
                                width: 30,
                                child:
                                    FittedBox(child: Icon(Icons.check_circle)))
                            : const SizedBox(
                                height: 30,
                                width: 30,
                                child: FittedBox(
                                    child: Icon(Icons.error_rounded))),
                        actions: [
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                widget.onComplete();
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) => const HomePage()),
                                    (Route<dynamic> route) => false);
                              },
                              child: const Text('Termina'),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const AlertDialog(
                        title: Center(
                            child: FittedBox(
                                child: Text('Attendi',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)))),
                        content: SizedBox(
                            height: 30,
                            width: 30,
                            child: FittedBox(
                                child: CircularProgressIndicator(
                                    color: Colors.black))),
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
