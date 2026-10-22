import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../../core/auth/middlewares_de_acesso.dart';
import '../../../core/auth/servico_de_token.dart';
import '../../../core/http/requisicao.dart';
import '../../../core/http/respostas.dart';
import '../../../core/paginacao/paginacao_http.dart';
import '../domain/gestao_de_usuarios.dart';
import '../domain/perfil.dart';
import '../domain/usuario_repositorio.dart';
import 'dados_do_usuario_dto.dart';
import 'usuario_json.dart';

Handler criarRotasDeGestaoDeUsuarios({
  required GestaoDeUsuarios gestao,
  required ServicoDeToken servicoDeToken,
}) {
  final soGerente = const Pipeline()
      .addMiddleware(exigirLogin(servicoDeToken))
      .addMiddleware(exigirPerfis({Perfil.gerente}));

  return (Router()
        ..get(
          '/',
          soGerente.addHandler((Request requisicao) async {
            final parametros = requisicao.lerPaginacao(
              camposOrdenaveis: camposOrdenaveisDeUsuario,
              ordenarPadrao: 'nome',
            );
            final pagina = await gestao.listar(parametros);
            return Respostas.ok(pagina.toJson((usuario) => usuario.toJson()));
          }),
        )
        ..get(
          '/<id>',
          soGerente.addHandler((Request requisicao) async {
            final usuario = await gestao.buscar(requisicao.idDaRota());
            return Respostas.ok(usuario.toJson());
          }),
        )
        ..post(
          '/',
          soGerente.addHandler((Request requisicao) async {
            final dados = lerDadosDoUsuario(
              LeitorDeCampos(await requisicao.lerJson()),
            );
            final usuario = await gestao.cadastrar(dados);
            return Respostas.criado(usuario.toJson());
          }),
        )
        ..put(
          '/<id>',
          soGerente.addHandler((Request requisicao) async {
            final id = requisicao.idDaRota();
            final dados = lerDadosDoUsuario(
              LeitorDeCampos(await requisicao.lerJson()),
            );
            final usuario = await gestao.atualizar(id, dados);
            return Respostas.ok(usuario.toJson());
          }),
        )
        ..delete(
          '/<id>',
          soGerente.addHandler((Request requisicao) async {
            await gestao.remover(requisicao.idDaRota());
            return Respostas.semConteudo();
          }),
        ))
      .call;
}
