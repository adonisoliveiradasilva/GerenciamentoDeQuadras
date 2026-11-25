import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../../core/auth/middlewares_de_acesso.dart';
import '../../../core/auth/servico_de_token.dart';
import '../../../core/http/erros.dart';
import '../../../core/http/respostas.dart';
import '../../usuarios/domain/perfil.dart';
import '../domain/servico_de_relatorios.dart';

class RelatoriosRotas {
  final ServicoDeRelatorios _servico;
  final ServicoDeToken _servicoDeToken;

  RelatoriosRotas(this._servico, this._servicoDeToken);

  Router get router {
    final logado = const Pipeline().addMiddleware(exigirLogin(_servicoDeToken));
    final soGerente = logado.addMiddleware(exigirPerfis({Perfil.gerente}));
    final router = Router();

    router.get('/', soGerente.addHandler(_gerarRelatorio));

    return router;
  }

  Future<Response> _gerarRelatorio(Request request) async {
    final params = request.url.queryParameters;

    DateTime? inicio;
    if (params['inicio'] != null) {
      inicio = DateTime.tryParse(params['inicio']!);
      if (inicio == null) {
        throw const ErroValidacao(
          'Parâmetro inicio deve estar no formato AAAA-MM-DD.',
          codigo: 'DATA_INVALIDA',
        );
      }
    }

    DateTime? fim;
    if (params['fim'] != null) {
      final parsed = DateTime.tryParse(params['fim']!);
      if (parsed == null) {
        throw const ErroValidacao(
          'Parâmetro fim deve estar no formato AAAA-MM-DD.',
          codigo: 'DATA_INVALIDA',
        );
      }
      fim = DateTime(parsed.year, parsed.month, parsed.day, 23, 59, 59);
    }

    int? quadraId;
    if (params['quadraId'] != null) {
      quadraId = int.tryParse(params['quadraId']!);
      if (quadraId == null || quadraId < 1) {
        throw const ErroValidacao(
          'Parâmetro quadraId inválido.',
          codigo: 'QUADRA_ID_INVALIDO',
        );
      }
    }

    final relatorio = await _servico.gerarRelatorio(
      inicio: inicio,
      fim: fim,
      quadraId: quadraId,
    );

    return Respostas.ok(relatorio.paraJson());
  }
}