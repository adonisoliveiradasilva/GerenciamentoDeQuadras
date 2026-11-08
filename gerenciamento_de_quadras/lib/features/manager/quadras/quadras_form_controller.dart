import 'package:flutter/material.dart';
import '../../../core/models/day_schedule.dart';

class QuadrasFormController extends ChangeNotifier {
  final nomeController = TextEditingController();
  final localizacaoController = TextEditingController();
  final descricaoController = TextEditingController();
  
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

  void atualizarHorario(int dayIndex, int intervalIndex, bool isStart, TimeOfDay time) {
    if (isStart) {
      diasSemana[dayIndex].intervals[intervalIndex].start = time;
    } else {
      diasSemana[dayIndex].intervals[intervalIndex].end = time;
    }
    notifyListeners();
  }

  void carregarDados(String? quadraName) {
    if (quadraName != null) {
      nomeController.text = quadraName;
      duracaoSelecionada = '30m'; 
    }
  }

  Future<String?> salvar() async {
    if (nomeController.text.trim().isEmpty) {
      return "Favor preencher o nome da quadra.";
    }
    if (localizacaoController.text.trim().isEmpty) {
      return "Favor preencher a localização.";
    }
    if (duracaoSelecionada == null) {
      return "Favor selecionar a duração de cada seção.";
    }
    

    isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1)); // Mock da API
      // await httpClient.post('/api/quadras', data: payload);
      
      isLoading = false;
      notifyListeners();
      
      return null;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return "Erro ao comunicar com o servidor. Tente novamente.";
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