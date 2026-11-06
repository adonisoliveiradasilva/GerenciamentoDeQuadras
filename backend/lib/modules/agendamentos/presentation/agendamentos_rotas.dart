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
    final router = Router();

    router.post('/', soCliente.addHandler(_criarAgendamento));

    router.get(
      '/livres/<quadraId>',
      logado.addHandler(
        (Request request) =>
            _buscarHorariosLivres(request, request.params['quadraId']!),
      ),
    );

    return router;
  }

  Future<Response> _criarAgendamento(Request request) async {
    try {
      final payload = await request.readAsString();
      final json = jsonDecode(payload);
      final dto = DadosDoAgendamentoDto.fromJson(json);

      final agendamento = await _servico.criarAgendamento(
        quadraId: dto.quadraId,
        clienteId: request.usuarioAutenticado.id,
        dataInicio: dto.dataInicio,
        dataFim: dto.dataFim,
        valorTotal: dto.valorTotal,
      );

      return Response.ok(
        jsonEncode({'mensagem': 'Agendamento criado com sucesso', 'id': agendamento.id}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.badRequest(
        body: jsonEncode({'erro': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Future<Response> _buscarHorariosLivres(Request request, String quadraIdStr) async {
    try {
      final quadraId = int.parse(quadraIdStr);
      final dataQuery = request.url.queryParameters['data'];
      
      if (dataQuery == null) {
        return Response.badRequest(
          body: jsonEncode({'erro': 'O parâmetro ?data=YYYY-MM-DD é obrigatório.'}),
          headers: {'content-type': 'application/json'},
        );
      }

      final dataAlvo = DateTime.parse(dataQuery);
      final horariosLivres = await _servico.buscarHorariosLivres(quadraId, dataAlvo);

      final horariosStrings = horariosLivres.map((h) => h.toIso8601String()).toList();

      return Response.ok(
        jsonEncode({'data': dataQuery, 'horariosLivres': horariosStrings}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.badRequest(
        body: jsonEncode({'erro': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  }
}