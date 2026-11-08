import 'package:flutter/material.dart';

class AgendamentosFormController extends ChangeNotifier {
  String? quadraSelecionada;
  String? quantidadeSecoes = '1';
  final dataController = TextEditingController();
  final horaInicioController = TextEditingController();

  bool isLoading = false;

  // Mock simulando o que a API vai retornar (Nome da quadra -> Duração)
  final Map<String, String> _quadrasMock = {
    'Quadra 1': '30m',
    'Quadra 2': '60m',
    'Quadra 3': '30m',
  };

  List<String> get quadrasDisponiveis => _quadrasMock.keys.toList();
  
  // Resgata a duração da quadra que o usuário selecionou
  String get duracaoDaQuadra {
    if (quadraSelecionada == null) return '';
    return _quadrasMock[quadraSelecionada]!;
  }

  final List<String> opcoesSecoes = ['1', '2', '3', '4']; 

  void carregarDados(String? agendamentoId) {
    if (agendamentoId != null) {
      quadraSelecionada = 'Quadra 1';
      quantidadeSecoes = '2';
      dataController.text = "01/01/2026";
      horaInicioController.text = "08:00";
    }
  }

  void alterarQuadra(String? nova) { 
    quadraSelecionada = nova; 
    notifyListeners(); 
  }
  
  void alterarSecoes(String? nova) { 
    quantidadeSecoes = nova; 
    notifyListeners(); 
  }

  Future<void> selecionarData(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), 
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      final dia = picked.day.toString().padLeft(2, '0');
      final mes = picked.month.toString().padLeft(2, '0');
      dataController.text = "$dia/$mes/${picked.year}";
    }
  }

  Future<void> selecionarHora(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked != null) {
      horaInicioController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }

  Future<String?> salvar() async {
    if (quadraSelecionada == null) return "Selecione uma quadra.";
    if (dataController.text.isEmpty) return "Selecione o dia do agendamento.";
    if (horaInicioController.text.isEmpty) return "Selecione o horário de início.";
    if (quantidadeSecoes == null) return "Selecione a quantidade de seções.";

    isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1)); // Mock POST API
      isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return "Erro ao comunicar com o servidor.";
    }
  }

  @override
  void dispose() {
    dataController.dispose();
    horaInicioController.dispose();
    super.dispose();
  }
}