import 'dart:io';

import 'package:shelf/shelf_io.dart' as shelf_io;

import 'app.dart';
import 'core/auth/hash_de_senha.dart';
import 'core/auth/servico_de_token.dart';
import 'core/config/ambiente.dart';
import 'core/database/database.dart';
import 'modules/auth/domain/fazer_login.dart';
import 'modules/auth/presentation/auth_rotas.dart';
import 'modules/quadras/data/quadra_repositorio_orm.dart';
import 'modules/quadras/domain/servico_de_quadras.dart';
import 'modules/quadras/presentation/quadras_rotas.dart';
import 'modules/usuarios/data/usuario_repositorio_orm.dart';
import 'modules/usuarios/domain/gestao_de_usuarios.dart';
import 'modules/usuarios/presentation/gestao_de_usuarios_rotas.dart';

Future<void> main() async {
  final ambiente = Ambiente.atual;
  final banco = criarBancoDeDados(ambiente: ambiente);
  final servicoDeToken = ServicoDeToken.doAmbiente(ambiente);
  const hashDeSenha = HashDeSenhaBcrypt();
  final usuarios = UsuarioRepositorioOrm(banco);

  final app = criarApp(
    modulos: [
      (
        prefixo: '/auth',
        rotas: criarRotasDeAuth(
          fazerLogin: FazerLogin(
            usuarios: usuarios,
            hashDeSenha: hashDeSenha,
            servicoDeToken: servicoDeToken,
          ),
          usuarios: usuarios,
          servicoDeToken: servicoDeToken,
        ),
      ),
      (
        prefixo: '/quadras',
        rotas: criarRotasDeQuadras(
          servico: ServicoDeQuadras(QuadraRepositorioOrm(banco)),
          servicoDeToken: servicoDeToken,
        ),
      ),
      (
        prefixo: '/clientes',
        rotas: criarRotasDeGestaoDeUsuarios(
          gestao: GestaoDeUsuarios(usuarios, perfil: Perfil.cliente),
          servicoDeToken: servicoDeToken,
        ),
      ),
    ],
  );

  final servidor = await shelf_io.serve(
    app,
    InternetAddress.anyIPv4,
    ambiente.porta,
  );
  print('Servidor iniciado na porta ${servidor.port}');
}
