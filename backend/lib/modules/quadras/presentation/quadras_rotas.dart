import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../../core/auth/middlewares_de_acesso.dart';
import '../../../core/auth/servico_de_token.dart';
import '../../../core/http/requisicao.dart';
import '../../../core/http/respostas.dart';
import '../../../core/paginacao/paginacao_http.dart';
import '../../usuarios/domain/perfil.dart';
import '../domain/quadra_repositorio.dart';
import '../domain/servico_de_quadras.dart';
import 'dados_da_quadra_dto.dart';
import 'quadra_json.dart';

Handler criarRotasDeQuadras({
  required ServicoDeQuadras servico,
  required ServicoDeToken servicoDeToken,
}) {
  final logado = const Pipeline().addMiddleware(exigirLogin(servicoDeToken));
  final soGerente = logado.addMiddleware(exigirPerfis({Perfil.gerente}));

  return (Router()
        ..get(
          '/',
          logado.addHandler((Request requisicao) async {
            final parametros = requisicao.lerPaginacao(
              camposOrdenaveis: camposOrdenaveisDeQuadra,
              ordenarPadrao: 'nome',
            );
            final pagina = await servico.listar(parametros);
            return Respostas.ok(pagina.toJson((quadra) => quadra.toJson()));
          }),
        )
        ..get(
          '/<id>',
          logado.addHandler((Request requisicao) async {
            final quadra = await servico.buscar(requisicao.idDaRota());
            return Respostas.ok(quadra.toJson());
          }),
        )
        ..post(
          '/',
          soGerente.addHandler((Request requisicao) async {
            final dados = lerDadosDaQuadra(await requisicao.lerJson());
            final quadra = await servico.criar(dados);
            return Respostas.criado(quadra.toJson());
          }),
        )
        ..put(
          '/<id>',
          soGerente.addHandler((Request requisicao) async {
            final id = requisicao.idDaRota();
            final dados = lerDadosDaQuadra(await requisicao.lerJson());
            final quadra = await servico.atualizar(id, dados);
            return Respostas.ok(quadra.toJson());
          }),
        )
        ..delete(
          '/<id>',
          soGerente.addHandler((Request requisicao) async {
            await servico.remover(requisicao.idDaRota());
            return Respostas.semConteudo();
          }),
        ))
      .call;
}
