import 'dart:io';

import 'package:backend/core/auth/hash_de_senha.dart';
import 'package:backend/core/database/database.dart';
import 'package:backend/modules/quadras/data/quadra_repositorio_orm.dart';
import 'package:backend/modules/quadras/domain/erros_quadra.dart';
import 'package:backend/modules/quadras/domain/hora_do_dia.dart';
import 'package:backend/modules/quadras/domain/quadra.dart';
import 'package:backend/modules/quadras/domain/servico_de_quadras.dart';
import 'package:backend/modules/usuarios/data/usuario_repositorio_orm.dart';
import 'package:backend/modules/usuarios/domain/erros_usuario.dart';
import 'package:backend/modules/usuarios/domain/gestao_de_usuarios.dart';
import 'package:backend/modules/usuarios/domain/usuario.dart';

const senhaDeExemplo = 'Senha@123';

const usuariosDeExemplo = [
  (
    perfil: Perfil.gerente,
    nome: 'Gerente Exemplo',
    email: 'gerente@quadras.com',
  ),
  (
    perfil: Perfil.funcionario,
    nome: 'Funcionário Exemplo',
    email: 'funcionario@quadras.com',
  ),
  (
    perfil: Perfil.cliente,
    nome: 'Cliente Exemplo',
    email: 'cliente@quadras.com',
  ),
];

Future<void> main() async {
  final banco = criarBancoDeDados(maxConexoes: 1);
  final usuarios = UsuarioRepositorioOrm(banco);
  const hashDeSenha = HashDeSenhaBcrypt();

  try {
    for (final exemplo in usuariosDeExemplo) {
      final gestao = GestaoDeUsuarios(
        usuarios,
        perfil: exemplo.perfil,
        hashDeSenha: hashDeSenha,
      );
      try {
        await gestao.cadastrar(
          AlteracaoUsuario(nome: exemplo.nome, email: exemplo.email),
          senha: senhaDeExemplo,
        );
        stdout.writeln('Criado: ${exemplo.perfil.name} <${exemplo.email}>');
      } on EmailJaCadastrado {
        stdout.writeln('Já existe: ${exemplo.perfil.name} <${exemplo.email}>');
      }
    }

    try {
      await ServicoDeQuadras(QuadraRepositorioOrm(banco)).criar(
        DadosDaQuadra(
          nome: 'Quadra Exemplo',
          localizacao: 'Bloco A',
          descricao: 'Quadra criada pelo script de dados de exemplo.',
          duracaoSessaoMin: 60,
          horarios: [
            for (
              var dia = IntervaloDeFuncionamento.segunda;
              dia <= IntervaloDeFuncionamento.domingo;
              dia++
            )
              IntervaloDeFuncionamento(
                diaSemana: dia,
                inicio: HoraDoDia(8, 0),
                fim: HoraDoDia(22, 0),
              ),
          ],
        ),
      );
      stdout.writeln('Criada: Quadra Exemplo (todos os dias, 08:00 às 22:00)');
    } on QuadraJaCadastrada {
      stdout.writeln('Já existe: Quadra Exemplo');
    }

    stdout.writeln('Senha dos usuários de exemplo: $senhaDeExemplo');
  } on SocketException {
    stderr.writeln(
      'Não foi possível conectar ao banco de dados. Confira se o Docker '
      'Desktop está aberto e rode "docker compose up -d" na raiz do projeto.',
    );
    exitCode = 1;
  } finally {
    await banco.close();
  }
}
