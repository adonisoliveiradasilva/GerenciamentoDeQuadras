import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/widgets/atoms/search_input.dart';
import '../../../../core/widgets/atoms/pagination_controls.dart';
import '../../../../core/widgets/molecules/action_list_card.dart';
import '../../../../core/widgets/atoms/primary_button.dart';
import '../../../../core/widgets/molecules/delete_confirmation_modal.dart';
import '../../../../core/widgets/atoms/custom_toast.dart';
import 'funcionarios_controller.dart';
import 'funcionarios_form_page.dart';

class FuncionariosPage extends StatefulWidget {
  const FuncionariosPage({super.key});

  @override
  State<FuncionariosPage> createState() => _FuncionariosPageState();
}

class _FuncionariosPageState extends State<FuncionariosPage> {
  final FuncionariosController _controller = FuncionariosController();

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
            const Text('Funcionários', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0D253F))),
            const Text('Gerencie os funcionários', style: TextStyle(color: Colors.blueGrey, fontSize: 14)),
            const SizedBox(height: 24),
            
            SearchInput(hintText: 'Pesquisar', onChanged: _controller.pesquisar),
            const SizedBox(height: 24),

            Expanded(
              child: ListenableBuilder(
                listenable: _controller,
                builder: (context, child) {
                  final lista = _controller.funcionariosPaginados;
                  if (lista.isEmpty) return const Center(child: Text("Nenhum funcionário encontrado.", style: TextStyle(color: Colors.grey)));

                  return ListView.builder(
                    itemCount: lista.length,
                    itemBuilder: (context, index) {
                      return ActionListCard(
                        title: lista[index],
                        onEdit: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => FuncionariosFormPage(funcionarioName: lista[index])));
                        },
                        onDelete: () async {
                          final confirmou = await showDialog<bool>(
                            context: context,
                            builder: (context) => DeleteConfirmationModal(
                              title: 'Funcionários',
                              subtitle: 'Remover funcionário',
                              itemName: lista[index],
                            ),
                          );

                          if (confirmou == true && context.mounted) {
                            final error = await _controller.deletarFuncionario(lista[index]);
                            if (context.mounted) {
                              if (error != null) CustomToast.showError(context, error);
                              else CustomToast.showSuccess(context, 'Funcionário removido com sucesso!');
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
              text: 'Criar funcionário',
              icon: const FaIcon(FontAwesomeIcons.circlePlus, color: Colors.white, size: 18),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FuncionariosFormPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}