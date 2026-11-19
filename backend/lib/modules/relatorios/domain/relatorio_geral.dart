class VolumeAgendamentos {
  final int total;
  final int pendentes;
  final int realizados;
  final int cancelados;

  const VolumeAgendamentos({
    required this.total,
    required this.pendentes,
    required this.realizados,
    required this.cancelados,
  });

  Map<String, Object?> paraJson() => {
        'total': total,
        'pendentes': pendentes,
        'realizados': realizados,
        'cancelados': cancelados,
      };
}

class MetricaFaturamento {
  final double realizado; // status == realizado
  final double previsto;  // status == pendente
  final double total;     // realizado + previsto (exclui cancelados)

  const MetricaFaturamento({
    required this.realizado,
    required this.previsto,
    required this.total,
  });

  Map<String, Object?> paraJson() => {
        'realizado': realizado,
        'previsto': previsto,
        'total': total,
      };
}

class HorarioBuscado {
  final String horario; // ex: "19:00"
  final int quantidade;

  const HorarioBuscado({
    required this.horario,
    required this.quantidade,
  });

  Map<String, Object?> paraJson() => {
        'horario': horario,
        'quantidade': quantidade,
      };
}

class RelatorioGeral {
  final DateTime inicio;
  final DateTime fim;
  final VolumeAgendamentos volume;
  final MetricaFaturamento faturamento;
  final List<HorarioBuscado> horariosMaisBuscados;

  const RelatorioGeral({
    required this.inicio,
    required this.fim,
    required this.volume,
    required this.faturamento,
    required this.horariosMaisBuscados,
  });

  Map<String, Object?> paraJson() => {
        'periodo': {
          'inicio': inicio.toIso8601String(),
          'fim': fim.toIso8601String(),
        },
        'volume': volume.paraJson(),
        'faturamento': faturamento.paraJson(),
        'horariosMaisBuscados':
            horariosMaisBuscados.map((h) => h.paraJson()).toList(),
      };
}