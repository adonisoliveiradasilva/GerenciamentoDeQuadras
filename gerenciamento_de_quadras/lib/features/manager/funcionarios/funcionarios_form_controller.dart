import 'package:flutter/material.dart';

import '../../../core/models/usuario_model.dart';
import '../../../core/services/usuarios_service.dart';

class FuncionariosFormController extends ChangeNotifier {
  final UsuariosService _service = UsuariosService();

  final nomeController = TextEditingController();
  final dataNascimentoController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();

  int? funcionarioId;
  bool isLoading = false;

  void carregarDados(UsuarioModel? funcionario) {
    if (funcionario == null) return;

    funcionarioId = funcionario.id;
    nomeController.text = funcionario.nome;
    emailController.text = funcionario.email;
    dataNascimentoController.text = funcionario.dataNascimentoFormatada ?? '';
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
      dataNascimentoController.text = '$dia/$mes/${picked.year}';
    }
  }

  Future<String?> salvar(bool isEditing) async {
    final nome = nomeController.text.trim();
    if (nome.isEmpty) return 'Favor preencher o nome.';

    final email = emailController.text.trim();
    if (email.isEmpty) return 'Favor preencher o email.';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) return 'Digite um email válido.';

    final senha = senhaController.text;
    final confirmarSenha = confirmarSenhaController.text;

    if (!isEditing || senha.isNotEmpty || confirmarSenha.isNotEmpty) {
      if (senha.length < 8) {
        return 'A senha deve ter no mínimo 8 caracteres.';
      }
      if (senha != confirmarSenha) {
        return 'As senhas não coincidem.';
      }
    }

    final dataIso = UsuarioModel.formatarDataParaApi(
      dataNascimentoController.text,
    );

    isLoading = true;
    notifyListeners();

    try {
      if (funcionarioId == null) {
        await _service.criarFuncionario(
          nome: nome,
          email: email,
          dataNascimentoIso: dataIso,
          senha: senha,
          confirmarSenha: confirmarSenha,
        );
      } else {
        await _service.atualizarFuncionario(
          id: funcionarioId!,
          nome: nome,
          email: email,
          dataNascimentoIso: dataIso,
          senha: senha.isEmpty ? null : senha,
          confirmarSenha: senha.isEmpty ? null : confirmarSenha,
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
    dataNascimentoController.dispose();
    emailController.dispose();
    senhaController.dispose();
    confirmarSenhaController.dispose();
    super.dispose();
  }
}
