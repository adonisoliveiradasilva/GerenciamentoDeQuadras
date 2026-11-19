import 'relatorio_geral.dart';

abstract class RelatorioRepositorio {
  Future<RelatorioGeral> gerarRelatorio({
    required DateTime inicio,
    required DateTime fim,
    int? quadraId,
  });
}