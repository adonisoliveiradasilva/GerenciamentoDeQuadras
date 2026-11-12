import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthService {
  // Endereço utilizado pelo emulador Android para acessar o computador.
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

    final Map<String, dynamic> body;

    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('O servidor retornou uma resposta inválida.');
    }

    if (response.statusCode == 200) {
      return body;
    }

    throw Exception(body['mensagem'] ?? 'Falha ao realizar login.');
  }
}
