// Generated physical schema. Keep historical copies with their migration.
import 'package:orm/migrate.dart';

final schema = SchemaSnapshot([
  TableSchema(
    "tasks",
    namespace: "public",
    columns: [
      Column("id", Codecs.integer, generated: true),
      Column("title", Codecs.text),
      Column("done", Codecs.boolean, defaultSql: "false"),
    ],
    primaryKey: ["id"],
  ),
]);
