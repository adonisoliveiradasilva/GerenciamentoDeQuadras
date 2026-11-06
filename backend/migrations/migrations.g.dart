// GENERATED CODE - DO NOT MODIFY BY HAND.
import 'package:orm/migrate.dart';

import 'm0001_create_tasks.dart' as m0;
import 'm0002_criar_usuarios.dart' as m1;
import 'm0003_criar_quadras.dart' as m2;
import 'm0004_criar_agendamentos.dart' as m3;
import 'm0005_criar_tokens_senha.dart' as m4;

const migrationDialect = SqlDialect.postgres;
final migrationHistory = MigrationHistory([
  (m0.migration, m0.migrationChecksum),
  (m1.migration, m1.migrationChecksum),
  (m2.migration, m2.migrationChecksum),
  (m3.migration, m3.migrationChecksum),
  (m4.migration, m4.migrationChecksum),
], dialect: migrationDialect);
