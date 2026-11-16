import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/models/agendamento_model.dart';
import '../../../core/services/agendamentos_service.dart';

class EmployeeAgendamentosController extends ChangeNotifier {
  final AgendamentosService _service = AgendamentosService();
  final bool apenasHoje;

  List<AgendamentoModel> agendamentos = [];
  String searchQuery = '';
  int currentPage = 1;
  int itemsPerPage = 5;
  int totalPages = 1;
  bool isLoading = false;
  String? errorMessage;

  Timer? _debounce;

  EmployeeAgendamentosController({this.apenasHoje = false}) {
    carregarAgendamentos();
  }

  Future<void> carregarAgendamentos() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final resultado = await _service.listarAgendamentos(
        pagina: currentPage,
        tamanho: itemsPerPage,
        escopo: apenasHoje ? 'hoje' : 'todos',
        busca: searchQuery,
      );

      agendamentos = resultado.itens;
      totalPages = resultado.totalPaginas;
      if (currentPage > totalPages) {
        currentPage = totalPages;
      }
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
      agendamentos = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void pesquisar(String query) {
    searchQuery = query;
    currentPage = 1;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      carregarAgendamentos();
    });
  }

  void alterarItensPorPagina(int qtd) {
    itemsPerPage = qtd;
    currentPage = 1;
    carregarAgendamentos();
  }

  void proximaPagina() {
    if (currentPage < totalPages) {
      currentPage++;
      carregarAgendamentos();
    }
  }

  void paginaAnterior() {
    if (currentPage > 1) {
      currentPage--;
      carregarAgendamentos();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
