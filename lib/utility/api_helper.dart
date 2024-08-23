import 'dart:convert';
import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'package:dashboard_tirocinio/utility/http_request_helper.dart';

HttpRequestHelper requestHelper = HttpRequestHelper();
DateFormat dateTimeFormatter = DateFormat('yyyy/MM/dd kk:mm');
DateFormat historyDateFormatter = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'");

/// ******************************************************************************
/// GESTIONE ROTTE GENERICHE DI CONFIGURAZIONE

Future<Map<String, dynamic>> getBrokerInfo(String token) async {
  final response = await requestHelper.getRequest('/broker_info', token);

  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    return jsonResponse;
  } else {
    Map<String, dynamic> error = jsonDecode(response.body);
    throw Exception(error['error']);
  }
}

Future<String> checkBaseUrl() async {
  final response = await requestHelper.getRequest('/api_info');

  if (response.statusCode == 200) {
    Map<String, dynamic> message = jsonDecode(response.body);
    return message['version'];
  } else {
    Map<String, dynamic> error = jsonDecode(response.body);
    throw Exception(error['error']);
  }
}

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
  } else if (response.statusCode == 401) {
    throw const HttpException('Token Scaduto, esegui nuovamente il login');
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
  } else if (response.statusCode == 401) {
    throw const HttpException('Token Scaduto, esegui nuovamente il login');
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
  } else if (response.statusCode == 401) {
    throw const HttpException('Token Scaduto, esegui nuovamente il login');
  } else {
    Map<String, dynamic> error = jsonDecode(response.body);
    throw Exception(error['error']);
  }
}

/*
  METODO PER CAMBIARE LA MAIL
  - Scopo: Cambia la mail dell'utente corrispondente alla mail, oppure se un admin
    intende cambiare la propria invia solamente il token.
  - Parametri:
    - token: Il token di autenticazione.
    - mail: L'email dell'utente (opzionale).
    - newMail: La nuova mail.
  - Ritorno: Un oggetto Future<String> contenente un messaggio di conferma.
*/
Future<String> changeMail(String token, String? mail, String newMail) async {
  Map<String, dynamic> body = {"new_email": newMail};
  if (mail != null) {
    body.addAll({"email": mail});
  }
  final response =
      await requestHelper.postRequest('/users/change-email', body, token);

  if (response.statusCode == 200) {
    Map<String, dynamic> message = jsonDecode(response.body);
    return message['message'];
  } else if (response.statusCode == 401) {
    throw const HttpException('Token Scaduto, esegui nuovamente il login');
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
  } else if (response.statusCode == 401) {
    throw const HttpException('Token Scaduto, esegui nuovamente il login');
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

  @override
  bool operator ==(Object other) {
    if (other is Area) {
      return nome == other.nome;
    } else {
      return false;
    }
  }
}

/*
  METODO PER AGGIUNGERE UNA NUOVA AREA
  - Scopo: Aggiunge una nuova area specificata dall'utente.
  - Parametri:
    - nome: Il nome della nuova area.
    - token: Il token di autenticazione.
  - Ritorno: Un oggetto Future<String> contenente il messaggio di successo.
*/
Future<String> addArea(String nome, String token) async {
  final response =
      await requestHelper.postRequest('/areas/', {"area_name": nome}, token);

  if (response.statusCode == 201) {
    Map<String, dynamic> message = jsonDecode(response.body);
    return message['message'];
  } else if (response.statusCode == 401) {
    throw const HttpException('Token Scaduto, esegui nuovamente il login');
  } else {
    Map<String, dynamic> error = jsonDecode(response.body);
    throw Exception(error['error']);
  }
}

/*
  METODO PER ELIMINARE UN'AREA
  - Scopo: Elimina un'area esistente specificata dall'utente.
  - Parametri:
    - nome: Il nome dell'area da eliminare.
    - token: Il token di autenticazione.
  - Ritorno: Un oggetto Future<String> contenente il messaggio di successo.
*/
Future<String> deleteArea(String nome, String token) async {
  final response =
      await requestHelper.deleteRequest('/areas/', {"area_name": nome}, token);

  if (response.statusCode == 200) {
    Map<String, dynamic> message = jsonDecode(response.body);
    return message['message'];
  } else if (response.statusCode == 401) {
    throw const HttpException('Token Scaduto, esegui nuovamente il login');
  } else {
    Map<String, dynamic> error = jsonDecode(response.body);
    throw Exception(error['error']);
  }
}

/*
  METODO PER OTTENERE TUTTE LE AREE
  - Scopo: Recupera una lista di tutte le aree esistenti.
  - Parametri:
    - token: Il token di autenticazione.
  - Ritorno: Un oggetto Future<List<Area>> contenente la lista delle aree.
*/
Future<List<Area>> getAllAreas(String token) async {
  final response = await requestHelper.getRequest('/areas/', token);

  List<Area> areas = [];

  if (response.statusCode == 200) {
    Map<String, dynamic> json = jsonDecode(response.body);
    for (String area in json["area_list"]) {
      areas.add(Area(nome: area));
    }
    return areas;
  } else if (response.statusCode == 401) {
    throw const HttpException('Token Scaduto, esegui nuovamente il login');
  } else {
    Map<String, dynamic> error = jsonDecode(response.body);
    throw Exception(error['error']);
  }
}

/*
  METODO PER OTTENERE LE AREE ASSOCIATE A UN UTENTE
  - Scopo: Recupera una lista di aree associate a un utente specifico o all'utente corrente.
  - Parametri:
    - token: Il token di autenticazione.
    - mail (opzionale): L'indirizzo email dell'utente (se non specificato, verranno recuperate le aree dell'utente corrente).
  - Ritorno: Un oggetto Future<List<Area>> contenente la lista delle aree associate all'utente.
*/
Future<List<Area>> getAllUserAreas(String token, [String? mail]) async {
  dynamic response;
  if (mail == null) {
    response = await requestHelper.postRequest('/areas/user', null, token);
  } else {
    response =
        await requestHelper.postRequest('/areas/user', {"email": mail}, token);
  }

  List<Area> areas = [];

  if (response.statusCode == 200) {
    Map<String, dynamic> json = jsonDecode(response.body);
    for (String area in json["area_list"]) {
      areas.add(Area(nome: area));
    }
    return areas;
  } else if (response.statusCode == 401) {
    throw const HttpException('Token Scaduto, esegui nuovamente il login');
  } else {
    Map<String, dynamic> error = jsonDecode(response.body);
    throw Exception(error['error']);
  }
}

/*
  METODO PER AGGIORNARE LE AREE ASSOCIATE A UN UTENTE
  - Scopo: Aggiorna la lista delle aree associate a un utente specifico.
  - Parametri:
    - mail: L'indirizzo email dell'utente.
    - aree: La nuova lista di aree da associare all'utente.
    - token: Il token di autenticazione.
  - Ritorno: Un oggetto Future<String> contenente il messaggio di successo.
*/
Future<String> updateUserAreas(
    String mail, List<String> aree, String token) async {
  final response = await requestHelper.postRequest(
      '/areas/user/update', {"email": mail, "area_list": aree}, token);

  if (response.statusCode == 200) {
    Map<String, dynamic> message = jsonDecode(response.body);
    return message['message'];
  } else if (response.statusCode == 401) {
    throw const HttpException('Token Scaduto, esegui nuovamente il login');
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
  final double? lettura;
  final DateTime? dataLettura;

  Sensor(
      {required this.id,
      required this.nome,
      required this.unitaMisura,
      required this.lettura,
      required this.dataLettura});

  factory Sensor.fromJson(Map<String, dynamic> json) {
    final int id = json['id_sensor'];
    final String nome = json['sens_name'];
    final String unitaMisura = json['unit'];
    final double? lettura =
        json['value'] == null ? null : double.parse(json['value']);
    final DateTime? dataLettura = json['lecture_date'] == null
        ? null
        : historyDateFormatter.parseUtc(json['lecture_date']);

    return Sensor(
        id: id,
        nome: nome,
        unitaMisura: unitaMisura,
        lettura: lettura,
        dataLettura: dataLettura);
  }
}

class SensorReading {
  final double value;
  final DateTime date;

  SensorReading({required this.value, required this.date});

  factory SensorReading.fromJson(Map<String, dynamic> json) {
    final double value = double.parse(json['value']);
    final DateTime date = historyDateFormatter.parseUtc(json['date']);

    return SensorReading(value: value, date: date);
  }
}

class SensorReadingsHistory {
  final List<SensorReading> readings;

  SensorReadingsHistory({required this.readings});

  factory SensorReadingsHistory.fromJson(List<dynamic> json) {
    List<SensorReading> readings = [];
    for (final elem in json) {
      readings.add(SensorReading.fromJson(elem));
    }
    return SensorReadingsHistory(readings: readings);
  }

  /*
    METODO PER CONVERTIRE LE LETTURE DEL SENSORE IN PUNTI PER UN GRAFICO
    - Scopo: Converte la lista di letture del sensore in una lista di FlSpot per la visualizzazione in un grafico.
    - Parametri:
      - start: Data di inizio dell'intervallo da considerare.
      - end: Data di fine dell'intervallo da considerare.
    - Ritorno: Una lista di FlSpot contenente i punti da tracciare.
  */
  List<FlSpot> toSpotList(DateTime start, DateTime end) {
    List<FlSpot> out = [];
    for (final elem in readings) {
      out.add(FlSpot(
          elem.date.toUtc().millisecondsSinceEpoch / 60000 -
              start.toUtc().millisecondsSinceEpoch / 60000,
          double.parse(elem.value.toStringAsFixed(2))));
    }
    return out;
  }
}

/*
  METODO PER OTTENERE LE LETTURE DI UN SENSORE IN UN INTERVALLO DI TEMPO
  - Scopo: Recupera le letture di un sensore specifico all'interno di un determinato intervallo di tempo.
  - Parametri:
    - sensorId: ID del sensore di cui si vogliono ottenere le letture.
    - start: Data di inizio dell'intervallo di tempo.
    - end: Data di fine dell'intervallo di tempo.
    - token: Il token di autenticazione.
  - Ritorno: Un oggetto Future<List<FlSpot>> contenente la lista dei punti da tracciare nel grafico.
*/
Future<List<FlSpot>> getSensorReadings(
    int sensorId, DateTime start, DateTime end, String token) async {
  final response = await requestHelper.postRequest(
      '/areas/nodes/sensors/sensor_data',
      {
        "id_sensor": sensorId,
        "start": dateTimeFormatter.format(start),
        "end": dateTimeFormatter.format(end)
      },
      token);

  if (response.statusCode == 200) {
    final List<dynamic> json = jsonDecode(response.body);
    return SensorReadingsHistory.fromJson(json).toSpotList(start, end);
  } else if (response.statusCode == 401) {
    throw const HttpException('Token Scaduto, esegui nuovamente il login');
  } else {
    Map<String, dynamic> error = jsonDecode(response.body);
    throw Exception(error['error']);
  }
}

/// ******************************************************************************
/// GESTIONE SENSORI BINARI

class BinarySensor {
  final int id;
  final String nome;
  final bool? valore;
  final DateTime? dataLettura;
  final String stringaTrue;
  final String stringaFalse;
  final String codiceIcona;

  BinarySensor(
      {required this.id,
      required this.nome,
      required this.valore,
      required this.dataLettura,
      required this.stringaTrue,
      required this.stringaFalse,
      required this.codiceIcona});

  factory BinarySensor.fromJson(Map<String, dynamic> json) {
    final int id = json['id_bin_sensor'];
    final String nome = json['sens_name'];
    final bool? valore = json['value'];
    final DateTime? dataLettura = json['lecture_date'] == null
        ? null
        : historyDateFormatter.parseUtc(json['lecture_date']);
    final String stringaTrue = json['true_string'];
    final String stringaFalse = json['false_string'];
    final String codiceIcona = json['icon'];

    return BinarySensor(
        id: id,
        nome: nome,
        valore: valore,
        dataLettura: dataLettura,
        stringaTrue: stringaTrue,
        stringaFalse: stringaFalse,
        codiceIcona: codiceIcona);
  }
}

class BinarySensorReading {
  final bool value;
  final DateTime date;

  BinarySensorReading({required this.value, required this.date});

  factory BinarySensorReading.fromJson(Map<String, dynamic> json) {
    final bool value = json['value'];
    final DateTime date = historyDateFormatter.parseUtc(json['date']);

    return BinarySensorReading(value: value, date: date);
  }
}

class BinarySensorReadingsHistory {
  final List<BinarySensorReading> readings;

  BinarySensorReadingsHistory({required this.readings});

  factory BinarySensorReadingsHistory.fromJson(List<dynamic> json) {
    List<BinarySensorReading> readings = [];
    for (final elem in json) {
      readings.add(BinarySensorReading.fromJson(elem));
    }
    return BinarySensorReadingsHistory(readings: readings);
  }
}

/*
  METODO PER OTTENERE LE LETTURE DI UN SENSORE BINARIO IN UN INTERVALLO DI TEMPO
  - Scopo: Recupera le letture di un sensore binario specifico all'interno di un determinato intervallo di tempo.
  - Parametri:
    - sensorId: ID del sensore binario di cui si vogliono ottenere le letture.
    - start: Data di inizio dell'intervallo di tempo.
    - end: Data di fine dell'intervallo di tempo.
    - token: Il token di autenticazione.
  - Ritorno: Un oggetto Future<BinarySensorReadingsHistory> contenente la cronologia delle letture.
*/
Future<BinarySensorReadingsHistory> getBinarySensorReadings(
    int sensorId, DateTime start, DateTime end, String token) async {
  final response = await requestHelper.postRequest(
      '/areas/nodes/sensors/binary_sensor_data',
      {
        "id_bin_sensor": sensorId,
        "start": dateTimeFormatter.format(start),
        "end": dateTimeFormatter.format(end)
      },
      token);

  if (response.statusCode == 200) {
    final List<dynamic> json = jsonDecode(response.body);
    return BinarySensorReadingsHistory.fromJson(json);
  } else if (response.statusCode == 401) {
    throw const HttpException('Token Scaduto, esegui nuovamente il login');
  } else {
    Map<String, dynamic> error = jsonDecode(response.body);
    throw Exception(error['error']);
  }
}

/// ******************************************************************************
/// GESTIONE NODI

class Nodo {
  final String id;
  final String nome;
  final String status;

  Nodo({required this.id, required this.nome, required this.status});

  /*
    COSTRUTTORE FACTORY PER NODO
    - Scopo: Crea un'istanza di Nodo a partire da un oggetto JSON.
    - Parametri:
      - json: Mappa contenente i dati del nodo.
    - Ritorno: Un'istanza di Nodo.
  */
  factory Nodo.fromJson(Map<String, dynamic> json) {
    final String id = json['id_node'];
    final String nome = json['node_name'];
    final String status = json['node_status'];

    return Nodo(id: id, nome: nome, status: status);
  }
}

/*
  METODO PER AGGIUNGERE UN NUOVO NODO
  - Scopo: Aggiunge un nuovo nodo nell'area.
  - Parametri:
    - data: Mappa contenente i dati del nodo da aggiungere.
    - token: Il token di autenticazione.
  - Ritorno: Un oggetto Future<String> contenente un messaggio di conferma.
*/
Future<String> addNode(Map<String, dynamic> data, String token) async {
  final response =
      await requestHelper.postRequest('/areas/nodes/new', data, token);

  if (response.statusCode == 201) {
    Map<String, dynamic> message = jsonDecode(response.body);
    return message['message'];
  } else if (response.statusCode == 401) {
    throw const HttpException('Token Scaduto, esegui nuovamente il login');
  } else {
    Map<String, dynamic> error = jsonDecode(response.body);
    throw Exception(error['error']);
  }
}

/*
  METODO PER ELIMINARE UN NODO
  - Scopo: Elimina un nodo specifico dall'area.
  - Parametri:
    - id: ID del nodo da eliminare.
    - token: Il token di autenticazione.
  - Ritorno: Un oggetto Future<String> contenente un messaggio di conferma.
*/
Future<String> deleteNode(String id, String token) async {
  final response = await requestHelper.deleteRequest(
      '/areas/nodes/', {'id_node': id}, token);

  if (response.statusCode == 200) {
    Map<String, dynamic> message = jsonDecode(response.body);
    return message['message'];
  } else if (response.statusCode == 401) {
    throw const HttpException('Token Scaduto, esegui nuovamente il login');
  } else {
    Map<String, dynamic> error = jsonDecode(response.body);
    throw Exception(error['error']);
  }
}

/*
  METODO PER OTTENERE TUTTI I NODI DELL'AREA
  - Scopo: Recupera una lista di tutti i nodi di un'area specifica.
  - Parametri:
    - nomeArea: Il nome dell'area di cui si vogliono ottenere i nodi.
    - token: Il token di autenticazione.
  - Ritorno: Un oggetto Future<List<Nodo>> contenente la lista dei nodi.
*/
Future<List<Nodo>> getAllAreaNodes(String nomeArea, String token) async {
  final response = await requestHelper.postRequest(
      '/areas/nodes/', {"area_name": nomeArea}, token);

  if (response.statusCode == 200) {
    final List<Nodo> nodes = [];
    for (Map<String, dynamic> element
        in jsonDecode(response.body) as List<dynamic>) {
      Nodo nodo = Nodo.fromJson(element);
      nodes.add(nodo);
    }
    return nodes;
  } else if (response.statusCode == 401) {
    throw const HttpException('Token Scaduto, esegui nuovamente il login');
  } else {
    Map<String, dynamic> error = jsonDecode(response.body);
    throw Exception(error['error']);
  }
}

/*
  METODO PER OTTENERE TUTTI I NODI OFFLINE DELL'UTENTE
  - Scopo: Recupera una lista di tutti i nodi offline appartenenti all'utente.
  - Parametri:
    - token: Il token di autenticazione.
  - Ritorno: Un oggetto Future<List<dynamic>> contenente la lista dei nodi offline.
*/
Future<List<dynamic>> getAllUserOfflineNodes(String token) async {
  final response =
      await requestHelper.getRequest('/areas/nodes/offline', token);

  if (response.statusCode == 200) {
    return jsonDecode(response.body) as List<dynamic>;
  } else if (response.statusCode == 401) {
    throw const HttpException('Token Scaduto, esegui nuovamente il login');
  } else {
    Map<String, dynamic> error = jsonDecode(response.body);
    throw Exception(error['error']);
  }
}

/*
  METODO PER OTTENERE TUTTI I SENSORI ASSOCIATI A UN NODO
  - Scopo: Recupera una lista di tutti i sensori (analogici e binari) associati a un nodo specifico.
  - Parametri:
    - nodeId: ID del nodo di cui si vogliono ottenere i sensori.
    - token: Il token di autenticazione.
  - Ritorno: Un oggetto Future<Map<String, dynamic>> contenente le liste dei sensori analogici e binari.
*/
Future<Map<String, dynamic>> getAllNodeSensors(
    String nodeId, String token) async {
  final response = await requestHelper.postRequest(
      '/areas/nodes/sensors/', {"id_node": nodeId}, token);

  if (response.statusCode == 200) {
    final List<Sensor> sensors = [];
    final List<BinarySensor> binarySensors = [];
    Map<String, dynamic> json = jsonDecode(response.body);
    for (Map<String, dynamic> sensor in json['sensors']) {
      sensors.add(Sensor.fromJson(sensor));
    }
    for (Map<String, dynamic> binarySensor in json['binary_sensors']) {
      binarySensors.add(BinarySensor.fromJson(binarySensor));
    }
    return {"sensors": sensors, "binary_sensors": binarySensors};
  } else if (response.statusCode == 401) {
    throw const HttpException('Token Scaduto, esegui nuovamente il login');
  } else {
    Map<String, dynamic> error = jsonDecode(response.body);
    throw Exception(error['error']);
  }
}

class StatoNodo {
  final String id;
  final DateTime start;
  final DateTime? end;
  final String status;

  StatoNodo(
      {required this.id,
      required this.start,
      required this.end,
      required this.status});

  /*
    COSTRUTTORE FACTORY PER STATONODO
    - Scopo: Crea un'istanza di StatoNodo a partire da un oggetto JSON.
    - Parametri:
      - json: Mappa contenente i dati dello stato del nodo.
    - Ritorno: Un'istanza di StatoNodo.
  */
  factory StatoNodo.fromJson(Map<String, dynamic> json) {
    final String id = json['id_node'];
    final DateTime start = historyDateFormatter.parseUtc(json['start']);
    final DateTime? end =
        json['end'] == null ? null : historyDateFormatter.parseUtc(json['end']);
    final String status = json['node_status'];

    return StatoNodo(id: id, start: start, end: end, status: status);
  }
}

/*
  METODO PER OTTENERE LA CRONOLOGIA DEGLI STATI DI UN NODO
  - Scopo: Recupera la cronologia degli stati di un nodo specifico in un intervallo di tempo.
  - Parametri:
    - nodeId: ID del nodo di cui si vuole ottenere la cronologia degli stati.
    - start: Data di inizio dell'intervallo di tempo.
    - end: Data di fine dell'intervallo di tempo.
    - token: Il token di autenticazione.
  - Ritorno: Un oggetto Future<List<StatoNodo>> contenente la cronologia degli stati del nodo.
*/
Future<List<StatoNodo>> getNodeStatusHistory(
    String nodeId, DateTime start, DateTime end, String token) async {
  final response = await requestHelper.postRequest(
      '/areas/nodes/history',
      {
        "id_node": nodeId,
        "start": dateTimeFormatter.format(start),
        "end": dateTimeFormatter.format(end)
      },
      token);

  if (response.statusCode == 200) {
    final List<StatoNodo> states = [];
    for (Map<String, dynamic> element
        in jsonDecode(response.body) as List<dynamic>) {
      StatoNodo stato = StatoNodo.fromJson(element);
      states.add(stato);
    }
    return states;
  } else if (response.statusCode == 401) {
    throw const HttpException('Token Scaduto, esegui nuovamente il login');
  } else {
    Map<String, dynamic> error = jsonDecode(response.body);
    throw Exception(error['error']);
  }
}

/// ******************************************************************************
/// GESTIONE NOTIFICHE

class NotificaSensore {
  final int id;
  final DateTime dataCreazione;
  final String nome;
  final String trigger;
  final double benchmark;
  final bool status;

  NotificaSensore(
      {required this.id,
      required this.dataCreazione,
      required this.nome,
      required this.trigger,
      required this.benchmark,
      required this.status});

  /*
    COSTRUTTORE FACTORY PER NOTIFICASENSORE
    - Scopo: Crea un'istanza di NotificaSensore a partire da un oggetto JSON.
    - Parametri:
      - json: Mappa contenente i dati della notifica del sensore.
    - Ritorno: Un'istanza di NotificaSensore.
  */
  factory NotificaSensore.fromJson(Map<String, dynamic> json) {
    final int id = json['id_notify'];
    final String nome = json['name'];
    final DateTime dataCreazione = historyDateFormatter.parseUtc(json['date']);
    final String trigger = json['trigger'];
    final double benchmark = double.parse(json['benchmark']);
    final bool status = json['status'];

    return NotificaSensore(
        id: id,
        nome: nome,
        dataCreazione: dataCreazione,
        trigger: trigger,
        benchmark: benchmark,
        status: status);
  }
}

/*
  METODO PER OTTENERE TUTTE LE NOTIFICHE DELL'UTENTE PER UN SENSORI
  - Scopo: Recupera una lista di tutte le notifiche associate a un sensore specifico.
  - Parametri:
    - idSensor: ID del sensore di cui si vogliono ottenere le notifiche.
    - token: Il token di autenticazione.
  - Ritorno: Un oggetto Future<List<NotificaSensore>> contenente la lista delle notifiche.
*/
Future<List<NotificaSensore>> getAllUserNotify(
    String idSensor, String token) async {
  final response = await requestHelper.postRequest(
      '/notify/', {'id_sensor': idSensor}, token);

  if (response.statusCode == 200) {
    final List<NotificaSensore> notifiche = [];
    for (Map<String, dynamic> element
        in jsonDecode(response.body) as List<dynamic>) {
      NotificaSensore notifica = NotificaSensore.fromJson(element);
      notifiche.add(notifica);
    }
    return notifiche;
  } else if (response.statusCode == 401) {
    throw const HttpException('Token Scaduto, esegui nuovamente il login');
  } else {
    Map<String, dynamic> error = jsonDecode(response.body);
    throw Exception(error['error']);
  }
}

/*
  METODO PER AGGIUNGERE UNA NUOVA NOTIFICA
  - Scopo: Aggiunge una nuova notifica per un sensore specifico.
  - Parametri:
    - idSensor: ID del sensore per il quale si vuole aggiungere la notifica.
    - nome: Nome della notifica.
    - trigger: Condizione di attivazione della notifica.
    - benchmark: Valore di riferimento per la notifica.
    - token: Il token di autenticazione.
  - Ritorno: Un oggetto Future<String> contenente un messaggio di conferma.
*/
Future<String> addNotify(String idSensor, String nome, String trigger,
    double benchmark, String token) async {
  final response = await requestHelper.postRequest(
      '/notify/add',
      {
        "id_sensor": idSensor,
        "date": dateTimeFormatter.format(DateTime.now()),
        "name": nome,
        "trigger": trigger,
        "benchmark": benchmark,
        "status": true
      },
      token);

  if (response.statusCode == 201) {
    Map<String, dynamic> message = jsonDecode(response.body);
    return message['message'];
  } else if (response.statusCode == 401) {
    throw const HttpException('Token Scaduto, esegui nuovamente il login');
  } else {
    Map<String, dynamic> error = jsonDecode(response.body);
    throw Exception(error['error']);
  }
}

/*
  METODO PER ELIMINARE UNA NOTIFICA
  - Scopo: Elimina una notifica specifica.
  - Parametri:
    - id: ID della notifica da eliminare.
    - token: Il token di autenticazione.
  - Ritorno: Un oggetto Future<String> contenente un messaggio di conferma.
*/
Future<String> deleteNotify(int id, String token) async {
  final response =
      await requestHelper.deleteRequest('/notify/', {"id_notify": id}, token);

  if (response.statusCode == 200) {
    Map<String, dynamic> message = jsonDecode(response.body);
    return message['message'];
  } else if (response.statusCode == 401) {
    throw const HttpException('Token Scaduto, esegui nuovamente il login');
  } else {
    Map<String, dynamic> error = jsonDecode(response.body);
    throw Exception(error['error']);
  }
}

class NotificaSensoreBinario {
  final int id;
  final DateTime dataCreazione;
  final String nome;
  final bool benchmark;
  final bool status;

  NotificaSensoreBinario(
      {required this.id,
      required this.dataCreazione,
      required this.nome,
      required this.benchmark,
      required this.status});

  /*
    COSTRUTTORE FACTORY PER NOTIFICASENSORBINARIO
    - Scopo: Crea un'istanza di NotificaSensoreBinario a partire da un oggetto JSON.
    - Parametri:
      - json: Mappa contenente i dati della notifica del sensore binario.
    - Ritorno: Un'istanza di NotificaSensoreBinario.
  */
  factory NotificaSensoreBinario.fromJson(Map<String, dynamic> json) {
    final int id = json['id_notify'];
    final String nome = json['name'];
    final DateTime dataCreazione = historyDateFormatter.parseUtc(json['date']);
    final bool benchmark = json['benchmark'];
    final bool status = json['status'];

    return NotificaSensoreBinario(
        id: id,
        nome: nome,
        dataCreazione: dataCreazione,
        benchmark: benchmark,
        status: status);
  }
}

/*
  METODO PER OTTENERE TUTTE LE NOTIFICHE BINARIE DELL'UTENTE
  - Scopo: Recupera una lista di tutte le notifiche binarie associate a un sensore specifico.
  - Parametri:
    - idSensor: ID del sensore binario di cui si vogliono ottenere le notifiche.
    - token: Il token di autenticazione.
  - Ritorno: Un oggetto Future<List<NotificaSensoreBinario>> contenente la lista delle notifiche.
*/
Future<List<NotificaSensoreBinario>> getAllUserBinaryNotify(
    String idSensor, String token) async {
  final response = await requestHelper.postRequest(
      '/notify/', {'id_bin_sensor': idSensor}, token);

  if (response.statusCode == 200) {
    final List<NotificaSensoreBinario> notifiche = [];
    for (Map<String, dynamic> element
        in jsonDecode(response.body) as List<dynamic>) {
      NotificaSensoreBinario notifica =
          NotificaSensoreBinario.fromJson(element);
      notifiche.add(notifica);
    }
    return notifiche;
  } else if (response.statusCode == 401) {
    throw const HttpException('Token Scaduto, esegui nuovamente il login');
  } else {
    Map<String, dynamic> error = jsonDecode(response.body);
    throw Exception(error['error']);
  }
}

/*
  METODO PER AGGIUNGERE UNA NUOVA NOTIFICA BINARY
  - Scopo: Aggiunge una nuova notifica binaria per un sensore binario specifico.
  - Parametri:
    - idBinSensor: ID del sensore binario per il quale si vuole aggiungere la notifica.
    - nome: Nome della notifica.
    - benchmark: Condizione di attivazione della notifica (true/false).
    - token: Il token di autenticazione.
  - Ritorno: Un oggetto Future<String> contenente un messaggio di conferma.
*/
Future<String> addBinaryNotify(
    String idBinSensor, String nome, bool benchmark, String token) async {
  final response = await requestHelper.postRequest(
      '/notify/add_binary',
      {
        "id_bin_sensor": idBinSensor,
        "date": dateTimeFormatter.format(DateTime.now()),
        "name": nome,
        "benchmark": benchmark,
        "status": true
      },
      token);

  if (response.statusCode == 201) {
    Map<String, dynamic> message = jsonDecode(response.body);
    return message['message'];
  } else if (response.statusCode == 401) {
    throw const HttpException('Token Scaduto, esegui nuovamente il login');
  } else {
    Map<String, dynamic> error = jsonDecode(response.body);
    throw Exception(error['error']);
  }
}

/*
  METODO PER ELIMINARE UNA NOTIFICA BINARY
  - Scopo: Elimina una notifica binaria specifica.
  - Parametri:
    - id: ID della notifica binaria da eliminare.
    - token: Il token di autenticazione.
  - Ritorno: Un oggetto Future<String> contenente un messaggio di conferma.
*/
Future<String> deleteBinaryNotify(int id, String token) async {
  final response = await requestHelper.deleteRequest(
      '/notify/', {"id_bin_notify": id}, token);

  if (response.statusCode == 200) {
    Map<String, dynamic> message = jsonDecode(response.body);
    return message['message'];
  } else if (response.statusCode == 401) {
    throw const HttpException('Token Scaduto, esegui nuovamente il login');
  } else {
    Map<String, dynamic> error = jsonDecode(response.body);
    throw Exception(error['error']);
  }
}

/*
  METODO PER AGGIORNARE LO STATO DI UNA NOTIFICA
  - Scopo: Modifica lo stato di una notifica esistente.
  - Parametri:
    - id: ID della notifica di cui modificare lo stato.
    - token: Il token di autenticazione.
  - Ritorno: Un oggetto Future<String> contenente un messaggio di conferma.
*/
Future<String> updateNotify(int id, String token) async {
  final response = await requestHelper.postRequest(
      '/notify/change_status', {"id_notify": id}, token);

  if (response.statusCode == 200) {
    Map<String, dynamic> message = jsonDecode(response.body);
    return message['message'];
  } else if (response.statusCode == 401) {
    throw const HttpException('Token Scaduto, esegui nuovamente il login');
  } else {
    Map<String, dynamic> error = jsonDecode(response.body);
    throw Exception(error['error']);
  }
}
