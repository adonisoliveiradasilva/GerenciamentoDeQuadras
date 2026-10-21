import 'package:orm/cli.dart';
import 'package:orm/drivers/postgres.dart';

import 'lib/core/config/ambiente.dart';
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
            url: Ambiente.atual.urlBanco,
            maxConnections: 1,
            tls: PostgresTls.disable,
          ),
        ),
      );
    },
  ),
);
