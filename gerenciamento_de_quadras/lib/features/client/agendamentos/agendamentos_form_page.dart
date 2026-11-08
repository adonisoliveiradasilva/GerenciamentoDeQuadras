import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/widgets/atoms/form_input.dart';
import '../../../core/widgets/atoms/form_dropdown.dart';
import '../../../core/widgets/atoms/primary_button.dart';
import '../../../core/widgets/atoms/custom_toast.dart';
import 'agendamentos_form_controller.dart';

class AgendamentosFormPage extends StatefulWidget {
  final String? agendamentoId; 

  const AgendamentosFormPage({super.key, this.agendamentoId});

  @override
  State<AgendamentosFormPage> createState() => _AgendamentosFormPageState();
}

class _AgendamentosFormPageState extends State<AgendamentosFormPage> {
  final AgendamentosFormController _controller = AgendamentosFormController();

  @override
  void initState() {
    super.initState();
    _controller.carregarDados(widget.agendamentoId);
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
            const Text('Seus agendamentos', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0D253F))),
            const Text('Gerencie seus agendamentos', style: TextStyle(color: Colors.blueGrey, fontSize: 14)),
            const SizedBox(height: 32),

            ListenableBuilder(
              listenable: _controller,
              builder: (context, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormDropdown(
                      label: 'Selecionar quadra',
                      hintText: 'Escolha uma quadra',
                      value: _controller.quadraSelecionada,
                      items: _controller.quadrasDisponiveis,
                      onChanged: _controller.alterarQuadra,
                    ),
                    
                    if (_controller.quadraSelecionada != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E65D0).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF1E65D0).withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            const FaIcon(FontAwesomeIcons.circleInfo, color: Color(0xFF1E65D0), size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'A duração de cada seção nesta quadra é de ${_controller.duracaoDaQuadra}.',
                                style: const TextStyle(color: Color(0xFF0D253F), fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              }
            ),
            
            FormInput(
              label: 'Selecionar dia', 
              hintText: 'dd/mm/aaaa', 
              controller: _controller.dataController,
              readOnly: true,
              onTap: () => _controller.selecionarData(context),
            ),
            
            const Text('Selecionar horário de início', style: TextStyle(color: Colors.blueGrey, fontSize: 12)),
            const SizedBox(height: 8),
            
            FormInput(
              label: '', 
              hintText: '08:00', 
              controller: _controller.horaInicioController,
              readOnly: true,
              onTap: () => _controller.selecionarHora(context),
            ),

            ListenableBuilder(
              listenable: _controller,
              builder: (context, child) {
                return FormDropdown(
                  label: 'Quantidade de seções',
                  hintText: 'Selecione',
                  value: _controller.quantidadeSecoes,
                  items: _controller.opcoesSecoes,
                  onChanged: _controller.alterarSecoes,
                );
              }
            ),

            const SizedBox(height: 32),
            
            ListenableBuilder(
              listenable: _controller,
              builder: (context, child) {
                return PrimaryButton(
                  text: _controller.isLoading ? 'Salvando...' : 'Salvar agendamento',
                  icon: const FaIcon(FontAwesomeIcons.solidFloppyDisk, color: Colors.white, size: 18),
                  onPressed: _controller.isLoading ? () {} : () async {
                    final errorMessage = await _controller.salvar();
                    if (context.mounted) {
                      if (errorMessage != null) {
                        CustomToast.showWarning(context, errorMessage);
                      } else {
                        CustomToast.showSuccess(context, 'Agendamento salvo com sucesso!');
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