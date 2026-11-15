import 'package:flutter/material.dart';

import '../../../core/models/day_schedule.dart';
import '../../../core/models/quadra_model.dart';
import '../../../core/services/quadras_service.dart';

class QuadrasFormController extends ChangeNotifier {
  final QuadrasService _service = QuadrasService();

  final nomeController = TextEditingController();
  final localizacaoController = TextEditingController();
  final descricaoController = TextEditingController();

  int? quadraId;
  String? duracaoSelecionada;
  bool isLoading = false;

  List<DaySchedule> diasSemana = [
    DaySchedule(name: 'Segunda'),
    DaySchedule(name: 'Terça'),
    DaySchedule(name: 'Quarta'),
    DaySchedule(name: 'Quinta'),
    DaySchedule(name: 'Sexta'),
    DaySchedule(name: 'Sábado'),
    DaySchedule(name: 'Domingo'),
  ];

  void alterarDuracao(String? novaDuracao) {
    duracaoSelecionada = novaDuracao;
    notifyListeners();
  }

  void alternarDia(int index) {
    diasSemana[index].isSelected = !diasSemana[index].isSelected;
    notifyListeners();
  }

  void adicionarIntervalo(int dayIndex) {
    diasSemana[dayIndex].intervals.add(TimeInterval());
    notifyListeners();
  }

  void removerIntervalo(int dayIndex, int intervalIndex) {
    diasSemana[dayIndex].intervals.removeAt(intervalIndex);
    notifyListeners();
  }

  void atualizarHorario(
    int dayIndex,
    int intervalIndex,
    bool isStart,
    TimeOfDay time,
  ) {
    if (isStart) {
      diasSemana[dayIndex].intervals[intervalIndex].start = time;
    } else {
      diasSemana[dayIndex].intervals[intervalIndex].end = time;
    }
    notifyListeners();
  }

  void carregarDados(QuadraModel? quadra) {
    if (quadra == null) return;

    quadraId = quadra.id;
    nomeController.text = quadra.nome;
    localizacaoController.text = quadra.localizacao;
    descricaoController.text = quadra.descricao ?? '';
    duracaoSelecionada = '${quadra.duracaoSessaoMin}m';

    for (final dia in diasSemana) {
      dia.isSelected = false;
      dia.intervals = [];
    }

    for (final horario in quadra.horarios) {
      final index = horario.diaSemana - 1;
      if (index >= 0 && index < diasSemana.length) {
        diasSemana[index].isSelected = true;
        diasSemana[index].intervals.add(
          TimeInterval(
            start: IntervaloFuncionamentoModel.parseTimeOfDay(horario.inicio),
            end: IntervaloFuncionamentoModel.parseTimeOfDay(horario.fim),
          ),
        );
      }
    }

    for (final dia in diasSemana) {
      if (dia.intervals.isEmpty) {
        dia.intervals.add(
          TimeInterval(
            start: const TimeOfDay(hour: 8, minute: 0),
            end: const TimeOfDay(hour: 12, minute: 0),
          ),
        );
      }
    }
  }

  Future<String?> salvar() async {
    final nome = nomeController.text.trim();
    final localizacao = localizacaoController.text.trim();

    if (nome.isEmpty) {
      return 'Favor preencher o nome da quadra.';
    }
    if (localizacao.isEmpty) {
      return 'Favor preencher a localização.';
    }
    if (duracaoSelecionada == null) {
      return 'Favor selecionar a duração de cada seção.';
    }

    final duracaoMin = int.tryParse(
      duracaoSelecionada!.replaceAll(RegExp(r'\D'), ''),
    );
    if (duracaoMin == null) {
      return 'Duração inválida.';
    }

    final horariosPayload = <IntervaloFuncionamentoModel>[];

    for (int i = 0; i < diasSemana.length; i++) {
      final dia = diasSemana[i];
      if (!dia.isSelected) continue;

      if (dia.intervals.isEmpty) {
        return 'Adicione ao menos um horário para ${dia.name}.';
      }

      for (final intervalo in dia.intervals) {
        if (intervalo.start == null || intervalo.end == null) {
          return 'Preencha o horário de início e fim em ${dia.name}.';
        }
        final inicioMin = intervalo.start!.hour * 60 + intervalo.start!.minute;
        final fimMin = intervalo.end!.hour * 60 + intervalo.end!.minute;
        if (inicioMin >= fimMin) {
          return 'O horário final deve ser depois do inicial em ${dia.name}.';
        }

        horariosPayload.add(
          IntervaloFuncionamentoModel(
            diaSemana: i + 1,
            inicio: IntervaloFuncionamentoModel.formatTimeOfDay(
              intervalo.start!,
            ),
            fim: IntervaloFuncionamentoModel.formatTimeOfDay(intervalo.end!),
          ),
        );
      }
    }

    isLoading = true;
    notifyListeners();

    try {
      if (quadraId == null) {
        await _service.criarQuadra(
          nome: nome,
          localizacao: localizacao,
          descricao: descricaoController.text,
          duracaoSessaoMin: duracaoMin,
          horarios: horariosPayload,
        );
      } else {
        await _service.atualizarQuadra(
          id: quadraId!,
          nome: nome,
          localizacao: localizacao,
          descricao: descricaoController.text,
          duracaoSessaoMin: duracaoMin,
          horarios: horariosPayload,
        );
      }

      isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    localizacaoController.dispose();
    descricaoController.dispose();
    super.dispose();
  }
}
