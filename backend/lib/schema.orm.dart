// GENERATED CODE - DO NOT MODIFY BY HAND.

import 'package:orm/sql.dart';
export "package:backend/modules/usuarios/domain/perfil.dart" show Perfil;
import "package:backend/modules/usuarios/domain/perfil.dart" as types0;

/// A complete immutable row from "horarios_funcionamento".
final class HorarioFuncionamento({
  required final int id,
  required final int quadraId,
  required final int diaSemana,
  required final LocalTime inicio,
  required final LocalTime fim,
});
final _horarioFuncionamentoId = Column<int>(
  "id",
  Codecs.integer,
  nullable: false,
  generated: true,
);
final _horarioFuncionamentoQuadraId = Column<int>(
  "quadra_id",
  Codecs.integer,
  nullable: false,
  generated: false,
);
final _horarioFuncionamentoDiaSemana = Column<int>(
  "dia_semana",
  Codecs.integer,
  nullable: false,
  generated: false,
);
final _horarioFuncionamentoInicio = Column<LocalTime>(
  "inicio",
  Codecs.time,
  nullable: false,
  generated: false,
);
final _horarioFuncionamentoFim = Column<LocalTime>(
  "fim",
  Codecs.time,
  nullable: false,
  generated: false,
);
final horarioFuncionamentoSchema = TableSchema(
  "horarios_funcionamento",
  namespace: "public",
  columns: [
    _horarioFuncionamentoId,
    _horarioFuncionamentoQuadraId,
    _horarioFuncionamentoDiaSemana,
    _horarioFuncionamentoInicio,
    _horarioFuncionamentoFim,
  ],
  primaryKey: ["id"],
  uniqueKeys: [],
  indexes: [
    IndexSchema("horarios_quadra_dia", [
      "quadra_id",
      "dia_semana",
      "inicio",
    ], unique: false),
  ],
  checks: [
    CheckSchema.forDialects(
      "horarios_dia_valido",
      sqlite: "dia_semana BETWEEN 1 AND 7",
      postgres: "dia_semana BETWEEN 1 AND 7",
      mysql: "dia_semana BETWEEN 1 AND 7",
      mariadb: "dia_semana BETWEEN 1 AND 7",
    ),
    CheckSchema.forDialects(
      "horarios_inicio_antes_do_fim",
      sqlite: "inicio < fim",
      postgres: "inicio < fim",
      mysql: "inicio < fim",
      mariadb: "inicio < fim",
    ),
  ],
  foreignKeys: [
    ForeignKey(
      ["quadra_id"],
      "quadras",
      ["id"],
      onDelete: "CASCADE",
      targetNamespace: "public",
    ),
  ],
);

final class HorarioFuncionamentoFields extends Fields {
  HorarioFuncionamentoFields(super.table);
  late final id = column(_horarioFuncionamentoId);
  late final quadraId = column(_horarioFuncionamentoQuadraId);
  late final diaSemana = column(_horarioFuncionamentoDiaSemana);
  late final inicio = column(_horarioFuncionamentoInicio);
  late final fim = column(_horarioFuncionamentoFim);
  Relation<Quadra, QuadraFields> get quadra =>
      Relation(quadraTable, parent: [quadraId], child: (row) => [row.id]);
}

final horarioFuncionamentoTable =
    Table<HorarioFuncionamento, HorarioFuncionamentoFields>(
      horarioFuncionamentoSchema,
      HorarioFuncionamentoFields.new,
      (row) => (row.id, row.quadraId, row.diaSemana, row.inicio, row.fim).map(
        (v0, v1, v2, v3, v4) => HorarioFuncionamento(
          id: v0,
          quadraId: v1,
          diaSemana: v2,
          inicio: v3,
          fim: v4,
        ),
      ),
    );

final class HorarioFuncionamentoTableSet
    extends TableSet<HorarioFuncionamento, HorarioFuncionamentoFields> {
  HorarioFuncionamentoTableSet(QueryContext db)
    : super(db, horarioFuncionamentoTable) {
    db.registerSchema(appSchema);
  }
  Future<HorarioFuncionamento> create({
    Change<int> id = const Change.keep(),
    required int quadraId,
    required int diaSemana,
    required LocalTime inicio,
    required LocalTime fim,
  }) => createRow(
    (row) => [
      ...row.id.change(id),
      row.quadraId.set(quadraId),
      row.diaSemana.set(diaSemana),
      row.inicio.set(inicio),
      row.fim.set(fim),
    ],
  );
  Query<HorarioFuncionamento, HorarioFuncionamentoFields> byId(int id) =>
      where((row) => row.id.eq(id));
}

extension HorarioFuncionamentoUpdates
    on Query<HorarioFuncionamento, HorarioFuncionamentoFields> {
  Future<int> patch({
    Change<int> quadraId = const Change.keep(),
    Change<int> diaSemana = const Change.keep(),
    Change<LocalTime> inicio = const Change.keep(),
    Change<LocalTime> fim = const Change.keep(),
  }) => update(
    (row) => [
      ...row.quadraId.change(quadraId),
      ...row.diaSemana.change(diaSemana),
      ...row.inicio.change(inicio),
      ...row.fim.change(fim),
    ],
  ).execute();
}

/// A complete immutable row from "quadras".
final class Quadra({
  required final int id,
  required final String nome,
  required final String localizacao,
  required final String? descricao,
  required final int duracaoSessaoMin,
  required final bool ativo,
  required final DateTime criadoEm,
  required final DateTime atualizadoEm,
});
final _quadraId = Column<int>(
  "id",
  Codecs.integer,
  nullable: false,
  generated: true,
);
final _quadraNome = Column<String>(
  "nome",
  Codecs.text,
  nullable: false,
  generated: false,
);
final _quadraLocalizacao = Column<String>(
  "localizacao",
  Codecs.text,
  nullable: false,
  generated: false,
);
final _quadraDescricao = Column<String?>(
  "descricao",
  Codecs.text.nullable(),
  nullable: true,
  generated: false,
);
final _quadraDuracaoSessaoMin = Column<int>(
  "duracao_sessao_min",
  Codecs.integer,
  nullable: false,
  generated: false,
);
final _quadraAtivo = Column<bool>(
  "ativo",
  Codecs.boolean,
  nullable: false,
  generated: false,
  defaultSql: "true",
);
final _quadraCriadoEm = Column<DateTime>(
  "criado_em",
  Codecs.dateTime,
  nullable: false,
  generated: false,
  defaultSql: "CURRENT_TIMESTAMP",
);
final _quadraAtualizadoEm = Column<DateTime>(
  "atualizado_em",
  Codecs.dateTime,
  nullable: false,
  generated: false,
  defaultSql: "CURRENT_TIMESTAMP",
);
final quadraSchema = TableSchema(
  "quadras",
  namespace: "public",
  columns: [
    _quadraId,
    _quadraNome,
    _quadraLocalizacao,
    _quadraDescricao,
    _quadraDuracaoSessaoMin,
    _quadraAtivo,
    _quadraCriadoEm,
    _quadraAtualizadoEm,
  ],
  primaryKey: ["id"],
  uniqueKeys: [],
  indexes: [
    IndexSchema("quadras_ativo_nome", ["ativo", "nome"], unique: false),
  ],
  checks: [
    CheckSchema.forDialects(
      "quadras_duracao_positiva",
      sqlite: "duracao_sessao_min > 0",
      postgres: "duracao_sessao_min > 0",
      mysql: "duracao_sessao_min > 0",
      mariadb: "duracao_sessao_min > 0",
    ),
  ],
  foreignKeys: [],
);

final class QuadraFields extends Fields {
  QuadraFields(super.table);
  late final id = column(_quadraId);
  late final nome = column(_quadraNome);
  late final localizacao = column(_quadraLocalizacao);
  late final descricao = column(_quadraDescricao);
  late final duracaoSessaoMin = column(_quadraDuracaoSessaoMin);
  late final ativo = column(_quadraAtivo);
  late final criadoEm = column(_quadraCriadoEm);
  late final atualizadoEm = column(_quadraAtualizadoEm);
  Relation<HorarioFuncionamento, HorarioFuncionamentoFields> get horarios =>
      Relation(
        horarioFuncionamentoTable,
        parent: [id],
        child: (row) => [row.quadraId],
      );
}

final quadraTable = Table<Quadra, QuadraFields>(
  quadraSchema,
  QuadraFields.new,
  (row) =>
      (
        (
          row.id,
          row.nome,
          row.localizacao,
          row.descricao,
          row.duracaoSessaoMin,
        ).map(
          (id, nome, localizacao, descricao, duracaoSessaoMin) => (
            id: id,
            nome: nome,
            localizacao: localizacao,
            descricao: descricao,
            duracaoSessaoMin: duracaoSessaoMin,
          ),
        ),
        (row.ativo, row.criadoEm, row.atualizadoEm).map(
          (ativo, criadoEm, atualizadoEm) =>
              (ativo: ativo, criadoEm: criadoEm, atualizadoEm: atualizadoEm),
        ),
      ).map(
        (left, right) => Quadra(
          id: left.id,
          nome: left.nome,
          localizacao: left.localizacao,
          descricao: left.descricao,
          duracaoSessaoMin: left.duracaoSessaoMin,
          ativo: right.ativo,
          criadoEm: right.criadoEm,
          atualizadoEm: right.atualizadoEm,
        ),
      ),
);

final class QuadraTableSet extends TableSet<Quadra, QuadraFields> {
  QuadraTableSet(QueryContext db) : super(db, quadraTable) {
    db.registerSchema(appSchema);
  }
  Future<Quadra> create({
    Change<int> id = const Change.keep(),
    required String nome,
    required String localizacao,
    String? descricao,
    required int duracaoSessaoMin,
    Change<bool> ativo = const Change.keep(),
    Change<DateTime> criadoEm = const Change.keep(),
    Change<DateTime> atualizadoEm = const Change.keep(),
  }) => createRow(
    (row) => [
      ...row.id.change(id),
      row.nome.set(nome),
      row.localizacao.set(localizacao),
      row.descricao.set(descricao),
      row.duracaoSessaoMin.set(duracaoSessaoMin),
      ...row.ativo.change(ativo),
      ...row.criadoEm.change(criadoEm),
      ...row.atualizadoEm.change(atualizadoEm),
    ],
  );
  Query<Quadra, QuadraFields> byId(int id) => where((row) => row.id.eq(id));
}

extension QuadraUpdates on Query<Quadra, QuadraFields> {
  Future<int> patch({
    Change<String> nome = const Change.keep(),
    Change<String> localizacao = const Change.keep(),
    Change<String?> descricao = const Change.keep(),
    Change<int> duracaoSessaoMin = const Change.keep(),
    Change<bool> ativo = const Change.keep(),
    Change<DateTime> criadoEm = const Change.keep(),
    Change<DateTime> atualizadoEm = const Change.keep(),
  }) => update(
    (row) => [
      ...row.nome.change(nome),
      ...row.localizacao.change(localizacao),
      ...row.descricao.change(descricao),
      ...row.duracaoSessaoMin.change(duracaoSessaoMin),
      ...row.ativo.change(ativo),
      ...row.criadoEm.change(criadoEm),
      ...row.atualizadoEm.change(atualizadoEm),
    ],
  ).execute();
}

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

final appSchema = List<TableSchema>.unmodifiable([
  horarioFuncionamentoSchema,
  quadraSchema,
  usuarioSchema,
]);

extension AppTables on QueryContext {
  HorarioFuncionamentoTableSet get horarioFuncionamento =>
      HorarioFuncionamentoTableSet(this);
  QuadraTableSet get quadra => QuadraTableSet(this);
  UsuarioTableSet get usuario => UsuarioTableSet(this);
}
