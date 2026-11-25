import 'dart:async';

import '../../../core/http/erros.dart';
import '../../quadras/domain/quadra_repositorio.dart';
import 'agendamento.dart';
import 'agendamento_repositorio.dart';

class ServicoDeAgendamentos {
  final AgendamentoRepositorio _agendamentoRepositorio;
  final QuadraRepositorio _quadraRepositorio;

  ServicoDeAgendamentos(this._agendamentoRepositorio, this._quadraRepositorio);

  Future<Agendamento> criarAgendamento({
    required int quadraId,
    required int clienteId,
    required DateTime dataInicio,
    required DateTime dataFim,
    double valorTotal = 0.0,
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
      throw const NaoEncontrado(
        'Quadra não encontrada.',
        'QUADRA_NAO_ENCONTRADA',
      );
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
        dataInicio.year,
        dataInicio.month,
        dataInicio.day,
        h.inicio.hora,
        h.inicio.minuto,
      );

      final fechamento = DateTime(
        dataInicio.year,
        dataInicio.month,
        dataInicio.day,
        h.fim.hora,
        h.fim.minuto,
      );

      return !dataInicio.isBefore(abertura) && !dataFim.isAfter(fechamento);
    });

    if (!dentroDoFuncionamento) {
      throw const ErroValidacao(
        'O horário escolhido está fora do funcionamento da quadra.',
        codigo: 'FORA_DO_FUNCIONAMENTO',
      );
    }

    final existeConflito = await _agendamentoRepositorio
        .existeConflitoDeHorario(quadraId, dataInicio, dataFim);

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
      valorTotal: valorTotal,
      criadoEm: DateTime.now(),
      atualizadoEm: DateTime.now(),
    );

    return _agendamentoRepositorio.criar(novoAgendamento);
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

    if (existente == null || existente.status == StatusAgendamento.cancelado) {
      throw const NaoEncontrado(
        'Agendamento não encontrado.',
        'AGENDAMENTO_NAO_ENCONTRADO',
      );
    }

    if (existente.clienteId != clienteId) {
      throw const ErroValidacao(
        'Você não tem permissão para alterar este agendamento.',
        codigo: 'SEM_PERMISSAO',
      );
    }

    if (!dataInicio.isBefore(dataFim)) {
      throw const ErroValidacao(
        'A data de término deve ser posterior à data de início.',
        codigo: 'INTERVALO_INVALIDO',
      );
    }

    final existeConflito = await _agendamentoRepositorio
        .existeConflitoDeHorario(
          quadraId,
          dataInicio,
          dataFim,
          ignorarAgendamentoId: agendamentoId,
        );

    if (existeConflito) {
      throw const Conflito(
        'HORARIO_INDISPONIVEL',
        'Já existe um agendamento para esta quadra neste horário.',
      );
    }

    final atualizado = Agendamento(
      id: existente.id,
      quadraId: quadraId,
      clienteId: existente.clienteId,
      quadraNome: existente.quadraNome,
      clienteNome: existente.clienteNome,
      dataInicio: dataInicio,
      dataFim: dataFim,
      status: existente.status,
      valorTotal: valorTotal,
      criadoEm: existente.criadoEm,
      atualizadoEm: DateTime.now(),
    );

    return _agendamentoRepositorio.atualizar(atualizado);
  }

  Future<void> cancelarAgendamento({
    required int agendamentoId,
    required int usuarioId,
    required bool isCliente,
  }) async {
    final existente = await _agendamentoRepositorio.buscarPorId(agendamentoId);

    if (existente == null || existente.status == StatusAgendamento.cancelado) {
      throw const NaoEncontrado(
        'Agendamento não encontrado.',
        'AGENDAMENTO_NAO_ENCONTRADO',
      );
    }

    if (isCliente && existente.clienteId != usuarioId) {
      throw const ErroValidacao(
        'Você não tem permissão para cancelar este agendamento.',
        codigo: 'SEM_PERMISSAO',
      );
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
            '${local.day.toString().padLeft(2, '0')}/'
            '${local.month.toString().padLeft(2, '0')}/'
            '${local.year}';

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
      throw const NaoEncontrado(
        'Quadra não encontrada.',
        'QUADRA_NAO_ENCONTRADA',
      );
    }

    final horariosDoDia = quadra.horarios
        .where((h) => h.diaSemana == dataAlvo.weekday)
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

    final slotsLivres = <DateTime>[];
    final agora = DateTime.now();

    for (final horario in horariosDoDia) {
      var slotAtual = DateTime(
        dataAlvo.year,
        dataAlvo.month,
        dataAlvo.day,
        horario.inicio.hora,
        horario.inicio.minuto,
      );

      final fechamento = DateTime(
        dataAlvo.year,
        dataAlvo.month,
        dataAlvo.day,
        horario.fim.hora,
        horario.fim.minuto,
      );

      while (slotAtual.isBefore(fechamento)) {
        final fimDoSlot = slotAtual.add(
          Duration(minutes: quadra.duracaoSessaoMin),
        );

        if (fimDoSlot.isAfter(fechamento)) break;

        final ocupado = agendamentosDoDia.any((agendamento) {
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
