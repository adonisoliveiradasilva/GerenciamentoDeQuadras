import '../domain/agendamento.dart';
import '../domain/agendamento_repositorio.dart';

import 'package:orm/orm.dart'; 
import '../../../schema.orm.dart' as orm; 

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
      status: Change.set(agendamento.status),
      valorTotal: agendamento.valorTotal,
    );

    return _mapearParaDominio(ormModel);
  }

  @override
  Future<List<Agendamento>> buscarPorQuadraEData(int quadraId, DateTime inicio, DateTime fim) async {
    final resultados = await db.agendamento
        .where((row) => row.quadraId.eq(quadraId))
        .where((row) => row.dataInicio.gte(inicio))
        .where((row) => row.dataInicio.lte(fim))
        .get(); 

    return resultados
        .where((r) => r.status != 'cancelado')
        .map(_mapearParaDominio)
        .toList();
  }

  @override
  Future<bool> existeConflitoDeHorario(int quadraId, DateTime inicio, DateTime fim) async {
    final resultados = await db.agendamento
        .where((row) => row.quadraId.eq(quadraId))
        .where((row) => row.dataInicio.lt(fim))
        .where((row) => row.dataFim.gt(inicio))
        .get(); 

    final conflitosAtivos = resultados.where((r) => r.status != 'cancelado');
    return conflitosAtivos.isNotEmpty;
  }

  Agendamento _mapearParaDominio(orm.Agendamento ormModel) {
    return Agendamento(
      id: ormModel.id,
      quadraId: ormModel.quadraId,
      clienteId: ormModel.clienteId,
      dataInicio: ormModel.dataInicio,
      dataFim: ormModel.dataFim,
      status: ormModel.status,
      valorTotal: (ormModel.valorTotal as num).toDouble(),
      criadoEm: ormModel.criadoEm,
      atualizadoEm: ormModel.atualizadoEm,
    );
  }
}