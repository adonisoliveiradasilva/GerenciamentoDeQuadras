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

final Model quadra = model(
  'quadras',
  (
    id: identity(),
    nome: text(),
    localizacao: text(),
    descricao: text().nullable(),
    duracaoSessaoMin: integer(),
    ativo: boolean(defaultValue: true),
    criadoEm: dateTime(defaultSql: 'CURRENT_TIMESTAMP'),
    atualizadoEm: dateTime(defaultSql: 'CURRENT_TIMESTAMP'),
  ),
  indexes: (q) => [index((q.ativo, q.nome), name: 'quadras_ativo_nome')],
  relations: (q) => (horarios: referencedBy(() => horarioFuncionamento)),
  checks: [check('duracao_sessao_min > 0', name: 'quadras_duracao_positiva')],
);

final Model horarioFuncionamento = model(
  'horarios_funcionamento',
  (
    id: identity(),
    quadraId: integer(),
    diaSemana: integer(),
    inicio: time(),
    fim: time(),
  ),
  indexes: (h) => [
    index((h.quadraId, h.diaSemana, h.inicio), name: 'horarios_quadra_dia'),
  ],
  relations: (h) =>
      (quadra: references(h.quadraId, () => quadra, onDelete: .cascade)),
  checks: [
    check('dia_semana BETWEEN 1 AND 7', name: 'horarios_dia_valido'),
    check('inicio < fim', name: 'horarios_inicio_antes_do_fim'),
  ],
);
