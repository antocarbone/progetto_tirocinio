import 'dart:convert';

import 'package:dashboard_tirocinio/presentation/custom_components.dart';
import 'package:dashboard_tirocinio/screens/dashboard/node_status_history.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:dashboard_tirocinio/utility/http_request_helper.dart';

HttpRequestHelper requestHelper = HttpRequestHelper();




/// ******************************************************************************
/// GESTIONE AUTENTICAZIONE E REGISTRAZIONE UTENTI


class AuthUser {
  final String token;
  final String mail;
  final bool isAdmin;

  AuthUser({required this.token, required this.mail, required this.isAdmin});

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final String token = json['token'];
    final String mail = json['email'];
    final bool isAdmin = bool.parse(json['admin']);

    return AuthUser(token: token, mail: mail, isAdmin: isAdmin);
  }
}


/*
  METODI PER LA GESTIONE DELL'AUTENTICAZIONE/REGISTRAZIONE DI UN UTENTE
 */
Future<AuthUser> logIn(String mail, String password) async {
  final response = await requestHelper.getRequest('/users/login', mail, password);

  if (response.statusCode == 200) {
    final user = AuthUser.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    return user;
  } else {
    Map<String, dynamic> error = jsonDecode(response.body);
    throw Exception(error['error']);
  }
}

Future<AuthUser> register(String username, String password) async {
  final response = await requestHelper.getRequest('/users/add', username, password);

  if (response.statusCode == 201) {
    final user = AuthUser.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    return user;
  } else {
    Map<String, dynamic> error = jsonDecode(response.body);
    throw Exception(error['error']);
  }
}




/// ******************************************************************************
/// GESTIONE DATI UTENTE


class User {
  final String mail;
  final String nome;
  final String cognome;

  User({required this.mail, required this.nome, required this.cognome});

  factory User.fromJson(Map<String, dynamic> json) {
    String mail = 'non-definito';
    String nome = 'non-definito';
    String cognome = 'non-definito';

    mail = json['email'];
    nome = json['nome'];
    cognome = json['cognome'];

    return User(mail: mail, nome: nome, cognome: cognome);
  }

  MyGenericListElement toListElement() {
    return MyGenericListElement(leading: const Icon(Icons.person), title: '$nome $cognome', subtitle: mail);
  }
}



Future<User> getUserInfo(String mail, String password) async {
  final response = await requestHelper.getRequest('/users/get_user_info', mail, password);

  if (response.statusCode == 200) {
    final user = User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    return user;
  } else {
    Map<String, dynamic> error = jsonDecode(response.body);
    throw Exception(error['error']);
  }
}


Future<List<MyGenericListElement>> getAllUsers(String mail, String password) async {
  final response = await requestHelper.getRequest('/users/get_user_info', mail, password);

  if (response.statusCode == 200) {
    final List<MyGenericListElement> users = [];
    for(Map<String, dynamic> element in jsonDecode(response.body) as List<Map<String, dynamic>>) {
      User user = User(mail: element['email'], nome: element['nome'], cognome: element['cognome']);
      users.add(user.toListElement());
    }
    return users;
  } else {
    Map<String, dynamic> error = jsonDecode(response.body);
    throw Exception(error['error']);
  }
}




/// ******************************************************************************
/// GESTIONE SENSORI


class Sensor {
  final int id;
  final String nome;
  final String unitaMisura;
  final double lettura;

  Sensor({required this.id, required this.nome, required this.unitaMisura, required this.lettura});

  factory Sensor.fromJson(Map<String, dynamic> json) {
    final int id = int.parse(json['id']);
    final String nome = json['nome'];
    final String unitaMisura = json['unita_di_misura'];
    final double lettura = double.parse(json['valore']);

    return Sensor(id: id, nome: nome, unitaMisura: unitaMisura, lettura: lettura);
  }

  MyGenericListElement toListElement() {
    return MyGenericListElement(
      leading: FittedBox(
        child: Stack(
          alignment: Alignment.center,
          children: [
            RadiusChart(chartData: [ChartData('', lettura)]),
            Text(
              '$lettura $unitaMisura',
              style: const TextStyle(
                  fontSize: 50, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      title: nome,
    );
  }

  MySensorInfo toNodeElement() {
    return MySensorInfo(sensorName: nome, sensorValue: lettura, sensorUnitMisura: unitaMisura);
  }
}




/// ******************************************************************************
/// GESTIONE SENSORI BINARI


class BinarySensor {
  final int id;
  final String nome;
  final bool valore;
  final String deviceClass;
  final String stringaTrue;
  final String stringaFalse;
  final String codiceIcona;

  BinarySensor(
      {required this.id,
        required this.nome,
        required this.valore,
        required this.deviceClass,
        required this.stringaTrue,
        required this.stringaFalse,
        required this.codiceIcona});

  factory BinarySensor.fromJson(Map<String, dynamic> json) {
    final int id = int.parse(json['id']);
    final String nome = json['nome'];
    final bool valore = json['valore'];
    final String deviceClass = json['device_class'];
    final String stringaTrue = json['stringa_true'];
    final String stringaFalse = json['stringa_false'];
    final String codiceIcona = json['codice_icona'];

    return BinarySensor(id: id, nome: nome, valore: valore, deviceClass: deviceClass, stringaTrue: stringaTrue, stringaFalse: stringaFalse, codiceIcona: codiceIcona);
  }

  MyGenericListElement toListElement() {
    return MyGenericListElement(
      leading: Icon(MdiIcons.fromString(codiceIcona)),
      title: nome,
      subtitle: valore ? stringaTrue : stringaFalse,
    );
  }

  MyBinarySensorInfo toNodeElement() {
    return MyBinarySensorInfo(sensorValue: valore, sensorName: nome, iconCode: codiceIcona, trueString: stringaTrue, falseString: stringaFalse);
  }
}




/// ******************************************************************************
/// GESTIONE NODI

class Nodo {
  final int id;
  final String nome;
  final String status;
  final List<Sensor> sensors;
  final List<BinarySensor> binarySensors;

  Nodo(
      {required this.id,
        required this.nome,
        required this.status,
        required this.sensors,
        required this.binarySensors});

  factory Nodo.fromJson(Map<String, dynamic> json) {
    List<Sensor> sensors = [];
    List<BinarySensor> binarySensors = [];
    final int id = int.parse(json['id']);
    final String nome = json['nome'];
    final String status = json['status'];
    for (Map<String, dynamic> sensor in json['sensors']) {
      sensors.add(Sensor.fromJson(sensor));
    }
    for (Map<String, dynamic> binarySensor in json['binary_sensors']) {
      binarySensors.add(BinarySensor.fromJson(binarySensor));
    }

    return Nodo(id: id, nome: nome, status: status, sensors: sensors, binarySensors: binarySensors);
  }

  MyNodeSummary toWidget() {
    return MyNodeSummary(
      nodeName: nome,
      nodeStatus: status,
      sensors: sensors,
      binarySensors: binarySensors,
    );
  }
}


Future<List<MyNodeSummary>> getAllAreaNodes(String mail, String password) async {
  final response = await requestHelper.getRequest('/users/get_user_info', mail, password);

  if (response.statusCode == 200) {
    final List<MyNodeSummary> nodes = [];
    for(Map<String, dynamic> element in jsonDecode(response.body) as List<Map<String, dynamic>>) {
      Nodo nodo = Nodo(id: int.parse(element['id']), nome: element['nome'], status: element['status'], sensors: element['sensors'], binarySensors: element['binary_sensors']);
      nodes.add(nodo.toWidget());
    }
    return nodes;
  } else {
    Map<String, dynamic> error = jsonDecode(response.body);
    throw Exception(error['error']);
  }
}