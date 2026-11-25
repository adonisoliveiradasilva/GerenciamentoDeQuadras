import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/services/agendamentos_service.dart';

class RelatoriosController extends ChangeNotifier {
  final AgendamentosService _service = AgendamentosService();

  DateTimeRange? periodoSelecionado;
  bool isLoading = false;
  String? errorMessage;

  Map<String, double> quadrasUsadas = {};
  Map<String, double> clientesFrequentes = {};
  Map<String, double> diasMovimentados = {};

  RelatoriosController() {
    carregarDadosDaApi();
  }

  String get periodoFormatado {
    if (periodoSelecionado == null) return 'Todo o período';
    final format = DateFormat('dd/MM/yyyy');
    return '${format.format(periodoSelecionado!.start)} - ${format.format(periodoSelecionado!.end)}';
  }

  Future<void> selecionarPeriodo(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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
      carregarDadosDaApi();
    }
  }

  Future<void> carregarDadosDaApi() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final metricas = await _service.obterRelatorios(
        inicio: periodoSelecionado?.start,
        fim: periodoSelecionado?.end,
      );

      quadrasUsadas = metricas.quadrasUsadas;
      clientesFrequentes = metricas.clientesFrequentes;
      diasMovimentados = metricas.diasMovimentados;
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
