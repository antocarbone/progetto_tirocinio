import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpRequestHelper {
  // PATH DI DEFAULT PER L'API
  final String _apiUrl = 'http://192.168.33.5:5000/api';

  /*
    METODO HELPER PER RICHIESTE GET
    - Scopo: Esegue una richiesta HTTP GET all'endpoint specificato.
    - Parametri:
      - endpoint: L'endpoint dell'API a cui inviare la richiesta.
      - auth (opzionale): La stringa di autenticazione di base da includere nelle intestazioni della richiesta.
    - Ritorno: Un oggetto Future<http.Response> contenente la risposta della richiesta.
  */
  Future<http.Response> getRequest(String endpoint, [String? auth]) async {
    return await http.get(
      Uri.parse('$_apiUrl$endpoint'),
      headers: auth != null ? {'authorization': 'Basic $auth'} : null,
    );
  }

  /*
    METODO HELPER PER RICHIESTE POST
    - Scopo: Esegue una richiesta HTTP POST all'endpoint specificato con il corpo della richiesta fornito.
    - Parametri:
      - endpoint: L'endpoint dell'API a cui inviare la richiesta.
      - body: Un Map<String, dynamic> contenente i dati da inviare come corpo della richiesta.
      - auth (opzionale): La stringa di autenticazione di base da includere nelle intestazioni della richiesta.
    - Ritorno: Un oggetto Future<http.Response> contenente la risposta della richiesta.
  */
  Future<http.Response> postRequest(String endpoint, Map<String, dynamic> body,
      [String? auth]) async {
    Map<String, String> header = {'Content-Type': 'application/json'};
    auth != null ? header.addAll({'authorization': 'Basic $auth'}) : null;
    return await http.post(
      Uri.parse('$_apiUrl$endpoint'),
      headers: header,
      body: jsonEncode(body),
    );
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
    Map<String, String> header = {'Content-Type': 'application/json'};
    auth != null ? header.addAll({'authorization': 'Basic $auth'}) : null;
    return await http.delete(
      Uri.parse('$_apiUrl$endpoint'),
      headers: header,
      body: jsonEncode(body),
    );
  }
}
