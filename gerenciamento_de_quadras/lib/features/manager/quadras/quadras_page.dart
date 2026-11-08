import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/widgets/atoms/search_input.dart';
import '../../../../core/widgets/atoms/pagination_controls.dart';
import '../../../../core/widgets/molecules/action_list_card.dart';
import '../../../../core/widgets/atoms/primary_button.dart';
import '../../../../core/widgets/molecules/delete_confirmation_modal.dart';
import '../../../../core/widgets/atoms/custom_toast.dart';
import 'quadras_controller.dart';
import 'quadras_form_page.dart';

class QuadrasPage extends StatefulWidget {
  const QuadrasPage({super.key});

  @override
  State<QuadrasPage> createState() => _QuadrasPageState();
}

class _QuadrasPageState extends State<QuadrasPage> {
  final QuadrasController _controller = QuadrasController();

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
            const Text(
              'Quadras',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0D253F)),
            ),
            const Text(
              'Gerencie suas quadras',
              style: TextStyle(color: Colors.blueGrey, fontSize: 14),
            ),
            const SizedBox(height: 24),
            
            SearchInput(
              hintText: 'Pesquisar',
              onChanged: _controller.pesquisar, 
            ),
            const SizedBox(height: 24),

            Expanded(
              child: ListenableBuilder(
                listenable: _controller,
                builder: (context, child) {
                  final lista = _controller.quadrasPaginadas;

                  if (lista.isEmpty) {
                    return const Center(child: Text("Nenhuma quadra encontrada.", style: TextStyle(color: Colors.grey)));
                  }

                  return ListView.builder(
                    itemCount: lista.length,
                    itemBuilder: (context, index) {
                      return ActionListCard(
                        title: lista[index],
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => QuadrasFormPage(quadraName: lista[index])),
                          );
                        },
                        onDelete: () async {
                          final confirmou = await showDialog<bool>(
                            context: context,
                            builder: (context) => DeleteConfirmationModal(
                              title: 'Quadras',
                              subtitle: 'Remover quadra',
                              itemName: lista[index],
                            ),
                          );

                          if (confirmou == true && context.mounted) {
                            final error = await _controller.deletarQuadra(lista[index]);
                            
                            if (context.mounted) {
                              if (error != null) {
                                CustomToast.showError(context, error);
                              } else {
                                CustomToast.showSuccess(context, 'Quadra removida com sucesso!');
                              }
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
                  onItemsPerPageChanged: (newValue) {
                    if (newValue != null) _controller.alterarItensPorPagina(newValue);
                  },
                  onPrevious: _controller.paginaAnterior,
                  onNext: _controller.proximaPagina,
                );
              }
            ),
            
            const SizedBox(height: 16),
            
            PrimaryButton(
              text: 'Nova quadra',
              icon: const FaIcon(FontAwesomeIcons.circlePlus, color: Colors.white, size: 18),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QuadrasFormPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}