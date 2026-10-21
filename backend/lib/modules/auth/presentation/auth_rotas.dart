import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../../core/auth/middlewares_de_acesso.dart';
import '../../../core/auth/servico_de_token.dart';
import '../../../core/http/erros.dart';
import '../../../core/http/requisicao.dart';
import '../../../core/http/respostas.dart';
import '../../usuarios/domain/usuario_repositorio.dart';
import '../../usuarios/presentation/usuario_json.dart';
import '../domain/fazer_login.dart';

Handler criarRotasDeAuth({
  required FazerLogin fazerLogin,
  required UsuarioRepositorio usuarios,
  required ServicoDeToken servicoDeToken,
}) {
  final autenticado = const Pipeline().addMiddleware(
    exigirLogin(servicoDeToken),
  );

  return (Router()
        ..post('/login', (Request requisicao) async {
          final campos = LeitorDeCampos(await requisicao.lerJson());
          final email = campos.email('email');
          final senha = campos.texto('senha', maximo: 72);
          campos.validar();

          final resultado = await fazerLogin.executar(
            email: email!,
            senha: senha!,
          );
          return Respostas.ok({
            'token': resultado.token.valor,
            'expiraEm': resultado.token.expiraEm.toIso8601String(),
            'usuario': resultado.usuario.toJson(),
          });
        })
        ..get(
          '/eu',
          autenticado.addHandler((Request requisicao) async {
            final usuario = await usuarios.buscarPorId(
              requisicao.usuarioAutenticado.id,
            );
            if (usuario == null) {
              throw const NaoAutenticado(
                'Usuário não encontrado ou desativado.',
                'USUARIO_INATIVO',
              );
            }
            return Respostas.ok(usuario.toJson());
          }),
        ))
      .call;
}
