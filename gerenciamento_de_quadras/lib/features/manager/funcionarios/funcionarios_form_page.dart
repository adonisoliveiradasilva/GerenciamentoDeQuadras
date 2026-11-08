import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/widgets/atoms/form_input.dart';
import '../../../core/widgets/atoms/form_input_password.dart';
import '../../../core/widgets/atoms/primary_button.dart';
import '../../../core/widgets/atoms/custom_toast.dart';
import 'funcionarios_form_controller.dart';

class FuncionariosFormPage extends StatefulWidget {
  final String? funcionarioName; 

  const FuncionariosFormPage({super.key, this.funcionarioName});

  @override
  State<FuncionariosFormPage> createState() => _FuncionariosFormPageState();
}

class _FuncionariosFormPageState extends State<FuncionariosFormPage> {
  final FuncionariosFormController _controller = FuncionariosFormController();

  @override
  void initState() {
    super.initState();
    _controller.carregarDados(widget.funcionarioName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.funcionarioName != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0D253F)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Funcionários', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0D253F))),
            Text(isEditing ? 'Editar funcionário' : 'Gerencie os funcionários', style: const TextStyle(color: Colors.blueGrey, fontSize: 14)),
            const SizedBox(height: 32),

            FormInput(
              label: 'Nome do funcionário', 
              hintText: 'Nome do funcionário', 
              controller: _controller.nomeController,
            ),
            
            FormInput(
              label: 'Data de nascimento', 
              hintText: 'dd/mm/aaaa', 
              controller: _controller.dataNascimentoController,
              readOnly: true,
              onTap: () => _controller.selecionarData(context),
            ),
            
            FormInput(
              label: 'Email', 
              hintText: 'Email do funcionário', 
              controller: _controller.emailController,
              keyboardType: TextInputType.emailAddress,
            ),

            FormInputPassword(
              label: 'Senha',
              hintText: '***************',
              controller: _controller.senhaController,
            ),

            FormInputPassword(
              label: 'Confirmar senha',
              hintText: '***************',
              controller: _controller.confirmarSenhaController,
            ),

            const SizedBox(height: 32),
            
            ListenableBuilder(
              listenable: _controller,
              builder: (context, child) {
                return PrimaryButton(
                  text: _controller.isLoading ? 'Salvando...' : 'Salvar funcionário',
                  icon: const FaIcon(FontAwesomeIcons.solidFloppyDisk, color: Colors.white, size: 18),
                  onPressed: _controller.isLoading ? () {} : () async {
                    final errorMessage = await _controller.salvar(isEditing);
                    if (context.mounted) {
                      if (errorMessage != null) {
                        CustomToast.showWarning(context, errorMessage);
                      } else {
                        CustomToast.showSuccess(context, 'Funcionário salvo com sucesso!');
                        Navigator.pop(context);
                      }
                    }
                  },
                );
              }
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}