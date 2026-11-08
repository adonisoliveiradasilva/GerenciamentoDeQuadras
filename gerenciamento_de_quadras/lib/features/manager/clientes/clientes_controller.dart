import 'package:flutter/material.dart';

class ClientesController extends ChangeNotifier {
  final List<String> _mockBancoDeDados = List.generate(25, (index) => 'Cliente ${index + 1}');

  List<String> clientesFiltrados = [];
  String searchQuery = '';
  int currentPage = 1;
  int itemsPerPage = 10;
  bool isLoading = false;

  ClientesController() {
    clientesFiltrados = _mockBancoDeDados;
  }

  List<String> get clientesPaginados {
    int startIndex = (currentPage - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    if (startIndex >= clientesFiltrados.length) return [];
    if (endIndex > clientesFiltrados.length) endIndex = clientesFiltrados.length;
    return clientesFiltrados.sublist(startIndex, endIndex);
  }

  int get totalPages => (clientesFiltrados.length / itemsPerPage).ceil();

  void pesquisar(String query) {
    searchQuery = query;
    currentPage = 1;
    if (query.isEmpty) {
      clientesFiltrados = _mockBancoDeDados;
    } else {
      clientesFiltrados = _mockBancoDeDados
          .where((c) => c.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void alterarItensPorPagina(int qtd) {
    itemsPerPage = qtd;
    currentPage = 1;
    notifyListeners();
  }

  void proximaPagina() {
    if (currentPage < totalPages) {
      currentPage++;
      notifyListeners();
    }
  }

  void paginaAnterior() {
    if (currentPage > 1) {
      currentPage--;
      notifyListeners();
    }
  }

  Future<String?> deletarCliente(String clienteName) async {
    isLoading = true;
    notifyListeners();
    try {
      await Future.delayed(const Duration(seconds: 1));
      _mockBancoDeDados.remove(clienteName);
      pesquisar(searchQuery); 
      isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return "Erro ao remover o cliente. Tente novamente.";
    }
  }
}