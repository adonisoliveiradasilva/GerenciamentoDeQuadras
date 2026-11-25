import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/models/agendamento_model.dart';
import '../../../core/services/agendamentos_service.dart';

class AgendamentosController extends ChangeNotifier {
  final AgendamentosService _service = AgendamentosService();
  final bool isHistory;

  List<AgendamentoModel> agendamentos = [];
  String searchQuery = '';
  int currentPage = 1;
  int itemsPerPage = 5;
  int totalPages = 1;
  bool isLoading = false;
  String? errorMessage;

  Timer? _debounce;

  AgendamentosController({this.isHistory = false}) {
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
        escopo: isHistory ? 'historico' : 'futuros',
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

  Future<String?> cancelarAgendamento(int id) async {
    isLoading = true;
    notifyListeners();

    try {
      await _service.cancelarAgendamento(id);
      if (agendamentos.length == 1 && currentPage > 1) {
        currentPage--;
      }
      await carregarAgendamentos();
      return null;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
