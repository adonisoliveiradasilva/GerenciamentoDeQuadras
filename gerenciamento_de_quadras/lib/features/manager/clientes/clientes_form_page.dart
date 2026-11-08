import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/widgets/atoms/form_input.dart';
import '../../../core/widgets/atoms/primary_button.dart';
import '../../../core/widgets/atoms/custom_toast.dart';
import 'clientes_form_controller.dart';

class ClientesFormPage extends StatefulWidget {
  final String? clienteName; 

  const ClientesFormPage({super.key, this.clienteName});

  @override
  State<ClientesFormPage> createState() => _ClientesFormPageState();
}

class _ClientesFormPageState extends State<ClientesFormPage> {
  final ClientesFormController _controller = ClientesFormController();

  @override
  void initState() {
    super.initState();
    _controller.carregarDados(widget.clienteName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            const Text('Clientes', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0D253F))),
            const Text('Gerencie os clientes', style: TextStyle(color: Colors.blueGrey, fontSize: 14)),
            const SizedBox(height: 32),

            FormInput(
              label: 'Nome do cliente', 
              hintText: 'Nome do cliente', 
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
              hintText: 'Email do cliente', 
              controller: _controller.emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            
            FormInput(
              label: 'Telefone', 
              hintText: 'Telefone do cliente', 
              controller: _controller.telefoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [_controller.telefoneMask],
            ),

            const SizedBox(height: 32),
            
            ListenableBuilder(
              listenable: _controller,
              builder: (context, child) {
                return PrimaryButton(
                  text: _controller.isLoading ? 'Salvando...' : 'Salvar cliente',
                  icon: const FaIcon(FontAwesomeIcons.solidFloppyDisk, color: Colors.white, size: 18),
                  onPressed: _controller.isLoading ? () {} : () async {
                    final errorMessage = await _controller.salvar();
                    if (context.mounted) {
                      if (errorMessage != null) {
                        CustomToast.showWarning(context, errorMessage);
                      } else {
                        CustomToast.showSuccess(context, 'Cliente salvo com sucesso!');
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