import 'package:flutter/material.dart';

class AgendamentoDto {
  final String id;
  final String data;
  final String descricao;

  AgendamentoDto({required this.id, required this.data, required this.descricao});
}

class AgendamentosController extends ChangeNotifier {
  final bool isHistory;
  late List<AgendamentoDto> _mockBancoDeDados;

  List<AgendamentoDto> agendamentosFiltrados = [];
  String searchQuery = '';
  int currentPage = 1;
  int itemsPerPage = 5; 
  bool isLoading = false;

  AgendamentosController({this.isHistory = false}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final mockCompleto = List.generate(15, (index) {
      final dt = today.add(Duration(days: index - 7));
      final dateStr = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
      return AgendamentoDto(id: index.toString(), data: dateStr, descricao: '08:00 - Quadra ${(index % 3) + 1}');
    });

    _mockBancoDeDados = mockCompleto.where((a) {
      final parts = a.data.split('/');
      final dt = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      
      if (isHistory) {
        return dt.isBefore(today);
      } else {
        return !dt.isBefore(today);
      }
    }).toList();

    agendamentosFiltrados = _mockBancoDeDados;
  }

  List<AgendamentoDto> get agendamentosPaginados {
    int startIndex = (currentPage - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    if (startIndex >= agendamentosFiltrados.length) return [];
    if (endIndex > agendamentosFiltrados.length) endIndex = agendamentosFiltrados.length;
    return agendamentosFiltrados.sublist(startIndex, endIndex);
  }

  int get totalPages => (agendamentosFiltrados.length / itemsPerPage).ceil();

  void pesquisar(String query) {
    searchQuery = query;
    currentPage = 1;
    if (query.isEmpty) {
      agendamentosFiltrados = _mockBancoDeDados;
    } else {
      agendamentosFiltrados = _mockBancoDeDados
          .where((a) => a.descricao.toLowerCase().contains(query.toLowerCase()) || 
                        a.data.contains(query))
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

  Future<String?> cancelarAgendamento(String id) async {
    isLoading = true;
    notifyListeners();
    try {
      await Future.delayed(const Duration(seconds: 1));
      _mockBancoDeDados.removeWhere((a) => a.id == id);
      pesquisar(searchQuery); 
      isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return "Erro ao cancelar agendamento.";
    }
  }
}