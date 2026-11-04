import '../domain/agendamento.dart';
import '../domain/agendamento_repositorio.dart';
import '../../quadras/domain/quadra_repositorio.dart';

class ServicoDeAgendamentos {
  final AgendamentoRepositorio _agendamentoRepositorio;
  final QuadraRepositorio _quadraRepositorio;

  ServicoDeAgendamentos(
    this._agendamentoRepositorio,
    this._quadraRepositorio,
  );

  Future<Agendamento> criarAgendamento({
    required int quadraId,
    required int clienteId,
    required DateTime dataInicio,
    required DateTime dataFim,
    required double valorTotal,
  }) async {
    if (dataInicio.isAfter(dataFim) || dataInicio.isAtSameMomentAs(dataFim)) {
      throw Exception('A data de término deve ser posterior à data de início.');
    }

    final existeConflito = await _agendamentoRepositorio.existeConflitoDeHorario(
      quadraId,
      dataInicio,
      dataFim,
    );

    if (existeConflito) {
      throw Exception('Já existe um agendamento para esta quadra neste horário.');
    }

    final novoAgendamento = Agendamento(
      id: 0, 
      quadraId: quadraId,
      clienteId: clienteId,
      dataInicio: dataInicio,
      dataFim: dataFim,
      status: 'pendente',
      valorTotal: valorTotal,
      criadoEm: DateTime.now(),
      atualizadoEm: DateTime.now(),
    );

    return await _agendamentoRepositorio.criar(novoAgendamento);
  }

  Future<List<DateTime>> buscarHorariosLivres(int quadraId, DateTime dataAlvo) async {
    final quadra = await _quadraRepositorio.buscarPorId(quadraId);
    if (quadra == null) throw Exception('Quadra não encontrada.');

    final diaSemana = dataAlvo.weekday;
    
    final horarioDoDia = quadra.horarios.where((h) => h.diaSemana == diaSemana).firstOrNull;
    if (horarioDoDia == null) return [];

    final inicioDoDia = DateTime(dataAlvo.year, dataAlvo.month, dataAlvo.day);
    final fimDoDia = DateTime(dataAlvo.year, dataAlvo.month, dataAlvo.day, 23, 59, 59);
    final agendamentosDoDia = await _agendamentoRepositorio.buscarPorQuadraEData(
      quadraId, 
      inicioDoDia, 
      fimDoDia,
    );

    List<DateTime> slotsLivres = [];
    
DateTime slotAtual = DateTime(
      dataAlvo.year, dataAlvo.month, dataAlvo.day, 
      horarioDoDia.inicio.hora, horarioDoDia.inicio.minuto, 
    );
    
    DateTime fechamento = DateTime(
      dataAlvo.year, dataAlvo.month, dataAlvo.day, 
      horarioDoDia.fim.hora, horarioDoDia.fim.minuto, 
    );

    while (slotAtual.isBefore(fechamento)) {
      DateTime fimDoSlot = slotAtual.add(Duration(minutes: quadra.duracaoSessaoMin));
      
      if (fimDoSlot.isAfter(fechamento)) break;

      bool ocupado = agendamentosDoDia.any((agendamento) {
        return slotAtual.isBefore(agendamento.dataFim) && fimDoSlot.isAfter(agendamento.dataInicio);
      });

      if (!ocupado && slotAtual.isAfter(DateTime.now())) {
        slotsLivres.add(slotAtual);
      }

      slotAtual = fimDoSlot;
    }

    return slotsLivres;
  }
}