import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../../core/auth/middlewares_de_acesso.dart';
import '../../../core/auth/servico_de_token.dart';
import '../../../core/http/erros.dart';
import '../../../core/http/respostas.dart';
import '../../usuarios/domain/perfil.dart';
import '../domain/servico_de_agendamentos.dart';
import 'dados_do_agendamento_dto.dart';

class AgendamentosRotas {
  final ServicoDeAgendamentos _servico;
  final ServicoDeToken _servicoDeToken;

  AgendamentosRotas(this._servico, this._servicoDeToken);

  Router get router {
    final logado = const Pipeline().addMiddleware(exigirLogin(_servicoDeToken));

    final soCliente = logado.addMiddleware(exigirPerfis({Perfil.cliente}));

    final soGerente = logado.addMiddleware(exigirPerfis({Perfil.gerente}));

    final router = Router();

    router.get('/', logado.addHandler(_listarAgendamentos));
    router.post('/', soCliente.addHandler(_criarAgendamento));
    router.put('/<id>', soCliente.addHandler(_atualizarAgendamento));
    router.delete('/<id>', logado.addHandler(_cancelarAgendamento));
    router.get('/relatorios', soGerente.addHandler(_obterRelatorios));

    router.get(
      '/livres/<quadraId>',
      logado.addHandler(
        (Request request) =>
            _buscarHorariosLivres(request, request.params['quadraId']!),
      ),
    );

    return router;
  }

  Future<Response> _listarAgendamentos(Request request) async {
    final usuario = request.usuarioAutenticado;
    final params = request.url.queryParameters;

    final pagina = int.tryParse(params['pagina'] ?? '1') ?? 1;
    final tamanho = int.tryParse(params['tamanho'] ?? '10') ?? 10;

    final escopo = params['escopo'];
    final busca = params['busca'];

    final listaCompleta = await _servico.listarAgendamentos(
      clienteId: usuario.perfil == Perfil.cliente ? usuario.id : null,
      escopo: escopo,
      busca: busca,
    );

    final total = listaCompleta.length;
    final totalPaginas = total == 0 ? 1 : (total / tamanho).ceil();

    final paginaSegura = pagina.clamp(1, totalPaginas);
    final inicio = (paginaSegura - 1) * tamanho;
    final fim = (inicio + tamanho).clamp(0, total);

    final itens = inicio >= total
        ? <dynamic>[]
        : listaCompleta.sublist(inicio, fim).map((a) => a.toJson()).toList();

    return Respostas.ok({
      'itens': itens,
      'pagina': paginaSegura,
      'tamanho': tamanho,
      'total': total,
      'totalPaginas': totalPaginas,
    });
  }

  Future<Response> _criarAgendamento(Request request) async {
    final payload = await request.readAsString();
    final json = jsonDecode(payload) as Map<String, dynamic>;

    final dto = DadosDoAgendamentoDto.deJson(json);

    final agendamento = await _servico.criarAgendamento(
      quadraId: dto.quadraId,
      clienteId: request.usuarioAutenticado.id,
      dataInicio: dto.dataInicio,
      dataFim: dto.dataFim,
    );

    return Respostas.criado({
      'mensagem': 'Agendamento criado com sucesso',
      'id': agendamento.id,
      'agendamento': agendamento.toJson(),
    });
  }

  Future<Response> _atualizarAgendamento(Request request) async {
    final id = int.tryParse(request.params['id'] ?? '');
    if (id == null) {
      throw const ErroValidacao('id inválido.', codigo: 'ID_INVALIDO');
    }

    final payload = await request.readAsString();
    final json = jsonDecode(payload) as Map<String, dynamic>;

    final dto = DadosDoAgendamentoDto.deJson(json);

    final agendamento = await _servico.atualizarAgendamento(
      agendamentoId: id,
      clienteId: request.usuarioAutenticado.id,
      quadraId: dto.quadraId,
      dataInicio: dto.dataInicio,
      dataFim: dto.dataFim,
      valorTotal: dto.valorTotal,
    );

    return Respostas.ok({
      'mensagem': 'Agendamento atualizado com sucesso',
      'agendamento': agendamento.toJson(),
    });
  }

  Future<Response> _cancelarAgendamento(Request request) async {
    final id = int.tryParse(request.params['id'] ?? '');
    if (id == null) {
      throw const ErroValidacao('id inválido.', codigo: 'ID_INVALIDO');
    }

    final usuario = request.usuarioAutenticado;

    await _servico.cancelarAgendamento(
      agendamentoId: id,
      usuarioId: usuario.id,
      isCliente: usuario.perfil == Perfil.cliente,
    );

    return Respostas.semConteudo();
  }

  Future<Response> _buscarHorariosLivres(
    Request request,
    String quadraIdStr,
  ) async {
    final quadraId = int.tryParse(quadraIdStr);
    if (quadraId == null) {
      throw const ErroValidacao(
        'quadraId inválido.',
        codigo: 'QUADRA_ID_INVALIDO',
      );
    }

    final dataQuery = request.url.queryParameters['data'];
    if (dataQuery == null) {
      throw const ErroValidacao(
        'O parâmetro ?data=YYYY-MM-DD é obrigatório.',
        codigo: 'DATA_OBRIGATORIA',
      );
    }

    final dataAlvo = DateTime.tryParse(dataQuery);
    if (dataAlvo == null) {
      throw const ErroValidacao(
        'O parâmetro data deve estar no formato YYYY-MM-DD.',
        codigo: 'DATA_INVALIDA',
      );
    }

    final ignorarId = int.tryParse(
      request.url.queryParameters['ignorarAgendamentoId'] ?? '',
    );

    final horariosLivres = await _servico.buscarHorariosLivres(
      quadraId,
      dataAlvo,
      ignorarAgendamentoId: ignorarId,
    );

    final horariosStrings = horariosLivres
        .map((h) => h.toIso8601String())
        .toList();

    return Respostas.ok({'data': dataQuery, 'horariosLivres': horariosStrings});
  }

  Future<Response> _obterRelatorios(Request request) async {
    final params = request.url.queryParameters;

    final inicioStr = params['inicio'];
    final fimStr = params['fim'];

    final inicio = inicioStr != null ? DateTime.tryParse(inicioStr) : null;
    if (inicioStr != null && inicio == null) {
      throw const ErroValidacao(
        'O parâmetro inicio deve estar no formato YYYY-MM-DD.',
        codigo: 'DATA_INVALIDA',
      );
    }

    final fimParsed = fimStr != null ? DateTime.tryParse(fimStr) : null;
    if (fimStr != null && fimParsed == null) {
      throw const ErroValidacao(
        'O parâmetro fim deve estar no formato YYYY-MM-DD.',
        codigo: 'DATA_INVALIDA',
      );
    }

    final fim = fimParsed?.add(
      const Duration(hours: 23, minutes: 59, seconds: 59),
    );

    final metricas = await _servico.gerarRelatorios(inicio: inicio, fim: fim);

    return Respostas.ok(metricas);
  }
}
