import 'package:orm/orm.dart';

import '../../../schema.orm.dart' as orm;
import '../domain/agendamento.dart';
import '../domain/agendamento_repositorio.dart';

class AgendamentoRepositorioORM implements AgendamentoRepositorio {
  final QueryContext db;

  AgendamentoRepositorioORM(this.db);

  @override
  Future<Agendamento> criar(Agendamento agendamento) async {
    final ormModel = await db.agendamento.create(
      quadraId: agendamento.quadraId,
      clienteId: agendamento.clienteId,
      dataInicio: agendamento.dataInicio,
      dataFim: agendamento.dataFim,
      status: Change.set(agendamento.status.name),
      valorTotal: agendamento.valorTotal,
    );

    final enriquecidos = await _enriquecer([ormModel]);
    return enriquecidos.first;
  }

  @override
  Future<Agendamento?> buscarPorId(int id) async {
    final ormModel = await db.agendamento
        .where((row) => row.id.eq(id))
        .firstOrNull();
    if (ormModel == null) return null;

    final enriquecidos = await _enriquecer([ormModel]);
    return enriquecidos.first;
  }

  @override
  Future<List<Agendamento>> listarTodos({int? clienteId}) async {
    var query = db.agendamento.where((row) => row.status.ne('cancelado'));

    if (clienteId != null) {
      query = query.where((row) => row.clienteId.eq(clienteId));
    }

    final resultados = await query
        .orderBy((row) => [row.dataInicio.asc()])
        .get();

    return _enriquecer(resultados);
  }

  @override
  Future<Agendamento> atualizar(Agendamento agendamento) async {
    await db.agendamento
        .where((row) => row.id.eq(agendamento.id))
        .patch(
          quadraId: Change.set(agendamento.quadraId),
          dataInicio: Change.set(agendamento.dataInicio),
          dataFim: Change.set(agendamento.dataFim),
          valorTotal: Change.set(agendamento.valorTotal),
          atualizadoEm: Change.set(DateTime.now().toUtc()),
        );

    final atualizado = await buscarPorId(agendamento.id);
    return atualizado!;
  }

  @override
  Future<void> cancelar(int id) async {
    await db.agendamento
        .where((row) => row.id.eq(id))
        .patch(
          status: Change.set('cancelado'),
          atualizadoEm: Change.set(DateTime.now().toUtc()),
        );
  }

  @override
  Future<List<Agendamento>> buscarPorQuadraEData(
    int quadraId,
    DateTime inicio,
    DateTime fim,
  ) async {
    final resultados = await db.agendamento
        .where((row) => row.quadraId.eq(quadraId))
        .where((row) => row.dataInicio.gte(inicio))
        .where((row) => row.dataInicio.lte(fim))
        .get();

    final ativos = resultados.where((r) => r.status != 'cancelado').toList();
    return _enriquecer(ativos);
  }

  @override
  Future<bool> existeConflitoDeHorario(
    int quadraId,
    DateTime inicio,
    DateTime fim, {
    int? ignorarAgendamentoId,
  }) async {
    var query = db.agendamento
        .where((row) => row.quadraId.eq(quadraId))
        .where((row) => row.dataInicio.lt(fim))
        .where((row) => row.dataFim.gt(inicio));

    if (ignorarAgendamentoId != null) {
      query = query.where((row) => row.id.ne(ignorarAgendamentoId));
    }

    final resultados = await query.get();
    final conflitosAtivos = resultados.where((r) => r.status != 'cancelado');
    return conflitosAtivos.isNotEmpty;
  }

  Future<List<Agendamento>> _enriquecer(List<orm.Agendamento> lista) async {
    if (lista.isEmpty) return [];

    final quadraIds = lista.map((e) => e.quadraId).toSet().toList();
    final clienteIds = lista.map((e) => e.clienteId).toSet().toList();

    final quadras = await db.quadra.where((q) => q.id.isIn(quadraIds)).get();
    final clientes = await db.usuario.where((u) => u.id.isIn(clienteIds)).get();

    final mapaQuadras = {for (final q in quadras) q.id: q.nome};
    final mapaClientes = {for (final c in clientes) c.id: c.nome};

    return lista
        .map(
          (ormModel) => Agendamento(
            id: ormModel.id,
            quadraId: ormModel.quadraId,
            clienteId: ormModel.clienteId,
            quadraNome: mapaQuadras[ormModel.quadraId],
            clienteNome: mapaClientes[ormModel.clienteId],
            dataInicio: ormModel.dataInicio,
            dataFim: ormModel.dataFim,
            status: StatusAgendamento.values.byName(ormModel.status),
            valorTotal: (ormModel.valorTotal as num).toDouble(),
            criadoEm: ormModel.criadoEm,
            atualizadoEm: ormModel.atualizadoEm,
          ),
        )
        .toList();
  }
}
