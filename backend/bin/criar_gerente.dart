import 'dart:io';

import 'package:backend/core/auth/hash_de_senha.dart';
import 'package:backend/core/database/database.dart';
import 'package:backend/core/http/erros.dart';
import 'package:backend/core/http/requisicao.dart';
import 'package:backend/modules/usuarios/data/usuario_repositorio_orm.dart';
import 'package:backend/modules/usuarios/domain/usuario.dart';

const _uso =
    'Uso: dart run bin/criar_gerente.dart --nome="Nome" --email=email@dominio.com --senha=senha';

Future<void> main(List<String> argumentos) async {
  final valores = <String, Object?>{
    for (final argumento in argumentos)
      if (RegExp(r'^--(\w+)=(.*)$').firstMatch(argumento) case final m?)
        m.group(1)!: m.group(2),
  };

  final campos = LeitorDeCampos(valores);
  final nome = campos.texto('nome', maximo: 120);
  final email = campos.email('email');
  final senha = campos.texto('senha', minimo: 8, maximo: 72);

  try {
    campos.validar();
  } on ErroValidacao catch (erro) {
    stderr
      ..writeln('Dados inválidos:')
      ..writeAll(erro.campos!.entries.map((e) => '  ${e.key}: ${e.value}\n'))
      ..writeln(_uso);
    exitCode = 64;
    return;
  }

  final banco = criarBancoDeDados(maxConexoes: 1);
  try {
    final gerente = await UsuarioRepositorioOrm(banco).criar(
      NovoUsuario(
        nome: nome!,
        email: email!,
        perfil: Perfil.gerente,
        senhaHash: await const HashDeSenhaBcrypt().gerar(senha!),
      ),
    );
    stdout.writeln(
      'Gerente criado: ${gerente.nome} <${gerente.email}> (id ${gerente.id})',
    );
  } on ErroApi catch (erro) {
    stderr.writeln(erro.mensagem);
    exitCode = 1;
  } finally {
    await banco.close();
  }
}
