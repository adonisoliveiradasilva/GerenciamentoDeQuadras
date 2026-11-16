import '../domain/agendamento.dart';
import '../domain/agendamento_repositorio.dart';
import '../../quadras/domain/quadra_repositorio.dart';

class ServicoDeAgendamentos {
  final AgendamentoRepositorio _agendamentoRepositorio;
  final QuadraRepositorio _quadraRepositorio;

  ServicoDeAgendamentos(this._agendamentoRepositorio, this._quadraRepositorio);

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

    final quadra = await _quadraRepositorio.buscarPorId(quadraId);
    if (quadra == null) {
      throw Exception('Quadra não encontrada.');
    }

    final existeConflito = await _agendamentoRepositorio
        .existeConflitoDeHorario(quadraId, dataInicio, dataFim);

    if (existeConflito) {
      throw Exception(
        'Já existe um agendamento para esta quadra neste horário.',
      );
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

  Future<Agendamento> atualizarAgendamento({
    required int agendamentoId,
    required int clienteId,
    required int quadraId,
    required DateTime dataInicio,
    required DateTime dataFim,
    required double valorTotal,
  }) async {
    final existente = await _agendamentoRepositorio.buscarPorId(agendamentoId);

    if (existente == null || existente.status == 'cancelado') {
      throw Exception('Agendamento não encontrado.');
    }

    if (existente.clienteId != clienteId) {
      throw Exception('Você não tem permissão para alterar este agendamento.');
    }

    if (dataInicio.isAfter(dataFim) || dataInicio.isAtSameMomentAs(dataFim)) {
      throw Exception('A data de término deve ser posterior à data de início.');
    }

    final existeConflito = await _agendamentoRepositorio
        .existeConflitoDeHorario(
          quadraId,
          dataInicio,
          dataFim,
          ignorarAgendamentoId: agendamentoId,
        );

    if (existeConflito) {
      throw Exception(
        'Já existe um agendamento para esta quadra neste horário.',
      );
    }

    final atualizado = Agendamento(
      id: existente.id,
      quadraId: quadraId,
      clienteId: existente.clienteId,
      dataInicio: dataInicio,
      dataFim: dataFim,
      status: existente.status,
      valorTotal: valorTotal,
      criadoEm: existente.criadoEm,
      atualizadoEm: DateTime.now(),
    );

    return await _agendamentoRepositorio.atualizar(atualizado);
  }

  Future<void> cancelarAgendamento({
    required int agendamentoId,
    required int usuarioId,
    required bool isCliente,
  }) async {
    final existente = await _agendamentoRepositorio.buscarPorId(agendamentoId);

    if (existente == null || existente.status == 'cancelado') {
      throw Exception('Agendamento não encontrado.');
    }

    if (isCliente && existente.clienteId != usuarioId) {
      throw Exception('Você não tem permissão para cancelar este agendamento.');
    }

    await _agendamentoRepositorio.cancelar(agendamentoId);
  }

  Future<List<Agendamento>> listarAgendamentos({
    int? clienteId,
    String? escopo,
    String? busca,
  }) async {
    final todos = await _agendamentoRepositorio.listarTodos(
      clienteId: clienteId,
    );

    final agora = DateTime.now();
    final inicioHoje = DateTime(agora.year, agora.month, agora.day);
    final fimHoje = DateTime(agora.year, agora.month, agora.day, 23, 59, 59);

    var filtrados = todos.where((a) {
      final local = a.dataInicio.toLocal();

      switch (escopo) {
        case 'historico':
          return local.isBefore(inicioHoje);
        case 'futuros':
          return !local.isBefore(inicioHoje);
        case 'hoje':
          return !local.isBefore(inicioHoje) && !local.isAfter(fimHoje);
        default:
          return true;
      }
    }).toList();

    if (escopo == 'historico') {
      filtrados.sort((a, b) => b.dataInicio.compareTo(a.dataInicio));
    }

    if (busca != null && busca.trim().isNotEmpty) {
      final termo = busca.trim().toLowerCase();

      filtrados = filtrados.where((a) {
        final local = a.dataInicio.toLocal();

        final dataBr =
            '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';

        final quadra = (a.quadraNome ?? '').toLowerCase();
        final cliente = (a.clienteNome ?? '').toLowerCase();

        return quadra.contains(termo) ||
            cliente.contains(termo) ||
            dataBr.contains(termo);
      }).toList();
    }

    return filtrados;
  }

  Future<List<DateTime>> buscarHorariosLivres(
    int quadraId,
    DateTime dataAlvo, {
    int? ignorarAgendamentoId,
  }) async {
    final quadra = await _quadraRepositorio.buscarPorId(quadraId);

    if (quadra == null) {
      throw Exception('Quadra não encontrada.');
    }

    final diaSemana = dataAlvo.weekday;

    final horariosDoDia = quadra.horarios
        .where((h) => h.diaSemana == diaSemana)
        .toList();

    if (horariosDoDia.isEmpty) return [];

    final inicioDoDia = DateTime(dataAlvo.year, dataAlvo.month, dataAlvo.day);

    final fimDoDia = DateTime(
      dataAlvo.year,
      dataAlvo.month,
      dataAlvo.day,
      23,
      59,
      59,
    );

    final agendamentosDoDia =
        (await _agendamentoRepositorio.buscarPorQuadraEData(
          quadraId,
          inicioDoDia,
          fimDoDia,
        )).where((a) => a.id != ignorarAgendamentoId).toList();

    final List<DateTime> slotsLivres = [];
    final agora = DateTime.now();

    for (final intervalo in horariosDoDia) {
      DateTime slotAtual = DateTime(
        dataAlvo.year,
        dataAlvo.month,
        dataAlvo.day,
        intervalo.inicio.hora,
        intervalo.inicio.minuto,
      );

      final DateTime fechamento = DateTime(
        dataAlvo.year,
        dataAlvo.month,
        dataAlvo.day,
        intervalo.fim.hora,
        intervalo.fim.minuto,
      );

      while (slotAtual.isBefore(fechamento)) {
        final DateTime fimDoSlot = slotAtual.add(
          Duration(minutes: quadra.duracaoSessaoMin),
        );

        if (fimDoSlot.isAfter(fechamento)) break;

        final bool ocupado = agendamentosDoDia.any((agendamento) {
          final agInicio = agendamento.dataInicio.toLocal();
          final agFim = agendamento.dataFim.toLocal();

          return slotAtual.isBefore(agFim) && fimDoSlot.isAfter(agInicio);
        });

        if (!ocupado && slotAtual.isAfter(agora)) {
          slotsLivres.add(slotAtual);
        }

        slotAtual = fimDoSlot;
      }
    }

    slotsLivres.sort((a, b) => a.compareTo(b));

    return slotsLivres;
  }

  Future<Map<String, dynamic>> gerarRelatorios({
    DateTime? inicio,
    DateTime? fim,
  }) async {
    final todos = await _agendamentoRepositorio.listarTodos();

    final filtrados = todos.where((a) {
      final local = a.dataInicio.toLocal();

      if (inicio != null && local.isBefore(inicio)) return false;
      if (fim != null && local.isAfter(fim)) return false;

      return true;
    }).toList();

    final contagemQuadras = <String, int>{};
    final contagemClientes = <String, int>{};

    final contagemDias = <String, int>{
      'Seg': 0,
      'Ter': 0,
      'Qua': 0,
      'Qui': 0,
      'Sex': 0,
      'Sáb': 0,
      'Dom': 0,
    };

    const nomesDias = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

    for (final ag in filtrados) {
      final nomeQuadra = ag.quadraNome ?? 'Quadra #${ag.quadraId}';

      contagemQuadras[nomeQuadra] = (contagemQuadras[nomeQuadra] ?? 0) + 1;

      final nomeCliente = ag.clienteNome ?? 'Cliente #${ag.clienteId}';

      contagemClientes[nomeCliente] = (contagemClientes[nomeCliente] ?? 0) + 1;

      final diaIndex = ag.dataInicio.toLocal().weekday - 1;

      if (diaIndex >= 0 && diaIndex < nomesDias.length) {
        final chaveDia = nomesDias[diaIndex];

        contagemDias[chaveDia] = (contagemDias[chaveDia] ?? 0) + 1;
      }
    }

    final topQuadras = contagemQuadras.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topClientes = contagemClientes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'quadrasUsadas': {for (final e in topQuadras.take(5)) e.key: e.value},
      'clientesFrequentes': {
        for (final e in topClientes.take(5)) e.key: e.value,
      },
      'diasMovimentados': contagemDias,
    };
  }
}
