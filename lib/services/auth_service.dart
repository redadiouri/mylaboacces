import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_storage.dart';

class AuthService {
  static const String apiUrl = "http://localhost/mylaboapi/public/api";

  /// LOGIN (connection)
  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$apiUrl/login"),
      headers: {"Accept": "application/json"},
      body: {
        "email": email,
        "password": password,
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final token = body["token"];

      String? role;
      if (body["user"] != null && body["user"]["role"] != null) {
        role = body["user"]["role"].toString();
      }

      await TokenStorage.save(token: token, role: role);

      return true;
    }

    return false;
  }

  /// LOGOUT (deconnection)
  Future<void> logout() async {
    await TokenStorage.clear();
  }

  /// AUTH STATE
  Future<bool> isLoggedIn() async {
    return (await TokenStorage.getToken()) != null;
  }

  /// TOKEN
  Future<String?> getToken() {
    return TokenStorage.getToken();
  }

  /// ROLE
  Future<String?> getRole() {
    return TokenStorage.getRole();
  }

  /// ROLE CHECK
  Future<bool> isAdmin() async {
    return (await getRole()) == 'admin';
  }

  /// AUTH HEADERS
  Future<Map<String, String>> authHeaders() async {
    final token = await getToken();
    final headers = {"Accept": "application/json"};
    if (token != null) headers["Authorization"] = "Bearer $token";
    return headers;
  }
}
