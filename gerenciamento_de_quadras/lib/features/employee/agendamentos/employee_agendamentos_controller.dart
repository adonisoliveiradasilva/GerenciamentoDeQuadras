import 'package:flutter/material.dart';

class FuncionarioAgendamentoDto {
  final String id;
  final String data; 
  final String horario; 
  final String cliente;
  final String quadra;
  final DateTime dateObj; 

  FuncionarioAgendamentoDto({
    required this.id, required this.data, required this.horario, 
    required this.cliente, required this.quadra, required this.dateObj
  });

  String get descricaoCompleta => '$horario: $cliente - $quadra'; 
}

class EmployeeAgendamentosController extends ChangeNotifier {
  final bool apenasHoje;
  late List<FuncionarioAgendamentoDto> _mockBancoDeDados;

  List<FuncionarioAgendamentoDto> agendamentosFiltrados = [];
  String searchQuery = '';
  int currentPage = 1;
  int itemsPerPage = 5; 

  EmployeeAgendamentosController({this.apenasHoje = false}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final mockCompleto = List.generate(45, (index) {
      int diasOffset;
      
      if (index < 8) {
        diasOffset = 0;
      } else if (index < 18) {
        diasOffset = -((index % 5) + 1);
      } else {
        diasOffset = (index % 20) + 1;
      }

      final dt = today.add(Duration(days: diasOffset));
      final isToday = dt.isAtSameMomentAs(today);
      final dateStr = isToday ? 'Hoje' : '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
      
      final horaInicio = 8 + (index % 12); 
      final horarioStr = '${horaInicio.toString().padLeft(2, '0')}:00 - ${(horaInicio + 1).toString().padLeft(2, '0')}:00';

      return FuncionarioAgendamentoDto(
        id: index.toString(),
        data: dateStr,
        horario: horarioStr,
        cliente: 'Cliente ${(index % 15) + 1}',
        quadra: 'Quadra ${(index % 3) + 1}',
        dateObj: dt,
      );
    });

    mockCompleto.sort((a, b) => a.dateObj.compareTo(b.dateObj));

    _mockBancoDeDados = mockCompleto.where((a) {
      if (apenasHoje) return a.dateObj.isAtSameMomentAs(today);
      return true;
    }).toList();

    agendamentosFiltrados = _mockBancoDeDados;
  }

  List<FuncionarioAgendamentoDto> get agendamentosPaginados {
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
      agendamentosFiltrados = _mockBancoDeDados.where((a) => 
        a.cliente.toLowerCase().contains(query.toLowerCase()) || 
        a.quadra.toLowerCase().contains(query.toLowerCase()) ||
        a.data.contains(query)
      ).toList();
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