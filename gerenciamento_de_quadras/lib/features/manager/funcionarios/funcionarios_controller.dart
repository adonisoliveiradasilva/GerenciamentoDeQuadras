import 'package:flutter/material.dart';

class FuncionariosController extends ChangeNotifier {
  final List<String> _mockBancoDeDados = List.generate(25, (index) => 'Funcionário ${index + 1}');

  List<String> funcionariosFiltrados = [];
  String searchQuery = '';
  int currentPage = 1;
  int itemsPerPage = 10;
  bool isLoading = false;

  FuncionariosController() {
    funcionariosFiltrados = _mockBancoDeDados;
  }

  List<String> get funcionariosPaginados {
    int startIndex = (currentPage - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    if (startIndex >= funcionariosFiltrados.length) return [];
    if (endIndex > funcionariosFiltrados.length) endIndex = funcionariosFiltrados.length;
    return funcionariosFiltrados.sublist(startIndex, endIndex);
  }

  int get totalPages => (funcionariosFiltrados.length / itemsPerPage).ceil();

  void pesquisar(String query) {
    searchQuery = query;
    currentPage = 1;
    if (query.isEmpty) {
      funcionariosFiltrados = _mockBancoDeDados;
    } else {
      funcionariosFiltrados = _mockBancoDeDados
          .where((f) => f.toLowerCase().contains(query.toLowerCase()))
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

  Future<String?> deletarFuncionario(String funcionarioName) async {
    isLoading = true;
    notifyListeners();
    try {
      await Future.delayed(const Duration(seconds: 1));
      _mockBancoDeDados.remove(funcionarioName);
      pesquisar(searchQuery); 
      isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return "Erro ao remover o funcionário. Tente novamente.";
    }
  }
}