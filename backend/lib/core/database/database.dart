import 'package:orm/postgres.dart';

import '../config/ambiente.dart';

export 'package:orm/postgres.dart';

export '../../schema.orm.dart';

Database<Postgres> criarBancoDeDados({
  Ambiente? ambiente,
  int maxConexoes = 5,
  PostgresTls tls = PostgresTls.disable,
}) {
  return postgres(
    PostgresOptions(
      url: (ambiente ?? Ambiente.atual).urlBanco,
      maxConnections: maxConexoes,
      tls: tls,
    ),
  );
}
