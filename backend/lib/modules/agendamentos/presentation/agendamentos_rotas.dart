import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../../core/auth/middlewares_de_acesso.dart';
import '../../../core/auth/servico_de_token.dart';
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

  String _limparErro(Object e) => e.toString().replaceFirst('Exception: ', '');

  Future<Response> _listarAgendamentos(Request request) async {
    try {
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

      return Respostas.okJson({
        'itens': itens,
        'pagina': paginaSegura,
        'tamanho': tamanho,
        'total': total,
        'totalPaginas': totalPaginas,
      });
    } catch (e) {
      return Respostas.erroJson(_limparErro(e));
    }
  }

  Future<Response> _criarAgendamento(Request request) async {
    try {
      final payload = await request.readAsString();
      final json = jsonDecode(payload) as Map<String, dynamic>;

      final dto = DadosDoAgendamentoDto.fromJson(json);

      final agendamento = await _servico.criarAgendamento(
        quadraId: dto.quadraId,
        clienteId: request.usuarioAutenticado.id,
        dataInicio: dto.dataInicio,
        dataFim: dto.dataFim,
        valorTotal: dto.valorTotal,
      );

      return Response(
        201,
        body: jsonEncode({
          'mensagem': 'Agendamento criado com sucesso',
          'id': agendamento.id,
          'agendamento': agendamento.toJson(),
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Respostas.erroJson(_limparErro(e));
    }
  }

  Future<Response> _atualizarAgendamento(Request request) async {
    try {
      final id = int.parse(request.params['id']!);

      final payload = await request.readAsString();
      final json = jsonDecode(payload) as Map<String, dynamic>;

      final dto = DadosDoAgendamentoDto.fromJson(json);

      final agendamento = await _servico.atualizarAgendamento(
        agendamentoId: id,
        clienteId: request.usuarioAutenticado.id,
        quadraId: dto.quadraId,
        dataInicio: dto.dataInicio,
        dataFim: dto.dataFim,
        valorTotal: dto.valorTotal,
      );

      return Respostas.okJson({
        'mensagem': 'Agendamento atualizado com sucesso',
        'agendamento': agendamento.toJson(),
      });
    } catch (e) {
      return Respostas.erroJson(_limparErro(e));
    }
  }

  Future<Response> _cancelarAgendamento(Request request) async {
    try {
      final id = int.parse(request.params['id']!);
      final usuario = request.usuarioAutenticado;

      await _servico.cancelarAgendamento(
        agendamentoId: id,
        usuarioId: usuario.id,
        isCliente: usuario.perfil == Perfil.cliente,
      );

      return Response(204);
    } catch (e) {
      return Respostas.erroJson(_limparErro(e));
    }
  }

  Future<Response> _buscarHorariosLivres(
    Request request,
    String quadraIdStr,
  ) async {
    try {
      final quadraId = int.parse(quadraIdStr);

      final dataQuery = request.url.queryParameters['data'];

      final ignorarId = int.tryParse(
        request.url.queryParameters['ignorarAgendamentoId'] ?? '',
      );

      if (dataQuery == null) {
        return Respostas.erroJson(
          'O parâmetro ?data=YYYY-MM-DD é obrigatório.',
        );
      }

      final dataAlvo = DateTime.parse(dataQuery);

      final horariosLivres = await _servico.buscarHorariosLivres(
        quadraId,
        dataAlvo,
        ignorarAgendamentoId: ignorarId,
      );

      final horariosStrings = horariosLivres
          .map((h) => h.toIso8601String())
          .toList();

      return Respostas.okJson({
        'data': dataQuery,
        'horariosLivres': horariosStrings,
      });
    } catch (e) {
      return Respostas.erroJson(_limparErro(e));
    }
  }

  Future<Response> _obterRelatorios(Request request) async {
    try {
      final params = request.url.queryParameters;

      final inicioStr = params['inicio'];
      final fimStr = params['fim'];

      final inicio = inicioStr != null ? DateTime.parse(inicioStr) : null;

      final fim = fimStr != null
          ? DateTime.parse(fimStr)
                .add(const Duration(hours: 23, minutes: 59, seconds: 59))
          : null;

      final metricas = await _servico.gerarRelatorios(inicio: inicio, fim: fim);

      return Respostas.okJson(metricas);
    } catch (e) {
      return Respostas.erroJson(_limparErro(e));
    }
  }
}

class Respostas {
  static Response okJson(Map<String, dynamic> body) => Response.ok(
    jsonEncode(body),
    headers: {'content-type': 'application/json'},
  );

  static Response erroJson(String mensagem) => Response.badRequest(
    body: jsonEncode({'mensagem': mensagem, 'erro': mensagem}),
    headers: {'content-type': 'application/json'},
  );
}
