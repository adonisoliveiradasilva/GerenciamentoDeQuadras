import 'package:orm/schema.dart';

import 'modules/usuarios/domain/perfil.dart';

export 'modules/usuarios/domain/perfil.dart';

final usuario = model('usuarios', (
  id: identity(),
  nome: text(),
  email: text(unique: true),
  senhaHash: text().nullable(),
  telefone: text().nullable(),
  dataNascimento: date().nullable(),
  perfil: enumeration(Perfil.values),
  ativo: boolean(defaultValue: true),
  criadoEm: dateTime(defaultSql: 'CURRENT_TIMESTAMP'),
  atualizadoEm: dateTime(defaultSql: 'CURRENT_TIMESTAMP'),
), indexes: (u) => [index((u.perfil, u.nome), name: 'usuarios_perfil_nome')]);
