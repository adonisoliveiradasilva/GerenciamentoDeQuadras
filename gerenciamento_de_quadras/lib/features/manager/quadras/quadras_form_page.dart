import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gerenciamento_de_quadras/core/widgets/atoms/custom_toast.dart';
import '../../../core/widgets/atoms/form_input.dart';
import '../../../core/widgets/atoms/primary_button.dart';
import '../../../core/widgets/molecules/schedule_card.dart';
import 'quadras_form_controller.dart';
import '../../../core/widgets/atoms/form_dropdown.dart';

class QuadrasFormPage extends StatefulWidget {
  final String? quadraName; 

  const QuadrasFormPage({super.key, this.quadraName});

  @override
  State<QuadrasFormPage> createState() => _QuadrasFormPageState();
}

class _QuadrasFormPageState extends State<QuadrasFormPage> {
  final QuadrasFormController _controller = QuadrasFormController();

  @override
  void initState() {
    super.initState();
    _controller.carregarDados(widget.quadraName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.quadraName != null;

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
            const Text('Quadras', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0D253F))),
            Text(isEditing ? 'Editar quadra' : 'Criar nova quadra', style: const TextStyle(color: Colors.blueGrey, fontSize: 14)),
            const SizedBox(height: 32),

            FormInput(label: 'Nome da quadra', hintText: 'Nome da quadra', controller: _controller.nomeController),
            FormInput(label: 'Localização', hintText: 'Localização', controller: _controller.localizacaoController),
            FormInput(label: 'Descrição', hintText: 'Campo de texto livre', maxLines: 4, controller: _controller.descricaoController),
            
            ListenableBuilder(
              listenable: _controller,
              builder: (context, child) {
                return FormDropdown(
                  label: 'Duração de cada seção',
                  hintText: 'Selecione a duração',
                  value: _controller.duracaoSelecionada,
                  items: const ['30m', '60m'],
                  onChanged: _controller.alterarDuracao,
                );
              }
            ),

            const SizedBox(height: 16),
            const Text('Horário de funcionamento', style: TextStyle(color: Colors.blueGrey, fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),

            ListenableBuilder(
              listenable: _controller,
              builder: (context, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Dias da semana', style: TextStyle(color: Colors.blueGrey, fontSize: 12)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: ExpansionTile(
                        title: const Text('Selecionar', style: TextStyle(color: Colors.blueGrey)),
                        iconColor: const Color(0xFF1E65D0),
                        collapsedIconColor: const Color(0xFF1E65D0),
                        shape: const Border(),
                        collapsedShape: const Border(),
                        children: List.generate(_controller.diasSemana.length, (index) {
                          final dia = _controller.diasSemana[index];
                          return CheckboxListTile(
                            title: Text(dia.name, style: const TextStyle(color: Colors.blueGrey)),
                            value: dia.isSelected,
                            activeColor: const Color(0xFF1E65D0),
                            controlAffinity: ListTileControlAffinity.leading,
                            onChanged: (val) => _controller.alternarDia(index),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    ..._controller.diasSemana.asMap().entries
                        .where((entry) => entry.value.isSelected)
                        .map((entry) {
                      final index = entry.key;
                      final dia = entry.value;

                      return ScheduleCard(
                        daySchedule: dia,
                        onAddInterval: () => _controller.adicionarIntervalo(index),
                        onRemoveInterval: (intervalIndex) => _controller.removerIntervalo(index, intervalIndex),
                        onTimeChanged: (intervalIndex, isStart, time) => _controller.atualizarHorario(index, intervalIndex, isStart, time),
                      );
                    }),
                  ],
                );
              }
            ),

            const SizedBox(height: 32),
            
            ListenableBuilder(
              listenable: _controller,
              builder: (context, child) {
                return PrimaryButton(
                  text: _controller.isLoading ? 'Salvando...' : 'Salvar quadra',
                  icon: const FaIcon(FontAwesomeIcons.solidFloppyDisk, color: Colors.white, size: 18),
                  onPressed: _controller.isLoading ? () {} : () async {
                    
                    final errorMessage = await _controller.salvar();
                    
                    if (context.mounted) {
                      if (errorMessage != null) {
                        CustomToast.showWarning(context, errorMessage);
                      } else {
                        CustomToast.showSuccess(context, 'Quadra salva com sucesso!');
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