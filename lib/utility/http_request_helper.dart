import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpRequestHelper {

  // PATH DI DEFAULT PER L'API
  final String _apiUrl = 'http://192.168.33.5:5000/api';

  // METODO HELPER PER RICHIESTE GET
  Future<http.Response> getRequest(String endpoint, [String? username, String? password]) async {
    if (username != null && password != null) {
      return await http.get(
        Uri.parse('$_apiUrl$endpoint'),
        headers: {
          'authorization': 'Basic ${base64.encode(utf8.encode('$username:$password'))}',
        },
      );
    } else {
      return await http.get(Uri.parse('$_apiUrl$endpoint'));
    }
  }

  // METODO HELPER PER RICHIESTE POST
  Future<http.Response> postRequest(String endpoint, Map<String, dynamic> body, [String? username, String? password]) async {
    if (username != null && password != null) {
      return await http.post(
        Uri.parse('$_apiUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Basic ${base64.encode(utf8.encode('$username:$password'))}',
        },
        body: json.encode(body),
      );
    } else {
      return await http.post(
        Uri.parse('$_apiUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );
    }
  }

  // METODO HELPER PER RICHIESTE DELETE
  Future<http.Response> deleteRequest(String endpoint, Map<String, dynamic> body, [String? username, String? password]) async {
    if (username != null && password != null) {
      return await http.delete(
        Uri.parse('$_apiUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Basic ${base64.encode(utf8.encode('$username:$password'))}',
        },
        body: json.encode(body),
      );
    } else {
      return await http.delete(
        Uri.parse('$_apiUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );
    }
  }
}