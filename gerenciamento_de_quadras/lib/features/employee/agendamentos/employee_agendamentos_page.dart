import 'package:flutter/material.dart';
import '../../../../core/widgets/atoms/search_input.dart';
import '../../../../core/widgets/atoms/pagination_controls.dart';
import '../../../../core/widgets/molecules/action_list_card.dart';
import '../../../../core/widgets/molecules/agendamento_details_modal.dart';
import 'employee_agendamentos_controller.dart';

class EmployeeAgendamentosPage extends StatefulWidget {
  final bool apenasHoje; 

  const EmployeeAgendamentosPage({super.key, this.apenasHoje = false});

  @override
  State<EmployeeAgendamentosPage> createState() => _EmployeeAgendamentosPageState();
}

class _EmployeeAgendamentosPageState extends State<EmployeeAgendamentosPage> {
  late EmployeeAgendamentosController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EmployeeAgendamentosController(apenasHoje: widget.apenasHoje);
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
            const Text('Agendamentos', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0D253F))),
            const Text('Valide os agendamentos', style: TextStyle(color: Colors.blueGrey, fontSize: 14)),
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
                
                      bool showDateHeader = true;
                      if (index > 0) {
                        final previousItem = lista[index - 1];
                        if (previousItem.data == item.data) {
                          showDateHeader = false;
                        }
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showDateHeader) ...[
                            Text(item.data, style: const TextStyle(color: Colors.blueGrey, fontSize: 12, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                          ],
                          ActionListCard(
                            title: item.descricaoCompleta,
                            onView: () {
                              showDialog(
                                context: context,
                                builder: (context) => AgendamentoDetailsModal(
                                  cliente: item.cliente,
                                  data: item.data,
                                  horario: item.horario,
                                  quadra: item.quadra,
                                ),
                              );
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
          ],
        ),
      ),
    );
  }
}