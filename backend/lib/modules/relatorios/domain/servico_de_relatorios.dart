import '../../../core/http/erros.dart';
import 'relatorio_geral.dart';
import 'relatorio_repositorio.dart';

class ServicoDeRelatorios {
  final RelatorioRepositorio _repositorio;

  ServicoDeRelatorios(this._repositorio);

  Future<RelatorioGeral> gerarRelatorio({
    DateTime? inicio,
    DateTime? fim,
    int? quadraId,
  }) async {
    final agora = DateTime.now();
    final dataFim = fim ?? DateTime(agora.year, agora.month, agora.day, 23, 59, 59);
    final dataInicio = inicio ??
        DateTime(agora.year, agora.month, agora.day)
            .subtract(const Duration(days: 30));

    if (dataInicio.isAfter(dataFim)) {
      throw const ErroValidacao(
        'A data de início deve ser anterior ou igual à data de fim.',
        codigo: 'PERIODO_INVALIDO',
      );
    }

    return _repositorio.gerarRelatorio(
      inicio: dataInicio,
      fim: dataFim,
      quadraId: quadraId,
    );
  }
}