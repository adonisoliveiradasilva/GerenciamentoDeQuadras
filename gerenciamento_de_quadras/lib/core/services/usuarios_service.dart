import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/usuario_model.dart';
import 'auth_service.dart';

class PaginaUsuarios {
  final List<UsuarioModel> itens;
  final int pagina;
  final int tamanho;
  final int total;
  final int totalPaginas;

  const PaginaUsuarios({
    required this.itens,
    required this.pagina,
    required this.tamanho,
    required this.total,
    required this.totalPaginas,
  });
}

class UsuariosService {
  final AuthService _authService = AuthService();

  String _extrairMensagemErro(String responseBody, String padrao) {
    try {
      final body = jsonDecode(responseBody) as Map<String, dynamic>;
      final campos = body['campos'];
      if (campos is Map && campos.isNotEmpty) {
        return campos.values.join('\n');
      }
      return body['mensagem']?.toString() ?? padrao;
    } catch (_) {
      return padrao;
    }
  }

  Future<PaginaUsuarios> _listar(
    String recurso, {
    int pagina = 1,
    int tamanho = 10,
    String? busca,
  }) async {
    final queryParams = <String, String>{
      'pagina': pagina.toString(),
      'tamanho': tamanho.toString(),
      if (busca != null && busca.trim().isNotEmpty) 'busca': busca.trim(),
    };

    final uri = Uri.parse('${AuthService.baseUrl}/$recurso')
        .replace(queryParameters: queryParams);

    final headers = await _authService.obterHeadersAutenticados();
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final listaBruta = (body['itens'] ?? []) as List<dynamic>;

      final itens = listaBruta
          .map((e) => UsuarioModel.fromJson(e as Map<String, dynamic>))
          .toList();

      final total = (body['total'] ?? itens.length) as int;
      final totalPaginas = (body['totalPaginas'] ?? 1) as int;

      return PaginaUsuarios(
        itens: itens,
        pagina: (body['pagina'] ?? pagina) as int,
        tamanho: (body['tamanho'] ?? tamanho) as int,
        total: total,
        totalPaginas: totalPaginas < 1 ? 1 : totalPaginas,
      );
    }

    throw Exception(
      _extrairMensagemErro(response.body, 'Erro ao carregar registros.'),
    );
  }

  // --- CLIENTES ---

  Future<PaginaUsuarios> listarClientes({
    int pagina = 1,
    int tamanho = 10,
    String? busca,
  }) => _listar('clientes', pagina: pagina, tamanho: tamanho, busca: busca);

  Future<UsuarioModel> criarCliente({
    required String nome,
    required String email,
    String? telefone,
    String? dataNascimentoIso,
  }) async {
    final uri = Uri.parse('${AuthService.baseUrl}/clientes');
    final headers = await _authService.obterHeadersAutenticados();

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({
        'nome': nome,
        'email': email,
        if (telefone != null && telefone.isNotEmpty) 'telefone': telefone,
        if (dataNascimentoIso != null && dataNascimentoIso.isNotEmpty)
          'dataNascimento': dataNascimentoIso,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return UsuarioModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw Exception(
      _extrairMensagemErro(response.body, 'Erro ao cadastrar cliente.'),
    );
  }

  Future<UsuarioModel> atualizarCliente({
    required int id,
    required String nome,
    required String email,
    String? telefone,
    String? dataNascimentoIso,
  }) async {
    final uri = Uri.parse('${AuthService.baseUrl}/clientes/$id');
    final headers = await _authService.obterHeadersAutenticados();

    final response = await http.put(
      uri,
      headers: headers,
      body: jsonEncode({
        'nome': nome,
        'email': email,
        'telefone': (telefone != null && telefone.isNotEmpty) ? telefone : null,
        'dataNascimento':
            (dataNascimentoIso != null && dataNascimentoIso.isNotEmpty)
            ? dataNascimentoIso
            : null,
      }),
    );

    if (response.statusCode == 200) {
      return UsuarioModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw Exception(
      _extrairMensagemErro(response.body, 'Erro ao atualizar cliente.'),
    );
  }

  Future<void> deletarCliente(int id) async {
    final uri = Uri.parse('${AuthService.baseUrl}/clientes/$id');
    final headers = await _authService.obterHeadersAutenticados();

    final response = await http.delete(uri, headers: headers);
    if (response.statusCode == 204 || response.statusCode == 200) return;

    throw Exception(
      _extrairMensagemErro(response.body, 'Erro ao remover cliente.'),
    );
  }

  // --- FUNCIONÁRIOS ---

  Future<PaginaUsuarios> listarFuncionarios({
    int pagina = 1,
    int tamanho = 10,
    String? busca,
  }) => _listar('funcionarios', pagina: pagina, tamanho: tamanho, busca: busca);

  Future<UsuarioModel> criarFuncionario({
    required String nome,
    required String email,
    String? dataNascimentoIso,
    required String senha,
    required String confirmarSenha,
  }) async {
    final uri = Uri.parse('${AuthService.baseUrl}/funcionarios');
    final headers = await _authService.obterHeadersAutenticados();

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({
        'nome': nome,
        'email': email,
        if (dataNascimentoIso != null && dataNascimentoIso.isNotEmpty)
          'dataNascimento': dataNascimentoIso,
        'senha': senha,
        'confirmarSenha': confirmarSenha,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return UsuarioModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw Exception(
      _extrairMensagemErro(response.body, 'Erro ao cadastrar funcionário.'),
    );
  }

  Future<UsuarioModel> atualizarFuncionario({
    required int id,
    required String nome,
    required String email,
    String? dataNascimentoIso,
    String? senha,
    String? confirmarSenha,
  }) async {
    final uri = Uri.parse('${AuthService.baseUrl}/funcionarios/$id');
    final headers = await _authService.obterHeadersAutenticados();

    final payload = <String, dynamic>{
      'nome': nome,
      'email': email,
      'dataNascimento':
          (dataNascimentoIso != null && dataNascimentoIso.isNotEmpty)
          ? dataNascimentoIso
          : null,
    };

    if (senha != null && senha.isNotEmpty) {
      payload['senha'] = senha;
      payload['confirmarSenha'] = confirmarSenha ?? '';
    }

    final response = await http.put(
      uri,
      headers: headers,
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      return UsuarioModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw Exception(
      _extrairMensagemErro(response.body, 'Erro ao atualizar funcionário.'),
    );
  }

  Future<void> deletarFuncionario(int id) async {
    final uri = Uri.parse('${AuthService.baseUrl}/funcionarios/$id');
    final headers = await _authService.obterHeadersAutenticados();

    final response = await http.delete(uri, headers: headers);
    if (response.statusCode == 204 || response.statusCode == 200) return;

    throw Exception(
      _extrairMensagemErro(response.body, 'Erro ao remover funcionário.'),
    );
  }
}
