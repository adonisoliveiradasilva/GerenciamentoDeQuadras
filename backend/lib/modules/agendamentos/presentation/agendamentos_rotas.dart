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
    final payload = await request.readAsString();
    final json = jsonDecode(payload) as Map<String, dynamic>;
    final dto = DadosDoAgendamentoDto.deJson(json);

    final agendamento = await _servico.criarAgendamento(
      quadraId: dto.quadraId,
      clienteId: request.usuarioAutenticado.id,
      dataInicio: dto.dataInicio,
      dataFim: dto.dataFim,
    );

    return Respostas.ok({
      'mensagem': 'Agendamento criado com sucesso',
      'id': agendamento.id,
    });
  }

  Future<Response> _buscarHorariosLivres(Request request, String quadraIdStr) async {
    final quadraId = int.tryParse(quadraIdStr);
    if (quadraId == null) {
      throw const ErroValidacao('quadraId inválido.', codigo: 'QUADRA_ID_INVALIDO');
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

    final horariosLivres = await _servico.buscarHorariosLivres(quadraId, dataAlvo);
    final horariosStrings = horariosLivres.map((h) => h.toIso8601String()).toList();

    return Respostas.ok({
      'data': dataQuery,
      'horariosLivres': horariosStrings,
    });
  }
}