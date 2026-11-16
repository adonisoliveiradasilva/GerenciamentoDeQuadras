import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/models/usuario_model.dart';
import '../../../core/services/usuarios_service.dart';

class ClientesController extends ChangeNotifier {
  final UsuariosService _service = UsuariosService();

  List<UsuarioModel> clientes = [];
  String searchQuery = '';
  int currentPage = 1;
  int itemsPerPage = 10;
  int totalPages = 1;
  bool isLoading = false;
  String? errorMessage;

  Timer? _debounce;

  ClientesController() {
    carregarClientes();
  }

  Future<void> carregarClientes() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final resultado = await _service.listarClientes(
        pagina: currentPage,
        tamanho: itemsPerPage,
        busca: searchQuery,
      );

      clientes = resultado.itens;
      totalPages = resultado.totalPaginas;
      if (currentPage > totalPages) {
        currentPage = totalPages;
      }
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
      clientes = [];
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
      carregarClientes();
    });
  }

  void alterarItensPorPagina(int qtd) {
    itemsPerPage = qtd;
    currentPage = 1;
    carregarClientes();
  }

  void proximaPagina() {
    if (currentPage < totalPages) {
      currentPage++;
      carregarClientes();
    }
  }

  void paginaAnterior() {
    if (currentPage > 1) {
      currentPage--;
      carregarClientes();
    }
  }

  Future<String?> deletarCliente(int id) async {
    isLoading = true;
    notifyListeners();

    try {
      await _service.deletarCliente(id);
      if (clientes.length == 1 && currentPage > 1) {
        currentPage--;
      }
      await carregarClientes();
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
