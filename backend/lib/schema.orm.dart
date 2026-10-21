// GENERATED CODE - DO NOT MODIFY BY HAND.

import 'package:orm/sql.dart';
export "package:backend/modules/usuarios/domain/perfil.dart" show Perfil;
import "package:backend/modules/usuarios/domain/perfil.dart" as types0;

/// A complete immutable row from "usuarios".
final class Usuario({
  required final int id,
  required final String nome,
  required final String email,
  required final String? senhaHash,
  required final String? telefone,
  required final LocalDate? dataNascimento,
  required final types0.Perfil perfil,
  required final bool ativo,
  required final DateTime criadoEm,
  required final DateTime atualizadoEm,
});
final _usuarioId = Column<int>(
  "id",
  Codecs.integer,
  nullable: false,
  generated: true,
);
final _usuarioNome = Column<String>(
  "nome",
  Codecs.text,
  nullable: false,
  generated: false,
);
final _usuarioEmail = Column<String>(
  "email",
  Codecs.text,
  nullable: false,
  generated: false,
);
final _usuarioSenhaHash = Column<String?>(
  "senha_hash",
  Codecs.text.nullable(),
  nullable: true,
  generated: false,
);
final _usuarioTelefone = Column<String?>(
  "telefone",
  Codecs.text.nullable(),
  nullable: true,
  generated: false,
);
final _usuarioDataNascimento = Column<LocalDate?>(
  "data_nascimento",
  Codecs.date.nullable(),
  nullable: true,
  generated: false,
);
final _usuarioPerfil = Column<types0.Perfil>(
  "perfil",
  Codecs.enumeration<types0.Perfil>({
    types0.Perfil.gerente: "gerente",
    types0.Perfil.funcionario: "funcionario",
    types0.Perfil.cliente: "cliente",
  }),
  nullable: false,
  generated: false,
);
final _usuarioAtivo = Column<bool>(
  "ativo",
  Codecs.boolean,
  nullable: false,
  generated: false,
  defaultSql: "true",
);
final _usuarioCriadoEm = Column<DateTime>(
  "criado_em",
  Codecs.dateTime,
  nullable: false,
  generated: false,
  defaultSql: "CURRENT_TIMESTAMP",
);
final _usuarioAtualizadoEm = Column<DateTime>(
  "atualizado_em",
  Codecs.dateTime,
  nullable: false,
  generated: false,
  defaultSql: "CURRENT_TIMESTAMP",
);
final usuarioSchema = TableSchema(
  "usuarios",
  namespace: "public",
  columns: [
    _usuarioId,
    _usuarioNome,
    _usuarioEmail,
    _usuarioSenhaHash,
    _usuarioTelefone,
    _usuarioDataNascimento,
    _usuarioPerfil,
    _usuarioAtivo,
    _usuarioCriadoEm,
    _usuarioAtualizadoEm,
  ],
  primaryKey: ["id"],
  uniqueKeys: [
    ["email"],
  ],
  indexes: [
    IndexSchema("usuarios_perfil_nome", ["perfil", "nome"], unique: false),
  ],
  foreignKeys: [],
);

final class UsuarioFields extends Fields {
  UsuarioFields(super.table);
  late final id = column(_usuarioId);
  late final nome = column(_usuarioNome);
  late final email = column(_usuarioEmail);
  late final senhaHash = column(_usuarioSenhaHash);
  late final telefone = column(_usuarioTelefone);
  late final dataNascimento = column(_usuarioDataNascimento);
  late final perfil = column(_usuarioPerfil);
  late final ativo = column(_usuarioAtivo);
  late final criadoEm = column(_usuarioCriadoEm);
  late final atualizadoEm = column(_usuarioAtualizadoEm);
}

final usuarioTable = Table<Usuario, UsuarioFields>(
  usuarioSchema,
  UsuarioFields.new,
  (row) =>
      (
        (row.id, row.nome, row.email, row.senhaHash, row.telefone).map(
          (id, nome, email, senhaHash, telefone) => (
            id: id,
            nome: nome,
            email: email,
            senhaHash: senhaHash,
            telefone: telefone,
          ),
        ),
        (
          row.dataNascimento,
          row.perfil,
          row.ativo,
          row.criadoEm,
          row.atualizadoEm,
        ).map(
          (dataNascimento, perfil, ativo, criadoEm, atualizadoEm) => (
            dataNascimento: dataNascimento,
            perfil: perfil,
            ativo: ativo,
            criadoEm: criadoEm,
            atualizadoEm: atualizadoEm,
          ),
        ),
      ).map(
        (left, right) => Usuario(
          id: left.id,
          nome: left.nome,
          email: left.email,
          senhaHash: left.senhaHash,
          telefone: left.telefone,
          dataNascimento: right.dataNascimento,
          perfil: right.perfil,
          ativo: right.ativo,
          criadoEm: right.criadoEm,
          atualizadoEm: right.atualizadoEm,
        ),
      ),
);

final class UsuarioTableSet extends TableSet<Usuario, UsuarioFields> {
  UsuarioTableSet(QueryContext db) : super(db, usuarioTable) {
    db.registerSchema(appSchema);
  }
  Future<Usuario> create({
    Change<int> id = const Change.keep(),
    required String nome,
    required String email,
    String? senhaHash,
    String? telefone,
    LocalDate? dataNascimento,
    required types0.Perfil perfil,
    Change<bool> ativo = const Change.keep(),
    Change<DateTime> criadoEm = const Change.keep(),
    Change<DateTime> atualizadoEm = const Change.keep(),
  }) => createRow(
    (row) => [
      ...row.id.change(id),
      row.nome.set(nome),
      row.email.set(email),
      row.senhaHash.set(senhaHash),
      row.telefone.set(telefone),
      row.dataNascimento.set(dataNascimento),
      row.perfil.set(perfil),
      ...row.ativo.change(ativo),
      ...row.criadoEm.change(criadoEm),
      ...row.atualizadoEm.change(atualizadoEm),
    ],
  );
  Query<Usuario, UsuarioFields> byId(int id) => where((row) => row.id.eq(id));
}

extension UsuarioUpdates on Query<Usuario, UsuarioFields> {
  Future<int> patch({
    Change<String> nome = const Change.keep(),
    Change<String> email = const Change.keep(),
    Change<String?> senhaHash = const Change.keep(),
    Change<String?> telefone = const Change.keep(),
    Change<LocalDate?> dataNascimento = const Change.keep(),
    Change<types0.Perfil> perfil = const Change.keep(),
    Change<bool> ativo = const Change.keep(),
    Change<DateTime> criadoEm = const Change.keep(),
    Change<DateTime> atualizadoEm = const Change.keep(),
  }) => update(
    (row) => [
      ...row.nome.change(nome),
      ...row.email.change(email),
      ...row.senhaHash.change(senhaHash),
      ...row.telefone.change(telefone),
      ...row.dataNascimento.change(dataNascimento),
      ...row.perfil.change(perfil),
      ...row.ativo.change(ativo),
      ...row.criadoEm.change(criadoEm),
      ...row.atualizadoEm.change(atualizadoEm),
    ],
  ).execute();
}

final appSchema = List<TableSchema>.unmodifiable([usuarioSchema]);

extension AppTables on QueryContext {
  UsuarioTableSet get usuario => UsuarioTableSet(this);
}
