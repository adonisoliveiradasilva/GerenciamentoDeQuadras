import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class ClientesFormController extends ChangeNotifier {
  final nomeController = TextEditingController();
  final dataNascimentoController = TextEditingController();
  final emailController = TextEditingController();
  final telefoneController = TextEditingController();

  bool isLoading = false;

  final telefoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####', 
    filter: { "#": RegExp(r'[0-9]') },
  );

  void carregarDados(String? clienteName) {
    if (clienteName != null) {
      nomeController.text = clienteName;
      // Mock API
      dataNascimentoController.text = "01/05/2003"; 
      emailController.text = "cliente@email.com";
      telefoneController.text = telefoneMask.maskText("31999999999");
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

  Future<String?> salvar() async {
    if (nomeController.text.trim().isEmpty) return "Favor preencher o nome.";
    if (dataNascimentoController.text.trim().isEmpty) return "Favor preencher a data de nascimento.";
    
    final email = emailController.text.trim();
    if (email.isEmpty) return "Favor preencher o email.";
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) return "Digite um email válido.";

    final telefoneIncompleto = telefoneMask.getUnmaskedText().length < 11;
    if (telefoneController.text.isEmpty || telefoneIncompleto) {
      return "Digite um telefone válido com DDD.";
    }

    isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1)); // Mock API
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
    telefoneController.dispose();
    super.dispose();
  }
}