import 'package:flutter/material.dart';

class QuadrasController extends ChangeNotifier {
  final List<String> _mockBancoDeDados = List.generate(25, (index) => 'Quadra ${index + 1}');

  List<String> quadrasFiltradas = [];
  String searchQuery = '';
  int currentPage = 1;
  int itemsPerPage = 10;
  bool isLoading = false;

  QuadrasController() {
    quadrasFiltradas = _mockBancoDeDados;
  }

  List<String> get quadrasPaginadas {
    int startIndex = (currentPage - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    
    if (startIndex >= quadrasFiltradas.length) return [];
    if (endIndex > quadrasFiltradas.length) endIndex = quadrasFiltradas.length;
    
    return quadrasFiltradas.sublist(startIndex, endIndex);
  }

  Future<String?> deletarQuadra(String quadraName) async {
    isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      // await httpClient.delete('/api/quadras/${id}');
      
      _mockBancoDeDados.remove(quadraName);
      pesquisar(searchQuery); 
      
      isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return "Erro ao remover a quadra. Tente novamente.";
    }
  }

  int get totalPages => (quadrasFiltradas.length / itemsPerPage).ceil();

  
  void pesquisar(String query) {
    searchQuery = query;
    currentPage = 1;

    if (query.isEmpty) {
      quadrasFiltradas = _mockBancoDeDados;
    } else {
      quadrasFiltradas = _mockBancoDeDados
          .where((q) => q.toLowerCase().contains(query.toLowerCase()))
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
}