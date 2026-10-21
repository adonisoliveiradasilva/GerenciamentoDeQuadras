// Generated physical schema. Keep historical copies with their migration.
import 'package:orm/migrate.dart';

final schema = SchemaSnapshot([
  TableSchema(
    "horarios_funcionamento",
    namespace: "public",
    columns: [
      Column("id", Codecs.integer, generated: true),
      Column("quadra_id", Codecs.integer),
      Column("dia_semana", Codecs.integer),
      Column("inicio", Codecs.time),
      Column("fim", Codecs.time),
    ],
    primaryKey: ["id"],

    indexes: [
      IndexSchema("horarios_quadra_dia", [
        "quadra_id",
        "dia_semana",
        "inicio",
      ], unique: false),
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
    checks: [
      CheckSchema("horarios_dia_valido", "dia_semana BETWEEN 1 AND 7"),
      CheckSchema("horarios_inicio_antes_do_fim", "inicio < fim"),
    ],
  ),
  TableSchema(
    "quadras",
    namespace: "public",
    columns: [
      Column("id", Codecs.integer, generated: true),
      Column("nome", Codecs.text),
      Column("localizacao", Codecs.text),
      Column("descricao", Codecs.text.nullable(), nullable: true),
      Column("duracao_sessao_min", Codecs.integer),
      Column("ativo", Codecs.boolean, defaultSql: "true"),
      Column("criado_em", Codecs.dateTime, defaultSql: "CURRENT_TIMESTAMP"),
      Column("atualizado_em", Codecs.dateTime, defaultSql: "CURRENT_TIMESTAMP"),
    ],
    primaryKey: ["id"],

    indexes: [
      IndexSchema("quadras_ativo_nome", ["ativo", "nome"], unique: false),
    ],

    checks: [CheckSchema("quadras_duracao_positiva", "duracao_sessao_min > 0")],
  ),
  TableSchema(
    "usuarios",
    namespace: "public",
    columns: [
      Column("id", Codecs.integer, generated: true),
      Column("nome", Codecs.text),
      Column("email", Codecs.text),
      Column("senha_hash", Codecs.text.nullable(), nullable: true),
      Column("telefone", Codecs.text.nullable(), nullable: true),
      Column("data_nascimento", Codecs.date.nullable(), nullable: true),
      Column("perfil", Codecs.text),
      Column("ativo", Codecs.boolean, defaultSql: "true"),
      Column("criado_em", Codecs.dateTime, defaultSql: "CURRENT_TIMESTAMP"),
      Column("atualizado_em", Codecs.dateTime, defaultSql: "CURRENT_TIMESTAMP"),
    ],
    primaryKey: ["id"],
    uniqueKeys: [
      ["email"],
    ],
    indexes: [
      IndexSchema("usuarios_perfil_nome", ["perfil", "nome"], unique: false),
    ],
  ),
]);
