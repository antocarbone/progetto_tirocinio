import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpRequestHelper {

  // PATH DI DEFAULT PER L'API
  final String _apiUrl = 'http://192.168.33.5:5000/api';

  // METODO HELPER PER RICHIESTE GET
  Future<http.Response> getRequest(String endpoint) async {
      return await http.get(Uri.parse('$_apiUrl$endpoint'));
  }

  // METODO HELPER PER RICHIESTE POST
  Future<http.Response> postRequest(String endpoint, Map<String, dynamic> body) async {
    return await http.post(
      Uri.parse('$_apiUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
  }

  // METODO HELPER PER RICHIESTE DELETE
  Future<http.Response> deleteRequest(String endpoint, Map<String, dynamic> body) async {
      return await http.delete(
        Uri.parse('$_apiUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );
  }
}