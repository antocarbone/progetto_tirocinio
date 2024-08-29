import 'dart:convert';
import 'package:dashboard_tirocinio/presentation/custom_components.dart';
import 'package:dashboard_tirocinio/screens/autenticazione/login_page.dart';
import 'package:dashboard_tirocinio/screens/wizard/area_assign_page.dart';
import 'package:dashboard_tirocinio/utility/api_helper.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_esp_ble_prov/flutter_esp_ble_prov.dart';
import 'package:dashboard_tirocinio/utility/utils.dart';

class BleConnectionDialog extends StatefulWidget {
  final Map<String, dynamic> nodeData;
  const BleConnectionDialog({super.key, required this.nodeData});

  @override
  State<BleConnectionDialog> createState() => _BleConnectionDialogState();
}

class _BleConnectionDialogState extends State<BleConnectionDialog> {
  final Map<String, dynamic> brokerData = {};
  final _flutterEspBleProvPlugin = FlutterEspBleProv();
  double defaultPadding = 12;
  bool? _deviceScanned;
  bool? _deviceConnected;
  bool? _gotInfos;
  bool? _brokerDataSent;

  Map<String, dynamic>? _deviceInfos;

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

  Future<void> _initialize() async {
    final nodeData = widget.nodeData;

    await initPreferences();
    if (_token != null) {
      Map<String, dynamic> tmpBrokerData = await getBrokerInfo(_token!);
      setState(() {
        brokerData.addAll(tmpBrokerData);
      });
    }

    bool res = await scanBleDevices(nodeData['name']);
    setState(() {
      _deviceScanned = res;
    });
    if (_deviceScanned == true) {
      res = await connectBleDevice(nodeData['name'], nodeData['pop']);
      setState(() {
        _deviceConnected = res;
      });
      if (_deviceConnected == true) {
        res = await sendBrokerData(nodeData['name'], nodeData['pop']);
        setState(() {
          _brokerDataSent = res;
        });
        if (_brokerDataSent == true) {
          res = await getDeviceInfos(nodeData['name'], nodeData['pop']);
          setState(() {
            _gotInfos = res;
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<bool> scanBleDevices(String name) async {
    final device = name;
    final List<String> scannedDevices;
    try {
      scannedDevices = await _flutterEspBleProvPlugin.scanBleDevices(device);
      if (scannedDevices.isNotEmpty) {
        return true;
      }
    } catch (e) {
      Utils.showSnackBar(
          context, 'Errore', 'Scansione dispositivo fallita!', true);
    }
    return false;
  }

  Future<bool> connectBleDevice(String name, String pop) async {
    try {
      await _flutterEspBleProvPlugin.connectBleDevice(name, pop);
      return true;
    } catch (e) {
      Utils.showSnackBar(
          context, 'Errore', 'Connessione al dispositivo fallita!', true);
    }
    return false;
  }

  Future<bool> getDeviceInfos(String name, String pop) async {
    String? res;
    try {
      res = await _flutterEspBleProvPlugin.sendCustomData(
          'get-device-info', '{"index":-1,"operation":0}', name, pop);
      if (res != null) {
        Map<String, dynamic> resJson = jsonDecode(res);
        if (resJson['status'] == 'success') {
          setState(() {
            _deviceInfos = resJson;
          });
          return true;
        }
      }
    } catch (e) {
      Utils.showSnackBar(
          context, 'Errore', 'Richiesta info dispositivo fallita!', true);
    }
    return false;
  }

  Future<bool> sendBrokerData(String name, String pop) async {
    String? res;
    try {
      res = await _flutterEspBleProvPlugin.sendCustomData(
          'mqtt-data', jsonEncode(brokerData), name, pop);
      if (res != null) {
        Map<String, dynamic> resJson = json.decode(res);
        if (resJson['status'] == 'success') {
          return true;
        } else {
          Utils.showSnackBar(
              context, 'Errore', 'Invio dati broker fallito!', true);
          return false;
        }
      }
    } catch (e) {
      Utils.showSnackBar(context, 'Errore', 'Invio dati broker fallito!', true);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
        child: FittedBox(
          child: Text('Inizializzazione dispositivo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildStatusIndicator(
            status: _deviceScanned,
            inProgressMessage: 'Sto cercando il device...',
            successMessage: 'Dispositivo trovato!',
            failureMessage: 'Dispositivo non trovato!',
          ),
          if (_deviceScanned != null) ...[
            buildStatusIndicator(
              status: _deviceConnected,
              inProgressMessage: 'Mi sto connettendo al dispositivo...',
              successMessage: 'Device connesso!',
              failureMessage: 'Connessione non riuscita!',
            )
          ] else ...[
            const RowStatusIndicator(
              indicator: Icon(Icons.circle_outlined),
              info: 'Connessione al dispositivo',
            )
          ],
          if (_deviceConnected != null) ...[
            buildStatusIndicator(
              status: _brokerDataSent,
              inProgressMessage: 'Sto inviando il broker al device...',
              successMessage: 'Invio riuscito!',
              failureMessage: 'Invio del broker fallito!',
            )
          ] else ...[
            const RowStatusIndicator(
              indicator: Icon(Icons.circle_outlined),
              info: 'Invio configurazione broker',
            )
          ],
          if (_brokerDataSent != null) ...[
            buildStatusIndicator(
              status: _gotInfos,
              inProgressMessage: 'Sto richiedendo le info al device...',
              successMessage: 'Info ottenute!',
              failureMessage: 'Richiesta fallita!',
            )
          ] else ...[
            const RowStatusIndicator(
              indicator: Icon(Icons.circle_outlined),
              info: 'Richiesta dati del nodo',
            )
          ],
          if (_checkJsonDeviceInfo(_deviceInfos)) ...[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => AreaAssignPage(
                        nodeData: widget.nodeData, deviceInfos: _deviceInfos!),
                  ),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text('Continua'),
            )
          ] else if (_deviceScanned == false ||
              _deviceConnected == false ||
              _brokerDataSent == false ||
              _gotInfos == false) ...[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Chiudi'),
            )
          ] else ...[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Utils.showSnackBar(
                    context, 'OPS', 'Info del device non corrette!', true);
              },
              child: const Text('Chiudi'),
            )
          ]
        ],
      ),
    );
  }

  Widget buildStatusIndicator({
    required bool? status,
    required String inProgressMessage,
    required String successMessage,
    required String failureMessage,
  }) {
    if (status == null) {
      return RowStatusIndicator(
        indicator: const CircularProgressIndicator(color: Colors.black),
        info: inProgressMessage,
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

  bool _checkJsonDeviceInfo(Map<String, dynamic>? jsonInfos) {
    if (_gotInfos == true) {
      if (jsonInfos != null &&
          jsonInfos['mac_address'] != null &&
          jsonInfos['unique_id'] != null &&
          jsonInfos['num_of_sensors'] != null &&
          jsonInfos['num_of_binary_sensors'] != null) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
}
