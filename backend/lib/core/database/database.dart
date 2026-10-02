import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:orm/postgres.dart';

export 'package:orm/postgres.dart';
export '../../schema.orm.dart';

class DatabaseConfig {
  static String? _cachedUrl;

  static void loadEnv() {
    if (_cachedUrl != null && _cachedUrl!.isNotEmpty) return;

    if (Platform.environment['DATABASE_URL'] case final envUrl? when envUrl.isNotEmpty) {
      _cachedUrl = envUrl;
      return;
    }

    final envFileCurrent = File('.env');
    final envFileParent = File('../.env');

    if (envFileCurrent.existsSync()) {
      final env = DotEnv()..load(['.env']);
      _cachedUrl = env['DATABASE_URL'];
    } else if (envFileParent.existsSync()) {
      final env = DotEnv()..load(['../.env']);
      _cachedUrl = env['DATABASE_URL'];
    }
  }

  static Uri getDatabaseUrl() {
    loadEnv();
    final value = _cachedUrl ?? Platform.environment['DATABASE_URL'];
    if (value == null || value.isEmpty) {
      throw const FormatException(
        'DATABASE_URL não configurada no ambiente ou no arquivo .env.',
      );
    }
    return Uri.parse(value);
  }
}

Database<Postgres> createDatabase({
  int maxConnections = 5,
  PostgresTls tls = PostgresTls.disable,
}) {
  final url = DatabaseConfig.getDatabaseUrl();
  return postgres(
    PostgresOptions(
      url: url,
      maxConnections: maxConnections,
      tls: tls,
    ),
  );
}
