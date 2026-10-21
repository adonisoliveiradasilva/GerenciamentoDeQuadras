// Generated physical schema. Keep historical copies with their migration.
import 'package:orm/migrate.dart';

final schema = SchemaSnapshot([
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
