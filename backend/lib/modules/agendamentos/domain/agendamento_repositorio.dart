import 'agendamento.dart';

abstract class AgendamentoRepositorio {
  Future<Agendamento> criar(Agendamento agendamento);

  Future<Agendamento?> buscarPorId(int id);

  Future<List<Agendamento>> listarTodos({int? clienteId});

  Future<Agendamento> atualizar(Agendamento agendamento);

  Future<void> cancelar(int id);

  Future<List<Agendamento>> buscarPorQuadraEData(
    int quadraId,
    DateTime inicio,
    DateTime fim,
  );

  Future<bool> existeConflitoDeHorario(
    int quadraId,
    DateTime inicio,
    DateTime fim, {
    int? ignorarAgendamentoId,
  });
}
