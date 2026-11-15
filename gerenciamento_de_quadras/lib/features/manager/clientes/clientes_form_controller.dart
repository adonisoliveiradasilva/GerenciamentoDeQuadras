import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../core/models/usuario_model.dart';
import '../../../core/services/usuarios_service.dart';

class ClientesFormController extends ChangeNotifier {
  final UsuariosService _service = UsuariosService();

  final nomeController = TextEditingController();
  final dataNascimentoController = TextEditingController();
  final emailController = TextEditingController();
  final telefoneController = TextEditingController();

  int? clienteId;
  bool isLoading = false;

  final telefoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  void carregarDados(UsuarioModel? cliente) {
    if (cliente == null) return;

    clienteId = cliente.id;
    nomeController.text = cliente.nome;
    emailController.text = cliente.email;
    dataNascimentoController.text = cliente.dataNascimentoFormatada ?? '';

    if (cliente.telefone != null && cliente.telefone!.isNotEmpty) {
      telefoneController.text = telefoneMask.maskText(cliente.telefone!);
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
      dataNascimentoController.text = '$dia/$mes/${picked.year}';
    }
  }

  Future<String?> salvar() async {
    final nome = nomeController.text.trim();
    if (nome.isEmpty) return 'Favor preencher o nome.';

    final email = emailController.text.trim();
    if (email.isEmpty) return 'Favor preencher o email.';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) return 'Digite um email válido.';

    final telefoneDigitos = telefoneController.text.replaceAll(
      RegExp(r'\D'),
      '',
    );
    if (telefoneDigitos.isNotEmpty &&
        (telefoneDigitos.length < 10 || telefoneDigitos.length > 11)) {
      return 'Digite um telefone válido com DDD.';
    }

    final dataIso = UsuarioModel.formatarDataParaApi(
      dataNascimentoController.text,
    );

    isLoading = true;
    notifyListeners();

    try {
      if (clienteId == null) {
        await _service.criarCliente(
          nome: nome,
          email: email,
          telefone: telefoneDigitos.isEmpty ? null : telefoneDigitos,
          dataNascimentoIso: dataIso,
        );
      } else {
        await _service.atualizarCliente(
          id: clienteId!,
          nome: nome,
          email: email,
          telefone: telefoneDigitos.isEmpty ? null : telefoneDigitos,
          dataNascimentoIso: dataIso,
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
    telefoneController.dispose();
    super.dispose();
  }
}
