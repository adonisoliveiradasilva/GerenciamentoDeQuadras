import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Endereço utilizado pelo emulador Android para acessar o computador.
  static const String baseUrl = 'http://10.0.2.2:8080';

  static const String _tokenKey = 'auth_token';
  static const String _expiraEmKey = 'auth_expira_em';
  static const String _usuarioKey = 'auth_usuario';

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
      await _salvarSessao(body);
      return body;
    }

    throw Exception(body['mensagem'] ?? 'Falha ao realizar login.');
  }

  Future<void> _salvarSessao(Map<String, dynamic> dados) async {
    final prefs = await SharedPreferences.getInstance();

    final token = dados['token'];
    final expiraEm = dados['expiraEm'];
    final usuario = dados['usuario'];

    if (token is String && token.isNotEmpty) {
      await prefs.setString(_tokenKey, token);
    }

    if (expiraEm is String && expiraEm.isNotEmpty) {
      await prefs.setString(_expiraEmKey, expiraEm);
    }

    if (usuario != null) {
      await prefs.setString(_usuarioKey, jsonEncode(usuario));
    }
  }

  Future<String?> obterToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<Map<String, dynamic>?> obterUsuarioSalvo() async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioJson = prefs.getString(_usuarioKey);

    if (usuarioJson == null || usuarioJson.isEmpty) return null;

    try {
      return jsonDecode(usuarioJson) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, String>> obterHeadersAutenticados() async {
    final token = await obterToken();

    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> buscarUsuarioAtual() async {
    final url = Uri.parse('$baseUrl/auth/eu');
    final headers = await obterHeadersAutenticados();

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final usuario = jsonDecode(response.body) as Map<String, dynamic>;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_usuarioKey, jsonEncode(usuario));

      return usuario;
    }

    if (response.statusCode == 401) {
      await logout();
      throw Exception('Sessão expirada. Faça login novamente.');
    }

    throw Exception('Não foi possível validar a sessão.');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_tokenKey);
    await prefs.remove(_expiraEmKey);
    await prefs.remove(_usuarioKey);
  }
}
