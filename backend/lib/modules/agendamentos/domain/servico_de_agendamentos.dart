import '../../../core/http/erros.dart';
import '../../quadras/domain/quadra_repositorio.dart';
import 'agendamento.dart';
import 'agendamento_repositorio.dart';

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
  }) async {
    if (!dataInicio.isBefore(dataFim)) {
      throw const ErroValidacao(
        'A data de término deve ser posterior à data de início.',
        codigo: 'INTERVALO_INVALIDO',
      );
    }

    if (!dataInicio.isAfter(DateTime.now())) {
      throw const ErroValidacao(
        'O agendamento deve ser feito para um horário no futuro.',
        codigo: 'DATA_NO_PASSADO',
      );
    }

    final quadra = await _quadraRepositorio.buscarPorId(quadraId);
    if (quadra == null) {
      throw const NaoEncontrado('Quadra não encontrada.', 'QUADRA_NAO_ENCONTRADA');
    }

    final duracaoMin = dataFim.difference(dataInicio).inMinutes;
    if (duracaoMin <= 0 || duracaoMin % quadra.duracaoSessaoMin != 0) {
      throw ErroValidacao(
        'A duração do agendamento deve ser múltipla de ${quadra.duracaoSessaoMin} minutos.',
        codigo: 'DURACAO_INVALIDA',
      );
    }

    final horariosDoDia = quadra.horarios.where(
      (h) => h.diaSemana == dataInicio.weekday,
    );

    final dentroDoFuncionamento = horariosDoDia.any((h) {
      final abertura = DateTime(
        dataInicio.year, dataInicio.month, dataInicio.day,
        h.inicio.hora, h.inicio.minuto,
      );
      final fechamento = DateTime(
        dataInicio.year, dataInicio.month, dataInicio.day,
        h.fim.hora, h.fim.minuto,
      );
      return !dataInicio.isBefore(abertura) && !dataFim.isAfter(fechamento);
    });

    if (!dentroDoFuncionamento) {
      throw const ErroValidacao(
        'O horário escolhido está fora do funcionamento da quadra.',
        codigo: 'FORA_DO_FUNCIONAMENTO',
      );
    }

    final existeConflito = await _agendamentoRepositorio.existeConflitoDeHorario(
      quadraId,
      dataInicio,
      dataFim,
    );

    if (existeConflito) {
      throw const Conflito(
        'HORARIO_INDISPONIVEL',
        'Já existe um agendamento para esta quadra neste horário.',
      );
    }

    final novoAgendamento = Agendamento(
      id: 0,
      quadraId: quadraId,
      clienteId: clienteId,
      dataInicio: dataInicio,
      dataFim: dataFim,
      status: StatusAgendamento.pendente,
      valorTotal: 0.0, // Calculado no servidor (ajuste se Quadra tiver campo de preço)
      criadoEm: DateTime.now(),
      atualizadoEm: DateTime.now(),
    );

    return _agendamentoRepositorio.criar(novoAgendamento);
  }

  Future<List<DateTime>> buscarHorariosLivres(int quadraId, DateTime dataAlvo) async {
    final quadra = await _quadraRepositorio.buscarPorId(quadraId);
    if (quadra == null) {
      throw const NaoEncontrado('Quadra não encontrada.', 'QUADRA_NAO_ENCONTRADA');
    }

    final horariosDoDia = quadra.horarios
        .where((h) => h.diaSemana == dataAlvo.weekday)
        .toList();
    if (horariosDoDia.isEmpty) return [];

    final inicioDoDia = DateTime(dataAlvo.year, dataAlvo.month, dataAlvo.day);
    final fimDoDia = DateTime(dataAlvo.year, dataAlvo.month, dataAlvo.day, 23, 59, 59);
    final agendamentosDoDia = await _agendamentoRepositorio.buscarPorQuadraEData(
      quadraId,
      inicioDoDia,
      fimDoDia,
    );

    final slotsLivres = <DateTime>[];

    for (final horario in horariosDoDia) {
      var slotAtual = DateTime(
        dataAlvo.year, dataAlvo.month, dataAlvo.day,
        horario.inicio.hora, horario.inicio.minuto,
      );
      final fechamento = DateTime(
        dataAlvo.year, dataAlvo.month, dataAlvo.day,
        horario.fim.hora, horario.fim.minuto,
      );

      while (slotAtual.isBefore(fechamento)) {
        final fimDoSlot = slotAtual.add(Duration(minutes: quadra.duracaoSessaoMin));
        if (fimDoSlot.isAfter(fechamento)) break;

        final ocupado = agendamentosDoDia.any((agendamento) {
          return slotAtual.isBefore(agendamento.dataFim) &&
              fimDoSlot.isAfter(agendamento.dataInicio);
        });

        if (!ocupado && slotAtual.isAfter(DateTime.now())) {
          slotsLivres.add(slotAtual);
        }

        slotAtual = fimDoSlot;
      }
    }

    return slotsLivres;
  }
}