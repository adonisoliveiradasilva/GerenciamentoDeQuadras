import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/models/usuario_model.dart';
import '../../../core/services/usuarios_service.dart';

class FuncionariosController extends ChangeNotifier {
  final UsuariosService _service = UsuariosService();

  List<UsuarioModel> funcionarios = [];
  String searchQuery = '';
  int currentPage = 1;
  int itemsPerPage = 10;
  int totalPages = 1;
  bool isLoading = false;
  String? errorMessage;

  Timer? _debounce;

  FuncionariosController() {
    carregarFuncionarios();
  }

  Future<void> carregarFuncionarios() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final resultado = await _service.listarFuncionarios(
        pagina: currentPage,
        tamanho: itemsPerPage,
        busca: searchQuery,
      );

      funcionarios = resultado.itens;
      totalPages = resultado.totalPaginas;
      if (currentPage > totalPages) {
        currentPage = totalPages;
      }
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
      funcionarios = [];
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
      carregarFuncionarios();
    });
  }

  void alterarItensPorPagina(int qtd) {
    itemsPerPage = qtd;
    currentPage = 1;
    carregarFuncionarios();
  }

  void proximaPagina() {
    if (currentPage < totalPages) {
      currentPage++;
      carregarFuncionarios();
    }
  }

  void paginaAnterior() {
    if (currentPage > 1) {
      currentPage--;
      carregarFuncionarios();
    }
  }

  Future<String?> deletarFuncionario(int id) async {
    isLoading = true;
    notifyListeners();

    try {
      await _service.deletarFuncionario(id);
      if (funcionarios.length == 1 && currentPage > 1) {
        currentPage--;
      }
      await carregarFuncionarios();
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
