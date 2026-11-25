import 'package:orm/orm.dart';
import '../../../schema.orm.dart';
import '../domain/relatorio_geral.dart';
import '../domain/relatorio_repositorio.dart';

class RelatorioRepositorioORM implements RelatorioRepositorio {
  final QueryContext db;

  RelatorioRepositorioORM(this.db);

  @override
  Future<RelatorioGeral> gerarRelatorio({
    required DateTime inicio,
    required DateTime fim,
    int? quadraId,
  }) async {
    var consulta = db.agendamento
        .where((row) => row.dataInicio.gte(inicio))
        .where((row) => row.dataInicio.lte(fim));

    if (quadraId != null) {
      consulta = consulta.where((row) => row.quadraId.eq(quadraId));
    }

    final agendamentos = await consulta.get();

    var pendentes = 0;
    var realizados = 0;
    var cancelados = 0;

    var faturamentoRealizado = 0.0;
    var faturamentoPrevisto = 0.0;

    final contagemPorHorario = <String, int>{};

    for (final ag in agendamentos) {
      final valor = (ag.valorTotal as num).toDouble();

      switch (ag.status) {
        case 'realizado':
          realizados++;
          faturamentoRealizado += valor;
          break;
        case 'pendente':
          pendentes++;
          faturamentoPrevisto += valor;
          break;
        case 'cancelado':
          cancelados++;
          break;
      }

      if (ag.status != 'cancelado') {
        final hora = ag.dataInicio.hour.toString().padLeft(2, '0');
        final minuto = ag.dataInicio.minute.toString().padLeft(2, '0');
        final chave = '$hora:$minuto';
        contagemPorHorario[chave] = (contagemPorHorario[chave] ?? 0) + 1;
      }
    }

    final horariosMaisBuscados = contagemPorHorario.entries
        .map((e) => HorarioBuscado(horario: e.key, quantidade: e.value))
        .toList()
      ..sort((a, b) {
        final porQtd = b.quantidade.compareTo(a.quantidade);
        return porQtd != 0 ? porQtd : a.horario.compareTo(b.horario);
      });

    double arredondar(double v) => double.parse(v.toStringAsFixed(2));

    final realizadoFinal = arredondar(faturamentoRealizado);
    final previstoFinal = arredondar(faturamentoPrevisto);

    return RelatorioGeral(
      inicio: inicio,
      fim: fim,
      volume: VolumeAgendamentos(
        total: agendamentos.length,
        pendentes: pendentes,
        realizados: realizados,
        cancelados: cancelados,
      ),
      faturamento: MetricaFaturamento(
        realizado: realizadoFinal,
        previsto: previstoFinal,
        total: arredondar(realizadoFinal + previstoFinal),
      ),
      horariosMaisBuscados: horariosMaisBuscados,
    );
  }
}