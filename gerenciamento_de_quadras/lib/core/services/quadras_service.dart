import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/quadra_model.dart';
import 'auth_service.dart';

class PaginaQuadras {
  final List<QuadraModel> itens;
  final int pagina;
  final int tamanho;
  final int total;
  final int totalPaginas;

  const PaginaQuadras({
    required this.itens,
    required this.pagina,
    required this.tamanho,
    required this.total,
    required this.totalPaginas,
  });
}

class QuadrasService {
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

  Future<PaginaQuadras> listarQuadras({
    int pagina = 1,
    int tamanho = 10,
    String? busca,
  }) async {
    final queryParams = <String, String>{
      'pagina': pagina.toString(),
      'tamanho': tamanho.toString(),
      if (busca != null && busca.trim().isNotEmpty) 'busca': busca.trim(),
    };

    final uri = Uri.parse('${AuthService.baseUrl}/quadras')
        .replace(queryParameters: queryParams);

    final headers = await _authService.obterHeadersAutenticados();
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final listaBruta =
          (body['itens'] ?? body['items'] ?? body['dados'] ?? [])
              as List<dynamic>;

      final itens = listaBruta
          .map((e) => QuadraModel.fromJson(e as Map<String, dynamic>))
          .toList();

      final total =
          (body['total'] ?? body['totalItens'] ?? itens.length) as int;
      final totalPaginas =
          (body['totalPaginas'] ?? body['paginas'] ?? 1) as int;

      return PaginaQuadras(
        itens: itens,
        pagina: (body['pagina'] ?? pagina) as int,
        tamanho: (body['tamanho'] ?? tamanho) as int,
        total: total,
        totalPaginas: totalPaginas < 1 ? 1 : totalPaginas,
      );
    }

    throw Exception(
      _extrairMensagemErro(response.body, 'Erro ao carregar quadras.'),
    );
  }

  Future<QuadraModel> criarQuadra({
    required String nome,
    required String localizacao,
    String? descricao,
    required int duracaoSessaoMin,
    required List<IntervaloFuncionamentoModel> horarios,
  }) async {
    final uri = Uri.parse('${AuthService.baseUrl}/quadras');
    final headers = await _authService.obterHeadersAutenticados();

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({
        'nome': nome,
        'localizacao': localizacao,
        'descricao': (descricao == null || descricao.trim().isEmpty)
            ? null
            : descricao.trim(),
        'duracaoSessaoMin': duracaoSessaoMin,
        'horarios': horarios.map((h) => h.toJson()).toList(),
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return QuadraModel.fromJson(body);
    }

    throw Exception(
      _extrairMensagemErro(response.body, 'Erro ao criar quadra.'),
    );
  }

  Future<QuadraModel> atualizarQuadra({
    required int id,
    required String nome,
    required String localizacao,
    String? descricao,
    required int duracaoSessaoMin,
    required List<IntervaloFuncionamentoModel> horarios,
  }) async {
    final uri = Uri.parse('${AuthService.baseUrl}/quadras/$id');
    final headers = await _authService.obterHeadersAutenticados();

    final response = await http.put(
      uri,
      headers: headers,
      body: jsonEncode({
        'nome': nome,
        'localizacao': localizacao,
        'descricao': (descricao == null || descricao.trim().isEmpty)
            ? null
            : descricao.trim(),
        'duracaoSessaoMin': duracaoSessaoMin,
        'horarios': horarios.map((h) => h.toJson()).toList(),
      }),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return QuadraModel.fromJson(body);
    }

    throw Exception(
      _extrairMensagemErro(response.body, 'Erro ao atualizar quadra.'),
    );
  }

  Future<void> deletarQuadra(int id) async {
    final uri = Uri.parse('${AuthService.baseUrl}/quadras/$id');
    final headers = await _authService.obterHeadersAutenticados();

    final response = await http.delete(uri, headers: headers);

    if (response.statusCode == 204 || response.statusCode == 200) {
      return;
    }

    throw Exception(
      _extrairMensagemErro(response.body, 'Erro ao remover quadra.'),
    );
  }
}
