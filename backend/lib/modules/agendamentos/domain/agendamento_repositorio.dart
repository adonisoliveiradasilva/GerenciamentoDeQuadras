import 'agendamento.dart';

abstract class AgendamentoRepositorio {
  Future<Agendamento> criar(Agendamento agendamento);
  
  Future<List<Agendamento>> buscarPorQuadraEData(int quadraId, DateTime inicio, DateTime fim);
  
  Future<bool> existeConflitoDeHorario(int quadraId, DateTime inicio, DateTime fim);
}