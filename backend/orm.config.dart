import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:orm/cli.dart';
import 'package:orm/drivers/postgres.dart';

import 'lib/schema.snapshot.dart' as target;
import 'migrations/migrations.g.dart';

Future<void> main(List<String> args) => runOrmCli(
  args,
  config: OrmConfig(
    schema: 'lib/schema.dart',
    migrations: 'migrations',
    history: migrationHistory,
    snapshot: target.schema,
    connect: ({required bool readOnly}) async {
      return SqlDatabase(
        PostgresDriver(
          PostgresOptions(
            url: databaseUrl(),
            maxConnections: 1,
            tls: PostgresTls.disable,
          ),
        ),
      );
    },
  ),
);

Uri databaseUrl() {
  var value = Platform.environment['DATABASE_URL'];
  if (value == null || value.isEmpty) {
    if (File('.env').existsSync()) {
      final env = DotEnv()..load(['.env']);
      value = env['DATABASE_URL'];
    } else if (File('../.env').existsSync()) {
      final env = DotEnv()..load(['../.env']);
      value = env['DATABASE_URL'];
    }
  }

  if (value == null || value.isEmpty) {
    throw const FormatException('DATABASE_URL is empty or missing.');
  }
  try {
    return Uri.parse(value);
  } on FormatException {
    throw const FormatException('DATABASE_URL is not a valid database URL.');
  }
}
