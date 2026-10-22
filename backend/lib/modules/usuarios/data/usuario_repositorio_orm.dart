import 'package:orm/drivers/postgres.dart' show PostgresFailure;

import '../../../core/database/database.dart' as bd;
import '../../../core/paginacao/paginacao.dart';
import '../../../core/paginacao/paginacao_orm.dart';
import '../domain/erros_usuario.dart';
import '../domain/perfil.dart';
import '../domain/usuario.dart';
import '../domain/usuario_repositorio.dart';

class UsuarioRepositorioOrm implements UsuarioRepositorio {
  UsuarioRepositorioOrm(this._db);

  final bd.Database<bd.Postgres> _db;

  static final _ordenacao = <String, CampoOrdenavel<bd.UsuarioFields>>{
    'nome': (u) => u.nome,
    'email': (u) => u.email,
    'criadoEm': (u) => u.criadoEm,
  };

  bd.Query<bd.Usuario, bd.UsuarioFields> _ativos({int? id, Perfil? perfil}) {
    var consulta = _db.usuario.where((u) => u.ativo.eq(true));
    if (id != null) consulta = consulta.where((u) => u.id.eq(id));
    if (perfil != null) consulta = consulta.where((u) => u.perfil.eq(perfil));
    return consulta;
  }

  @override
  Future<Usuario?> buscarPorId(int id, {Perfil? perfil}) async =>
      (await _ativos(id: id, perfil: perfil).firstOrNull())?._paraDominio();

  @override
  Future<Usuario?> buscarPorEmail(String email) async {
    final linha = await _ativos()
        .where((u) => u.email.eq(email.toLowerCase()))
        .firstOrNull();
    return linha?._paraDominio();
  }

  @override
  Future<Usuario?> buscarRemovidoPorEmail(String email) async {
    final linha = await _db.usuario
        .where((u) => u.ativo.eq(false))
        .where((u) => u.email.eq(email.toLowerCase()))
        .firstOrNull();
    return linha?._paraDominio();
  }

  @override
  Future<Usuario?> reativar(int id, NovoUsuario dados) async {
    final alterados = await _db.usuario
        .where((u) => u.ativo.eq(false))
        .where((u) => u.id.eq(id))
        .patch(
          ativo: .set(true),
          nome: .set(dados.nome),
          email: .set(dados.email.toLowerCase()),
          perfil: .set(dados.perfil),
          senhaHash: .set(dados.senhaHash),
          telefone: .set(dados.telefone),
          dataNascimento: .set(_paraData(dados.dataNascimento)),
          atualizadoEm: .set(DateTime.now().toUtc()),
        );
    return alterados == 0 ? null : buscarPorId(id);
  }

  @override
  Future<Pagina<Usuario>> listar(
    Perfil perfil,
    ParametrosPaginacao parametros,
  ) async {
    final pagina = await _ativos(perfil: perfil)
        .buscar(parametros.busca, [(u) => u.nome, (u) => u.email])
        .paginar(parametros, ordenacao: _ordenacao, desempate: (u) => u.id);
    return pagina.mapear((linha) => linha._paraDominio());
  }

  @override
  Future<Usuario> criar(NovoUsuario dados) => _tratandoEmailDuplicado(() async {
    final linha = await _db.usuario.create(
      nome: dados.nome,
      email: dados.email.toLowerCase(),
      perfil: dados.perfil,
      senhaHash: dados.senhaHash,
      telefone: dados.telefone,
      dataNascimento: _paraData(dados.dataNascimento),
    );
    return linha._paraDominio();
  });

  @override
  Future<Usuario?> atualizar(
    int id,
    AlteracaoUsuario dados, {
    Perfil? perfil,
    String? novaSenhaHash,
  }) => _tratandoEmailDuplicado(() async {
    final alterados = await _ativos(id: id, perfil: perfil).patch(
      nome: .set(dados.nome),
      email: .set(dados.email.toLowerCase()),
      telefone: .set(dados.telefone),
      dataNascimento: .set(_paraData(dados.dataNascimento)),
      senhaHash: novaSenhaHash == null ? const .keep() : .set(novaSenhaHash),
      atualizadoEm: .set(DateTime.now().toUtc()),
    );
    return alterados == 0 ? null : buscarPorId(id);
  });

  @override
  Future<bool> definirSenha(int id, String senhaHash) async {
    final alterados = await _ativos(id: id).patch(
      senhaHash: .set(senhaHash),
      atualizadoEm: .set(DateTime.now().toUtc()),
    );
    return alterados > 0;
  }

  @override
  Future<bool> desativar(int id, {Perfil? perfil}) async {
    final alterados = await _ativos(
      id: id,
      perfil: perfil,
    ).patch(ativo: .set(false), atualizadoEm: .set(DateTime.now().toUtc()));
    return alterados > 0;
  }

  Future<T> _tratandoEmailDuplicado<T>(Future<T> Function() operacao) async {
    try {
      return await operacao();
    } on PostgresFailure catch (falha) {
      if (falha.code == _violacaoDeUnicidade) throw const EmailJaCadastrado();
      rethrow;
    }
  }
}

const _violacaoDeUnicidade = '23505';

bd.LocalDate? _paraData(DateTime? data) =>
    data == null ? null : bd.LocalDate(data.year, data.month, data.day);

extension on bd.Usuario {
  Usuario _paraDominio() => Usuario(
    id: id,
    nome: nome,
    email: email,
    perfil: perfil,
    ativo: ativo,
    criadoEm: criadoEm,
    atualizadoEm: atualizadoEm,
    senhaHash: senhaHash,
    telefone: telefone,
    dataNascimento: switch (dataNascimento) {
      final data? => DateTime.utc(data.year, data.month, data.day),
      null => null,
    },
  );
}
