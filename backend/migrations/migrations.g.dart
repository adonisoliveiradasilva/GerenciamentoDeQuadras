// GENERATED CODE - DO NOT MODIFY BY HAND.
import 'package:orm/migrate.dart';

import 'm0001_create_tasks.dart' as m0;
import 'm0002_criar_usuarios.dart' as m1;

const migrationDialect = SqlDialect.postgres;
final migrationHistory = MigrationHistory([
  (m0.migration, m0.migrationChecksum),
  (m1.migration, m1.migrationChecksum),
], dialect: migrationDialect);
