import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthService {
  // Use 10.0.2.2 se estiver testando em um emulador Android.
  static const String baseUrl = 'http://10.0.2.2:8080';

  Future<Map<String, dynamic>> login({
    required String email,
    required String senha,
  }) async {
    final url = Uri.parse('$baseUrl/auth/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'senha': senha}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['mensagem'] ?? 'Falha ao realizar login');
    }
  }
}
