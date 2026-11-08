import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/widgets/atoms/search_input.dart';
import '../../../../core/widgets/atoms/pagination_controls.dart';
import '../../../../core/widgets/molecules/action_list_card.dart';
import '../../../../core/widgets/atoms/primary_button.dart';
import '../../../../core/widgets/molecules/delete_confirmation_modal.dart';
import '../../../../core/widgets/atoms/custom_toast.dart';
import 'clientes_controller.dart';
import 'clientes_form_page.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  final ClientesController _controller = ClientesController();

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
            const Text('Clientes', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0D253F))),
            const Text('Gerencie os clientes', style: TextStyle(color: Colors.blueGrey, fontSize: 14)),
            const SizedBox(height: 24),
            
            SearchInput(hintText: 'Pesquisar', onChanged: _controller.pesquisar),
            const SizedBox(height: 24),

            Expanded(
              child: ListenableBuilder(
                listenable: _controller,
                builder: (context, child) {
                  final lista = _controller.clientesPaginados;
                  if (lista.isEmpty) return const Center(child: Text("Nenhum cliente encontrado.", style: TextStyle(color: Colors.grey)));

                  return ListView.builder(
                    itemCount: lista.length,
                    itemBuilder: (context, index) {
                      return ActionListCard(
                        title: lista[index],
                        onEdit: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ClientesFormPage(clienteName: lista[index])));
                        },
                        onDelete: () async {
                          final confirmou = await showDialog<bool>(
                            context: context,
                            builder: (context) => DeleteConfirmationModal(
                              title: 'Clientes',
                              subtitle: 'Remover cliente',
                              itemName: lista[index],
                            ),
                          );

                          if (confirmou == true && context.mounted) {
                            final error = await _controller.deletarCliente(lista[index]);
                            if (context.mounted) {
                              if (error != null) CustomToast.showError(context, error);
                              else CustomToast.showSuccess(context, 'Cliente removido com sucesso!');
                            }
                          }
                        },
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
            
            PrimaryButton(
              text: 'Novo cliente',
              icon: const FaIcon(FontAwesomeIcons.circlePlus, color: Colors.white, size: 18),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ClientesFormPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}