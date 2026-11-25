import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/agendamento_model.dart';
import 'auth_service.dart';

class PaginaAgendamentos {
  final List<AgendamentoModel> itens;
  final int pagina;
  final int tamanho;
  final int total;
  final int totalPaginas;

  const PaginaAgendamentos({
    required this.itens,
    required this.pagina,
    required this.tamanho,
    required this.total,
    required this.totalPaginas,
  });
}

class AgendamentosService {
  final AuthService _authService = AuthService();

  String _extrairMensagemErro(String responseBody, String padrao) {
    try {
      final body = jsonDecode(responseBody) as Map<String, dynamic>;
      return (body['mensagem'] ?? body['erro'])?.toString() ?? padrao;
    } catch (_) {
      return padrao;
    }
  }

  Future<PaginaAgendamentos> listarAgendamentos({
    int pagina = 1,
    int tamanho = 10,
    String? escopo,
    String? busca,
  }) async {
    final queryParams = <String, String>{
      'pagina': pagina.toString(),
      'tamanho': tamanho.toString(),
      if (escopo != null && escopo.isNotEmpty) 'escopo': escopo,
      if (busca != null && busca.trim().isNotEmpty) 'busca': busca.trim(),
    };

    final uri = Uri.parse('${AuthService.baseUrl}/agendamentos')
        .replace(queryParameters: queryParams);

    final headers = await _authService.obterHeadersAutenticados();
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final lista = (body['itens'] ?? []) as List<dynamic>;

      final itens = lista
          .map((e) => AgendamentoModel.fromJson(e as Map<String, dynamic>))
          .toList();

      final totalPaginas = (body['totalPaginas'] ?? 1) as int;

      return PaginaAgendamentos(
        itens: itens,
        pagina: (body['pagina'] ?? pagina) as int,
        tamanho: (body['tamanho'] ?? tamanho) as int,
        total: (body['total'] ?? itens.length) as int,
        totalPaginas: totalPaginas < 1 ? 1 : totalPaginas,
      );
    }

    throw Exception(
      _extrairMensagemErro(response.body, 'Erro ao carregar agendamentos.'),
    );
  }

  Future<List<DateTime>> buscarHorariosLivres({
    required int quadraId,
    required DateTime data,
    int? ignorarAgendamentoId,
  }) async {
    final dataIso =
        '${data.year.toString().padLeft(4, '0')}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}';

    final uri =
        Uri.parse('${AuthService.baseUrl}/agendamentos/livres/$quadraId')
            .replace(
              queryParameters: {
                'data': dataIso,
                if (ignorarAgendamentoId != null)
                  'ignorarAgendamentoId': ignorarAgendamentoId.toString(),
              },
            );

    final headers = await _authService.obterHeadersAutenticados();
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final lista = (body['horariosLivres'] ?? []) as List<dynamic>;
      return lista.map((e) => DateTime.parse(e as String).toLocal()).toList();
    }

    throw Exception(
      _extrairMensagemErro(response.body, 'Erro ao buscar horários livres.'),
    );
  }

  Future<void> criarAgendamento({
    required int quadraId,
    required DateTime dataInicio,
    required DateTime dataFim,
    double valorTotal = 0.0,
  }) async {
    final uri = Uri.parse('${AuthService.baseUrl}/agendamentos');
    final headers = await _authService.obterHeadersAutenticados();

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({
        'quadraId': quadraId,
        'dataInicio': dataInicio.toIso8601String(),
        'dataFim': dataFim.toIso8601String(),
        'valorTotal': valorTotal,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) return;

    throw Exception(
      _extrairMensagemErro(response.body, 'Erro ao criar agendamento.'),
    );
  }

  Future<void> atualizarAgendamento({
    required int id,
    required int quadraId,
    required DateTime dataInicio,
    required DateTime dataFim,
    double valorTotal = 0.0,
  }) async {
    final uri = Uri.parse('${AuthService.baseUrl}/agendamentos/$id');
    final headers = await _authService.obterHeadersAutenticados();

    final response = await http.put(
      uri,
      headers: headers,
      body: jsonEncode({
        'quadraId': quadraId,
        'dataInicio': dataInicio.toIso8601String(),
        'dataFim': dataFim.toIso8601String(),
        'valorTotal': valorTotal,
      }),
    );

    if (response.statusCode == 200) return;

    throw Exception(
      _extrairMensagemErro(response.body, 'Erro ao atualizar agendamento.'),
    );
  }

  Future<void> cancelarAgendamento(int id) async {
    final uri = Uri.parse('${AuthService.baseUrl}/agendamentos/$id');
    final headers = await _authService.obterHeadersAutenticados();

    final response = await http.delete(uri, headers: headers);
    if (response.statusCode == 204 || response.statusCode == 200) return;

    throw Exception(
      _extrairMensagemErro(response.body, 'Erro ao cancelar agendamento.'),
    );
  }

  Future<RelatorioMetricasModel> obterRelatorios({
    DateTime? inicio,
    DateTime? fim,
  }) async {
    String formatarIso(DateTime dt) =>
        '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

    final uri = Uri.parse('${AuthService.baseUrl}/agendamentos/relatorios')
        .replace(
          queryParameters: {
            if (inicio != null) 'inicio': formatarIso(inicio),
            if (fim != null) 'fim': formatarIso(fim),
          },
        );

    final headers = await _authService.obterHeadersAutenticados();
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return RelatorioMetricasModel.fromJson(body);
    }

    throw Exception(
      _extrairMensagemErro(response.body, 'Erro ao carregar relatórios.'),
    );
  }
}
