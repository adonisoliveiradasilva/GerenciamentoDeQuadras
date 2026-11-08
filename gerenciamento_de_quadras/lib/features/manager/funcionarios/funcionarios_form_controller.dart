import 'package:flutter/material.dart';

class FuncionariosFormController extends ChangeNotifier {
  final nomeController = TextEditingController();
  final dataNascimentoController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();

  bool isLoading = false;

  void carregarDados(String? funcionarioName) {
    if (funcionarioName != null) {
      nomeController.text = funcionarioName;
      dataNascimentoController.text = "15/08/1995"; 
      emailController.text = "funcionario@email.com";
    }
  }

  Future<void> selecionarData(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final dia = picked.day.toString().padLeft(2, '0');
      final mes = picked.month.toString().padLeft(2, '0');
      dataNascimentoController.text = "$dia/$mes/${picked.year}";
    }
  }

  Future<String?> salvar(bool isEditing) async {
    if (nomeController.text.trim().isEmpty) return "Favor preencher o nome.";
    if (dataNascimentoController.text.trim().isEmpty) return "Favor preencher a data de nascimento.";
    
    final email = emailController.text.trim();
    if (email.isEmpty) return "Favor preencher o email.";
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) return "Digite um email válido.";

    if (!isEditing || senhaController.text.isNotEmpty || confirmarSenhaController.text.isNotEmpty) {
      if (senhaController.text.length < 6) return "A senha deve ter no mínimo 6 caracteres.";
      if (senhaController.text != confirmarSenhaController.text) return "As senhas não coincidem.";
    }

    isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1)); 
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
    nomeController.dispose();
    dataNascimentoController.dispose();
    emailController.dispose();
    senhaController.dispose();
    confirmarSenhaController.dispose();
    super.dispose();
  }
}