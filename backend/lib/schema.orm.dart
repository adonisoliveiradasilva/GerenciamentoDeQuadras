// GENERATED CODE - DO NOT MODIFY BY HAND.

import 'package:orm/sql.dart';
export "package:backend/modules/usuarios/domain/perfil.dart" show Perfil;
export "package:backend/modules/auth/domain/tipo_de_token_de_senha.dart"
    show TipoDeTokenDeSenha;
import "package:backend/modules/usuarios/domain/perfil.dart" as types0;
import "package:backend/modules/auth/domain/tipo_de_token_de_senha.dart"
    as types1;

/// A complete immutable row from "agendamentos".
final class Agendamento({
  required final int id,
  required final int quadraId,
  required final int clienteId,
  required final DateTime dataInicio,
  required final DateTime dataFim,
  required final String status,
  required final double valorTotal,
  required final DateTime criadoEm,
  required final DateTime atualizadoEm,
});
final _agendamentoId = Column<int>(
  "id",
  Codecs.integer,
  nullable: false,
  generated: true,
);
final _agendamentoQuadraId = Column<int>(
  "quadra_id",
  Codecs.integer,
  nullable: false,
  generated: false,
);
final _agendamentoClienteId = Column<int>(
  "cliente_id",
  Codecs.integer,
  nullable: false,
  generated: false,
);
final _agendamentoDataInicio = Column<DateTime>(
  "data_inicio",
  Codecs.dateTime,
  nullable: false,
  generated: false,
);
final _agendamentoDataFim = Column<DateTime>(
  "data_fim",
  Codecs.dateTime,
  nullable: false,
  generated: false,
);
final _agendamentoStatus = Column<String>(
  "status",
  Codecs.text,
  nullable: false,
  generated: false,
  defaultSql: "'pendente'",
);
final _agendamentoValorTotal = Column<double>(
  "valor_total",
  Codecs.real,
  nullable: false,
  generated: false,
);
final _agendamentoCriadoEm = Column<DateTime>(
  "criado_em",
  Codecs.dateTime,
  nullable: false,
  generated: false,
  defaultSql: "CURRENT_TIMESTAMP",
);
final _agendamentoAtualizadoEm = Column<DateTime>(
  "atualizado_em",
  Codecs.dateTime,
  nullable: false,
  generated: false,
  defaultSql: "CURRENT_TIMESTAMP",
);
final agendamentoSchema = TableSchema(
  "agendamentos",
  namespace: "public",
  columns: [
    _agendamentoId,
    _agendamentoQuadraId,
    _agendamentoClienteId,
    _agendamentoDataInicio,
    _agendamentoDataFim,
    _agendamentoStatus,
    _agendamentoValorTotal,
    _agendamentoCriadoEm,
    _agendamentoAtualizadoEm,
  ],
  primaryKey: ["id"],
  uniqueKeys: [],
  indexes: [
    IndexSchema("agendamentos_quadra_datas", [
      "quadra_id",
      "data_inicio",
      "data_fim",
    ], unique: false),
    IndexSchema("agendamentos_cliente_status", [
      "cliente_id",
      "status",
    ], unique: false),
  ],
  checks: [
    CheckSchema.forDialects(
      "agendamentos_inicio_antes_do_fim",
      sqlite: "data_inicio < data_fim",
      postgres: "data_inicio < data_fim",
      mysql: "data_inicio < data_fim",
      mariadb: "data_inicio < data_fim",
    ),
  ],
  foreignKeys: [
    ForeignKey(
      ["quadra_id"],
      "quadras",
      ["id"],
      onDelete: "RESTRICT",
      targetNamespace: "public",
    ),
    ForeignKey(
      ["cliente_id"],
      "usuarios",
      ["id"],
      onDelete: "RESTRICT",
      targetNamespace: "public",
    ),
  ],
);

final class AgendamentoFields extends Fields {
  AgendamentoFields(super.table);
  late final id = column(_agendamentoId);
  late final quadraId = column(_agendamentoQuadraId);
  late final clienteId = column(_agendamentoClienteId);
  late final dataInicio = column(_agendamentoDataInicio);
  late final dataFim = column(_agendamentoDataFim);
  late final status = column(_agendamentoStatus);
  late final valorTotal = column(_agendamentoValorTotal);
  late final criadoEm = column(_agendamentoCriadoEm);
  late final atualizadoEm = column(_agendamentoAtualizadoEm);
  Relation<Quadra, QuadraFields> get quadra =>
      Relation(quadraTable, parent: [quadraId], child: (row) => [row.id]);
  Relation<Usuario, UsuarioFields> get cliente =>
      Relation(usuarioTable, parent: [clienteId], child: (row) => [row.id]);
}

final agendamentoTable = Table<Agendamento, AgendamentoFields>(
  agendamentoSchema,
  AgendamentoFields.new,
  (row) =>
      (
        (row.id, row.quadraId, row.clienteId, row.dataInicio, row.dataFim).map(
          (id, quadraId, clienteId, dataInicio, dataFim) => (
            id: id,
            quadraId: quadraId,
            clienteId: clienteId,
            dataInicio: dataInicio,
            dataFim: dataFim,
          ),
        ),
        (row.status, row.valorTotal, row.criadoEm, row.atualizadoEm).map(
          (status, valorTotal, criadoEm, atualizadoEm) => (
            status: status,
            valorTotal: valorTotal,
            criadoEm: criadoEm,
            atualizadoEm: atualizadoEm,
          ),
        ),
      ).map(
        (left, right) => Agendamento(
          id: left.id,
          quadraId: left.quadraId,
          clienteId: left.clienteId,
          dataInicio: left.dataInicio,
          dataFim: left.dataFim,
          status: right.status,
          valorTotal: right.valorTotal,
          criadoEm: right.criadoEm,
          atualizadoEm: right.atualizadoEm,
        ),
      ),
);

final class AgendamentoTableSet
    extends TableSet<Agendamento, AgendamentoFields> {
  AgendamentoTableSet(QueryContext db) : super(db, agendamentoTable) {
    db.registerSchema(appSchema);
  }
  Future<Agendamento> create({
    Change<int> id = const Change.keep(),
    required int quadraId,
    required int clienteId,
    required DateTime dataInicio,
    required DateTime dataFim,
    Change<String> status = const Change.keep(),
    required double valorTotal,
    Change<DateTime> criadoEm = const Change.keep(),
    Change<DateTime> atualizadoEm = const Change.keep(),
  }) => createRow(
    (row) => [
      ...row.id.change(id),
      row.quadraId.set(quadraId),
      row.clienteId.set(clienteId),
      row.dataInicio.set(dataInicio),
      row.dataFim.set(dataFim),
      ...row.status.change(status),
      row.valorTotal.set(valorTotal),
      ...row.criadoEm.change(criadoEm),
      ...row.atualizadoEm.change(atualizadoEm),
    ],
  );
  Query<Agendamento, AgendamentoFields> byId(int id) =>
      where((row) => row.id.eq(id));
}

extension AgendamentoUpdates on Query<Agendamento, AgendamentoFields> {
  Future<int> patch({
    Change<int> quadraId = const Change.keep(),
    Change<int> clienteId = const Change.keep(),
    Change<DateTime> dataInicio = const Change.keep(),
    Change<DateTime> dataFim = const Change.keep(),
    Change<String> status = const Change.keep(),
    Change<double> valorTotal = const Change.keep(),
    Change<DateTime> criadoEm = const Change.keep(),
    Change<DateTime> atualizadoEm = const Change.keep(),
  }) => update(
    (row) => [
      ...row.quadraId.change(quadraId),
      ...row.clienteId.change(clienteId),
      ...row.dataInicio.change(dataInicio),
      ...row.dataFim.change(dataFim),
      ...row.status.change(status),
      ...row.valorTotal.change(valorTotal),
      ...row.criadoEm.change(criadoEm),
      ...row.atualizadoEm.change(atualizadoEm),
    ],
  ).execute();
}

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
  Relation<Agendamento, AgendamentoFields> get agendamentos =>
      Relation(agendamentoTable, parent: [id], child: (row) => [row.quadraId]);
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

/// A complete immutable row from "tokens_senha".
final class TokenDeSenha({
  required final int id,
  required final int usuarioId,
  required final String tokenHash,
  required final types1.TipoDeTokenDeSenha tipo,
  required final DateTime expiraEm,
  required final DateTime? usadoEm,
  required final DateTime criadoEm,
});
final _tokenDeSenhaId = Column<int>(
  "id",
  Codecs.integer,
  nullable: false,
  generated: true,
);
final _tokenDeSenhaUsuarioId = Column<int>(
  "usuario_id",
  Codecs.integer,
  nullable: false,
  generated: false,
);
final _tokenDeSenhaTokenHash = Column<String>(
  "token_hash",
  Codecs.text,
  nullable: false,
  generated: false,
);
final _tokenDeSenhaTipo = Column<types1.TipoDeTokenDeSenha>(
  "tipo",
  Codecs.enumeration<types1.TipoDeTokenDeSenha>({
    types1.TipoDeTokenDeSenha.criar: "criar",
    types1.TipoDeTokenDeSenha.redefinir: "redefinir",
  }),
  nullable: false,
  generated: false,
);
final _tokenDeSenhaExpiraEm = Column<DateTime>(
  "expira_em",
  Codecs.dateTime,
  nullable: false,
  generated: false,
);
final _tokenDeSenhaUsadoEm = Column<DateTime?>(
  "usado_em",
  Codecs.dateTime.nullable(),
  nullable: true,
  generated: false,
);
final _tokenDeSenhaCriadoEm = Column<DateTime>(
  "criado_em",
  Codecs.dateTime,
  nullable: false,
  generated: false,
  defaultSql: "CURRENT_TIMESTAMP",
);
final tokenDeSenhaSchema = TableSchema(
  "tokens_senha",
  namespace: "public",
  columns: [
    _tokenDeSenhaId,
    _tokenDeSenhaUsuarioId,
    _tokenDeSenhaTokenHash,
    _tokenDeSenhaTipo,
    _tokenDeSenhaExpiraEm,
    _tokenDeSenhaUsadoEm,
    _tokenDeSenhaCriadoEm,
  ],
  primaryKey: ["id"],
  uniqueKeys: [
    ["token_hash"],
  ],
  indexes: [
    IndexSchema("tokens_senha_usuario_tipo", [
      "usuario_id",
      "tipo",
    ], unique: false),
  ],
  foreignKeys: [
    ForeignKey(
      ["usuario_id"],
      "usuarios",
      ["id"],
      onDelete: "CASCADE",
      targetNamespace: "public",
    ),
  ],
);

final class TokenDeSenhaFields extends Fields {
  TokenDeSenhaFields(super.table);
  late final id = column(_tokenDeSenhaId);
  late final usuarioId = column(_tokenDeSenhaUsuarioId);
  late final tokenHash = column(_tokenDeSenhaTokenHash);
  late final tipo = column(_tokenDeSenhaTipo);
  late final expiraEm = column(_tokenDeSenhaExpiraEm);
  late final usadoEm = column(_tokenDeSenhaUsadoEm);
  late final criadoEm = column(_tokenDeSenhaCriadoEm);
  Relation<Usuario, UsuarioFields> get usuario =>
      Relation(usuarioTable, parent: [usuarioId], child: (row) => [row.id]);
}

final tokenDeSenhaTable = Table<TokenDeSenha, TokenDeSenhaFields>(
  tokenDeSenhaSchema,
  TokenDeSenhaFields.new,
  (row) =>
      (
        (row.id, row.usuarioId, row.tokenHash, row.tipo, row.expiraEm).map(
          (id, usuarioId, tokenHash, tipo, expiraEm) => (
            id: id,
            usuarioId: usuarioId,
            tokenHash: tokenHash,
            tipo: tipo,
            expiraEm: expiraEm,
          ),
        ),
        (
          row.usadoEm,
          row.criadoEm,
        ).map((usadoEm, criadoEm) => (usadoEm: usadoEm, criadoEm: criadoEm)),
      ).map(
        (left, right) => TokenDeSenha(
          id: left.id,
          usuarioId: left.usuarioId,
          tokenHash: left.tokenHash,
          tipo: left.tipo,
          expiraEm: left.expiraEm,
          usadoEm: right.usadoEm,
          criadoEm: right.criadoEm,
        ),
      ),
);

final class TokenDeSenhaTableSet
    extends TableSet<TokenDeSenha, TokenDeSenhaFields> {
  TokenDeSenhaTableSet(QueryContext db) : super(db, tokenDeSenhaTable) {
    db.registerSchema(appSchema);
  }
  Future<TokenDeSenha> create({
    Change<int> id = const Change.keep(),
    required int usuarioId,
    required String tokenHash,
    required types1.TipoDeTokenDeSenha tipo,
    required DateTime expiraEm,
    DateTime? usadoEm,
    Change<DateTime> criadoEm = const Change.keep(),
  }) => createRow(
    (row) => [
      ...row.id.change(id),
      row.usuarioId.set(usuarioId),
      row.tokenHash.set(tokenHash),
      row.tipo.set(tipo),
      row.expiraEm.set(expiraEm),
      row.usadoEm.set(usadoEm),
      ...row.criadoEm.change(criadoEm),
    ],
  );
  Query<TokenDeSenha, TokenDeSenhaFields> byId(int id) =>
      where((row) => row.id.eq(id));
}

extension TokenDeSenhaUpdates on Query<TokenDeSenha, TokenDeSenhaFields> {
  Future<int> patch({
    Change<int> usuarioId = const Change.keep(),
    Change<String> tokenHash = const Change.keep(),
    Change<types1.TipoDeTokenDeSenha> tipo = const Change.keep(),
    Change<DateTime> expiraEm = const Change.keep(),
    Change<DateTime?> usadoEm = const Change.keep(),
    Change<DateTime> criadoEm = const Change.keep(),
  }) => update(
    (row) => [
      ...row.usuarioId.change(usuarioId),
      ...row.tokenHash.change(tokenHash),
      ...row.tipo.change(tipo),
      ...row.expiraEm.change(expiraEm),
      ...row.usadoEm.change(usadoEm),
      ...row.criadoEm.change(criadoEm),
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
  Relation<Agendamento, AgendamentoFields> get agendamentos =>
      Relation(agendamentoTable, parent: [id], child: (row) => [row.clienteId]);
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
  agendamentoSchema,
  horarioFuncionamentoSchema,
  quadraSchema,
  tokenDeSenhaSchema,
  usuarioSchema,
]);

extension AppTables on QueryContext {
  AgendamentoTableSet get agendamento => AgendamentoTableSet(this);
  HorarioFuncionamentoTableSet get horarioFuncionamento =>
      HorarioFuncionamentoTableSet(this);
  QuadraTableSet get quadra => QuadraTableSet(this);
  TokenDeSenhaTableSet get tokenDeSenha => TokenDeSenhaTableSet(this);
  UsuarioTableSet get usuario => UsuarioTableSet(this);
}
