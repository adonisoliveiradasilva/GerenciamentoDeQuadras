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
import 'modules/agendamentos/data/agendamento_repositorio_orm.dart';
import 'modules/agendamentos/domain/servico_de_agendamentos.dart';
import 'modules/agendamentos/presentation/agendamentos_rotas.dart';

Future<void> main() async {
  final ambiente = Ambiente.atual;
  final banco = criarBancoDeDados(ambiente: ambiente);
  final servicoDeToken = ServicoDeToken.doAmbiente(ambiente);
  const hashDeSenha = HashDeSenhaBcrypt();
  
  // Repositórios instanciados
  final usuarios = UsuarioRepositorioOrm(banco);
  final quadras = QuadraRepositorioOrm(banco);
  final agendamentos = AgendamentoRepositorioORM(banco);

  // Serviços instanciados
  final servicoDeAgendamentos = ServicoDeAgendamentos(agendamentos, quadras);

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
          servico: ServicoDeQuadras(quadras),
          servicoDeToken: servicoDeToken,
        ),
      ),
      (
        prefixo: '/clientes',
        rotas: criarRotasDeGestaoDeUsuarios(
          gestao: GestaoDeUsuarios(
            usuarios,
            perfil: Perfil.cliente,
            hashDeSenha: hashDeSenha,
          ),
          servicoDeToken: servicoDeToken,
        ),
      ),
      (
        prefixo: '/funcionarios',
        rotas: criarRotasDeGestaoDeUsuarios(
          gestao: GestaoDeUsuarios(
            usuarios,
            perfil: Perfil.funcionario,
            hashDeSenha: hashDeSenha,
          ),
          servicoDeToken: servicoDeToken,
          comSenha: true,
        ),
      ),
      (
        prefixo: '/agendamentos',
        rotas: AgendamentosRotas(servicoDeAgendamentos, servicoDeToken).router.call,
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