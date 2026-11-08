import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RelatoriosController extends ChangeNotifier {
  DateTimeRange? periodoSelecionado;
  bool isLoading = false;

  Map<String, double> quadrasUsadas = {'Quadra 1': 45, 'Quadra 2': 30, 'Quadra 3': 15, 'Quadra 4': 10};
  Map<String, double> clientesFrequentes = {'João': 12, 'Maria': 10, 'Carlos': 8, 'Ana': 5, 'Pedro': 4};
  Map<String, double> diasMovimentados = {'Seg': 20, 'Ter': 15, 'Qua': 25, 'Qui': 30, 'Sex': 50, 'Sáb': 60, 'Dom': 45};

  String get periodoFormatado {
    if (periodoSelecionado == null) return 'Selecionar período';
    final format = DateFormat('dd/MM/yyyy');
    return '${format.format(periodoSelecionado!.start)} - ${format.format(periodoSelecionado!.end)}';
  }

  Future<void> selecionarPeriodo(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: periodoSelecionado,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E65D0),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0D253F),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      periodoSelecionado = picked;
      _carregarDadosDaApi();
    }
  }

  Future<void> _carregarDadosDaApi() async {
    isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1)); // Mock da API
    
    // Aqui terá:
    // final response = await httpClient.get('/api/relatorios?start=${periodoSelecionado!.start}&end=${periodoSelecionado!.end}');
    // quadrasUsadas = response.data.quadras;
    // clientesFrequentes = response.data.clientes;
    // diasMovimentados = response.data.dias;

    isLoading = false;
    notifyListeners();
  }
}