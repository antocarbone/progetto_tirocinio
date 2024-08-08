import 'dart:convert';

import 'package:dashboard_tirocinio/presentation/custom_components.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:dashboard_tirocinio/utility/http_request_helper.dart';

HttpRequestHelper requestHelper = HttpRequestHelper();

/// ******************************************************************************
/// GESTIONE AUTENTICAZIONE E REGISTRAZIONE UTENTI

class AuthUser {
  final String token;
  final String isAdmin;

  AuthUser({required this.token, required this.isAdmin});

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final String token = json['token'];
    final String isAdmin = json['tipo'];

    return AuthUser(token: token, isAdmin: isAdmin);
  }
}

/*
  METODO PER IL LOGIN
  - Scopo: Effettua il login dell'utente.
  - Parametri:
    - mail: L'email dell'utente.
    - password: La password dell'utente.
  - Ritorno: Un oggetto Future<AuthUser> contenente le informazioni dell'utente autenticato.
*/
Future<AuthUser> logIn(String mail, String password) async {
  final response = await requestHelper
      .postRequest('/users/login', {"email": mail, "passw": password});

  if (response.statusCode == 200) {
    final user =
        AuthUser.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    return user;
  } else {
    Map<String, dynamic> error = jsonDecode(response.body);
    throw Exception(error['error']);
  }
}

/*
  METODO PER LA REGISTRAZIONE
  - Scopo: Registra un nuovo utente.
  - Parametri:
    - token: Il token di autenticazione.
    - nome: Il nome dell'utente.
    - cognome: Il cognome dell'utente.
    - contatto1: Il primo contatto dell'utente.
    - contatto2: Il secondo contatto dell'utente (opzionale).
    - mail: L'email dell'utente.
    - password: La password dell'utente.
    - isAdmin: Il tipo di utente (admin o non admin).
  - Ritorno: Un oggetto Future<String> contenente un messaggio di conferma.
*/
Future<String> register(
    String token,
    String nome,
    String cognome,
    int contatto1,
    int? contatto2,
    String mail,
    String password,
    String isAdmin) async {
  List<int> contatti = [];
  contatti.add(contatto1);
  if (contatto2 != null) {
    contatti.add(contatto2);
  }
  final response = await requestHelper.postRequest(
      '/users/signup',
      {
        "email": mail,
        "passw": password,
        "nome": nome,
        "cognome": cognome,
        "contatti": contatti,
        "tipo": isAdmin
      },
      token);

  if (response.statusCode == 201) {
    Map<String, dynamic> message = jsonDecode(response.body);
    return message['message'];
  } else {
    Map<String, dynamic> error = jsonDecode(response.body);
    throw Exception(error['error']);
  }
}

/*
  METODO PER CANCELLARE UN UTENTE
  - Scopo: Cancella l'utente corrispondente alla mail inviata.
  - Parametri:
    - token: Il token di autenticazione.
    - mail: L'email dell'utente da cancellare.
  - Ritorno: Un oggetto Future<String> contenente un messaggio di conferma.
*/
Future<String> deleteUser(String token, String mail) async {
  final response =
      await requestHelper.deleteRequest('/users/', {"email": mail}, token);

  if (response.statusCode == 200) {
    Map<String, dynamic> message = jsonDecode(response.body);
    return message['message'];
  } else {
    Map<String, dynamic> error = jsonDecode(response.body);
    throw Exception(error['error']);
  }
}

/*
  METODO PER CAMBIARE LA PASSWORD
  - Scopo: Cambia la password dell'utente corrispondente alla mail, oppure se un admin
    intende cambiare la propria invia solamente il token.
  - Parametri:
    - token: Il token di autenticazione.
    - mail: L'email dell'utente (opzionale).
    - newPassw: La nuova password.
  - Ritorno: Un oggetto Future<String> contenente un messaggio di conferma.
*/
Future<String> changePassword(
    String token, String? mail, String newPassw) async {
  Map<String, dynamic> body = {"passw": newPassw};
  if (mail != null) {
    body.addAll({"email": mail});
  }
  final response =
      await requestHelper.postRequest('/users/change-passw', body, token);

  if (response.statusCode == 200) {
    Map<String, dynamic> message = jsonDecode(response.body);
    return message['message'];
  } else {
    Map<String, dynamic> error = jsonDecode(response.body);
    throw Exception(error['error']);
  }
}

/// ******************************************************************************
/// GESTIONE DATI UTENTE

class User {
  final String mail;
  final List<int> contatti;
  final String nome;
  final String cognome;

  User(
      {required this.mail,
      required this.contatti,
      required this.nome,
      required this.cognome});

  factory User.fromJson(Map<String, dynamic> json) {
    List<int> contatti = [];
    String mail = json['email'];
    for (String contatto in json["contatti"]) {
      contatti.add(int.parse(contatto));
    }
    String nome = json['nome'];
    String cognome = json['cognome'];

    return User(mail: mail, contatti: contatti, nome: nome, cognome: cognome);
  }
}

/*
  METODO PER OTTENERE LE INFORMAZIONI DI UN UTENTE
  - Scopo: Recupera le informazioni dell'utente.
  - Parametri:
    - mail: L'email dell'utente.
    - password: La password dell'utente.
  - Ritorno: Un oggetto Future<User> contenente le informazioni dell'utente.
*/
Future<User> getUserInfo(String mail, String password) async {
  final response = await requestHelper.getRequest('/users/get_user_info');

  if (response.statusCode == 200) {
    final user =
        User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    return user;
  } else {
    Map<String, dynamic> error = jsonDecode(response.body);
    throw Exception(error['error']);
  }
}

/*
  METODO PER OTTENERE TUTTI GLI UTENTI
  - Scopo: Recupera una lista di tutti gli utenti.
  - Parametri:
    - token: Il token di autenticazione.
  - Ritorno: Un oggetto Future<List<User>> contenente la lista degli utenti.
*/
Future<List<User>> getAllUsers(String token) async {
  final response = await requestHelper.getRequest('/users/all', token);

  if (response.statusCode == 200) {
    final List<User> users = [];
    for (Map<String, dynamic> element
        in jsonDecode(response.body) as List<dynamic>) {
      List<int> contatti = [];
      for (String contatto in element["contatti"]) {
        contatti.add(int.parse(contatto));
      }
      User user = User(
          mail: element['email'],
          contatti: contatti,
          nome: element['nome'],
          cognome: element['cognome']);
      users.add(user);
    }
    return users;
  } else {
    Map<String, dynamic> error = jsonDecode(response.body);
    throw Exception(error['error']);
  }
}

/// ******************************************************************************
/// GESTIONE AREE

class Area {
  final String nome;

  Area({required this.nome});

  factory Area.fromJson(Map<String, dynamic> json) {
    String nome = json['area_name'];

    return Area(nome: nome);
  }
}

Future<String> addArea(String nome, String token) async {
  final response = await requestHelper.postRequest('/areas/', {"area_name":nome}, token);

  if (response.statusCode == 201) {
    Map<String, dynamic> message = jsonDecode(response.body);
    return message['message'];
  } else {
    Map<String, dynamic> error = jsonDecode(response.body);
    print(error['error']);
    throw Exception(error['error']);
  }
}

Future<String> deleteArea(String nome, String token) async {
  final response = await requestHelper.deleteRequest('/areas/', {"area_name":nome}, token);

  if (response.statusCode == 200) {
    Map<String, dynamic> message = jsonDecode(response.body);
    return message['message'];
  } else {
    Map<String, dynamic> error = jsonDecode(response.body);
    throw Exception(error['error']);
  }
}

Future<List<Area>> getAllAreas(String token) async {
  final response = await requestHelper.getRequest('/areas/', token);

  List<Area> areas = [];

  if (response.statusCode == 200) {
    Map<String, dynamic> json = jsonDecode(response.body);
    for(String area in json["all_areas"]) {
      areas.add(Area(nome: area));
    }
    return areas;
  } else {
    Map<String, dynamic> error = jsonDecode(response.body);
    throw Exception(error['error']);
  }
}

Future<List<Area>> getAllUserAreas(String token, String mail) async {
  final response = await requestHelper.postRequest('/areas/all_user_areas', {"email":mail},token);

  List<Area> areas = [];

  if (response.statusCode == 200) {
    Map<String, dynamic> json = jsonDecode(response.body);
    for(Map<String, dynamic> area in json["all_areas"]) {
      areas.add(Area(nome: area["area_name"]));
    }
    return areas;
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

  Sensor(
      {required this.id,
      required this.nome,
      required this.unitaMisura,
      required this.lettura});

  factory Sensor.fromJson(Map<String, dynamic> json) {
    final int id = int.parse(json['id']);
    final String nome = json['nome'];
    final String unitaMisura = json['unita_di_misura'];
    final double lettura = double.parse(json['valore']);

    return Sensor(
        id: id, nome: nome, unitaMisura: unitaMisura, lettura: lettura);
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
              style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      title: nome,
    );
  }

  MySensorInfo toNodeElement() {
    return MySensorInfo(
        sensorName: nome, sensorValue: lettura, sensorUnitMisura: unitaMisura);
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

    return BinarySensor(
        id: id,
        nome: nome,
        valore: valore,
        deviceClass: deviceClass,
        stringaTrue: stringaTrue,
        stringaFalse: stringaFalse,
        codiceIcona: codiceIcona);
  }

  MyGenericListElement toListElement() {
    return MyGenericListElement(
      leading: Icon(MdiIcons.fromString(codiceIcona)),
      title: nome,
      subtitle: valore ? stringaTrue : stringaFalse,
    );
  }

  MyBinarySensorInfo toNodeElement() {
    return MyBinarySensorInfo(
        sensorValue: valore,
        sensorName: nome,
        iconCode: codiceIcona,
        trueString: stringaTrue,
        falseString: stringaFalse);
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

    return Nodo(
        id: id,
        nome: nome,
        status: status,
        sensors: sensors,
        binarySensors: binarySensors);
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

/*
  METODO PER OTTENERE TUTTI I NODI DELL'AREA
  - Scopo: Recupera una lista di tutti i nodi di un'area.
  - Parametri:
    - mail: L'email dell'utente.
    - password: La password dell'utente.
  - Ritorno: Un oggetto Future<List<MyNodeSummary>> contenente la lista dei nodi.
*/
Future<List<MyNodeSummary>> getAllAreaNodes(
    String mail, String password) async {
  final response = await requestHelper.getRequest('/users/get_user_info');

  if (response.statusCode == 200) {
    final List<MyNodeSummary> nodes = [];
    for (Map<String, dynamic> element
        in jsonDecode(response.body) as List<Map<String, dynamic>>) {
      Nodo nodo = Nodo(
          id: int.parse(element['id']),
          nome: element['nome'],
          status: element['status'],
          sensors: element['sensors'],
          binarySensors: element['binary_sensors']);
      nodes.add(nodo.toWidget());
    }
    return nodes;
  } else {
    Map<String, dynamic> error = jsonDecode(response.body);
    throw Exception(error['error']);
  }
}
