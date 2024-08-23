import 'dart:convert';
import 'package:dashboard_tirocinio/utility/utils.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:http/http.dart' as http;

class HttpRequestHelper {
  /*
    METODO HELPER PER RICHIESTE GET
    - Scopo: Esegue una richiesta HTTP GET all'endpoint specificato.
    - Parametri:
      - endpoint: L'endpoint dell'API a cui inviare la richiesta.
      - auth (opzionale): La stringa di autenticazione di base da includere nelle intestazioni della richiesta.
    - Ritorno: Un oggetto Future<http.Response> contenente la risposta della richiesta.
  */
  Future<http.Response> getRequest(String endpoint, [String? auth]) async {
    await EncryptedSharedPreferences.initialize(Utils.encryptingKey);
    EncryptedSharedPreferences prefs = EncryptedSharedPreferences.getInstance();
    String? baseUrl = prefs.getString('url');
    if (baseUrl != null) {
      return await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: auth != null ? {'authorization': 'Basic $auth'} : null,
      );
    } else {
      throw Exception('Errore nel base url');
    }
  }

  /*
    METODO HELPER PER RICHIESTE POST
    - Scopo: Esegue una richiesta HTTP POST all'endpoint specificato con il corpo della richiesta fornito.
    - Parametri:
      - endpoint: L'endpoint dell'API a cui inviare la richiesta.
      - body (opzionale): Un Map<String, dynamic> contenente i dati da inviare come corpo della richiesta.
      - auth (opzionale): La stringa di autenticazione di base da includere nelle intestazioni della richiesta.
    - Ritorno: Un oggetto Future<http.Response> contenente la risposta della richiesta.
  */
  Future<http.Response> postRequest(String endpoint,
      [Map<String, dynamic>? body, String? auth]) async {
    await EncryptedSharedPreferences.initialize(Utils.encryptingKey);
    EncryptedSharedPreferences prefs = EncryptedSharedPreferences.getInstance();
    String? baseUrl = prefs.getString('url');
    if (baseUrl != null) {
      Map<String, String> header;
      if (body != null) {
        header = {'Content-Type': 'application/json'};
        auth != null ? header.addAll({'authorization': 'Basic $auth'}) : null;
        return await http.post(
          Uri.parse('$baseUrl$endpoint'),
          headers: header,
          body: jsonEncode(body),
        );
      } else {
        if (auth != null) {
          header = {'authorization': 'Basic $auth'};
          return await http.post(
            Uri.parse('$baseUrl$endpoint'),
            headers: header,
          );
        } else {
          return await http.post(
            Uri.parse('$baseUrl$endpoint'),
          );
        }
      }
    } else {
      throw Exception('Errore nel base url');
    }
  }

  /*
    METODO HELPER PER RICHIESTE DELETE
    - Scopo: Esegue una richiesta HTTP DELETE all'endpoint specificato con il corpo della richiesta fornito.
    - Parametri:
      - endpoint: L'endpoint dell'API a cui inviare la richiesta.
      - body: Un Map<String, dynamic> contenente i dati da inviare come corpo della richiesta.
      - auth (opzionale): La stringa di autenticazione di base da includere nelle intestazioni della richiesta.
    - Ritorno: Un oggetto Future<http.Response> contenente la risposta della richiesta.
  */
  Future<http.Response> deleteRequest(
      String endpoint, Map<String, dynamic> body,
      [String? auth]) async {
    await EncryptedSharedPreferences.initialize(Utils.encryptingKey);
    EncryptedSharedPreferences prefs = EncryptedSharedPreferences.getInstance();
    String? baseUrl = prefs.getString('url');
    if (baseUrl != null) {
      Map<String, String> header = {'Content-Type': 'application/json'};
      auth != null ? header.addAll({'authorization': 'Basic $auth'}) : null;
      return await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: header,
        body: jsonEncode(body),
      );
    } else {
      throw Exception('Errore nel base url');
    }
  }
}
