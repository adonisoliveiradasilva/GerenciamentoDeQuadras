import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/widgets/atoms/search_input.dart';
import '../../../../core/widgets/atoms/pagination_controls.dart';
import '../../../../core/widgets/molecules/action_list_card.dart';
import '../../../../core/widgets/atoms/primary_button.dart';
import '../../../../core/widgets/molecules/delete_confirmation_modal.dart';
import '../../../../core/widgets/atoms/custom_toast.dart';
import 'agendamentos_controller.dart';
import 'agendamentos_form_page.dart';

class AgendamentosPage extends StatefulWidget {
  final bool isHistory; // Define se a tela carrega o Histórico ou Futuro

  const AgendamentosPage({super.key, this.isHistory = false});

  @override
  State<AgendamentosPage> createState() => _AgendamentosPageState();
}

class _AgendamentosPageState extends State<AgendamentosPage> {
  late AgendamentosController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AgendamentosController(isHistory: widget.isHistory);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              widget.isHistory ? 'Histórico' : 'Seus agendamentos', 
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0D253F)),
            ),
            Text(
              widget.isHistory ? 'Agendamentos passados' : 'Gerencie seus agendamentos', 
              style: const TextStyle(color: Colors.blueGrey, fontSize: 14),
            ),
            const SizedBox(height: 24),
            
            SearchInput(hintText: 'Pesquisar', onChanged: _controller.pesquisar),
            const SizedBox(height: 24),

            Expanded(
              child: ListenableBuilder(
                listenable: _controller,
                builder: (context, child) {
                  final lista = _controller.agendamentosPaginados;
                  if (lista.isEmpty) {
                    return const Center(child: Text("Nenhum agendamento encontrado.", style: TextStyle(color: Colors.grey)));
                  }

                  return ListView.builder(
                    itemCount: lista.length,
                    itemBuilder: (context, index) {
                      final item = lista[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.data, style: const TextStyle(color: Colors.blueGrey, fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          ActionListCard(
                            title: item.descricao,
                            onEdit: widget.isHistory ? null : () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => AgendamentosFormPage(agendamentoId: item.id)));
                            },
                            onDelete: widget.isHistory ? null : () async {
                              final confirmou = await showDialog<bool>(
                                context: context,
                                builder: (context) => DeleteConfirmationModal(
                                  title: 'Agendamentos',
                                  subtitle: 'Cancelar agendamento',
                                  itemName: '${item.data} - ${item.descricao}',
                                ),
                              );

                              if (confirmou == true && context.mounted) {
                                final error = await _controller.cancelarAgendamento(item.id);
                                if (context.mounted) {
                                  if (error != null) CustomToast.showError(context, error);
                                  else CustomToast.showSuccess(context, 'Agendamento cancelado com sucesso!');
                                }
                              }
                            },
                          ),
                          const SizedBox(height: 8),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            
            const SizedBox(height: 16),

            ListenableBuilder(
              listenable: _controller,
              builder: (context, child) {
                final total = _controller.totalPages == 0 ? 1 : _controller.totalPages;
                return PaginationControls(
                  currentPage: _controller.currentPage,
                  totalPages: total, 
                  itemsPerPage: _controller.itemsPerPage,
                  onItemsPerPageChanged: (v) { if (v != null) _controller.alterarItensPorPagina(v); },
                  onPrevious: _controller.paginaAnterior,
                  onNext: _controller.proximaPagina,
                );
              }
            ),

            const SizedBox(height: 16),
            
            if (!widget.isHistory)
              PrimaryButton(
                text: 'Novo agendamento',
                icon: const FaIcon(FontAwesomeIcons.circlePlus, color: Colors.white, size: 18),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AgendamentosFormPage()));
                },
              ),
          ],
        ),
      ),
    );
  }
}