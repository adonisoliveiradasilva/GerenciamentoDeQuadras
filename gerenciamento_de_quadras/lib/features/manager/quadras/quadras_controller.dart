import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/models/quadra_model.dart';
import '../../../core/services/quadras_service.dart';

class QuadrasController extends ChangeNotifier {
  final QuadrasService _service = QuadrasService();

  List<QuadraModel> quadras = [];
  String searchQuery = '';
  int currentPage = 1;
  int itemsPerPage = 10;
  int totalPages = 1;
  bool isLoading = false;
  String? errorMessage;

  Timer? _debounce;

  QuadrasController() {
    carregarQuadras();
  }

  Future<void> carregarQuadras() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final resultado = await _service.listarQuadras(
        pagina: currentPage,
        tamanho: itemsPerPage,
        busca: searchQuery,
      );

      quadras = resultado.itens;
      totalPages = resultado.totalPaginas;
      if (currentPage > totalPages) {
        currentPage = totalPages;
      }
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
      quadras = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> deletarQuadra(int id) async {
    isLoading = true;
    notifyListeners();

    try {
      await _service.deletarQuadra(id);
      if (quadras.length == 1 && currentPage > 1) {
        currentPage--;
      }
      await carregarQuadras();
      return null;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  void pesquisar(String query) {
    searchQuery = query;
    currentPage = 1;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      carregarQuadras();
    });
  }

  void alterarItensPorPagina(int qtd) {
    itemsPerPage = qtd;
    currentPage = 1;
    carregarQuadras();
  }

  void proximaPagina() {
    if (currentPage < totalPages) {
      currentPage++;
      carregarQuadras();
    }
  }

  void paginaAnterior() {
    if (currentPage > 1) {
      currentPage--;
      carregarQuadras();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
