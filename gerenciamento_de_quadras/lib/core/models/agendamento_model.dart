class AgendamentoModel {
  final int id;
  final int quadraId;
  final String quadraNome;
  final int clienteId;
  final String clienteNome;
  final DateTime dataInicio;
  final DateTime dataFim;
  final String status;
  final double valorTotal;

  const AgendamentoModel({
    required this.id,
    required this.quadraId,
    required this.quadraNome,
    required this.clienteId,
    required this.clienteNome,
    required this.dataInicio,
    required this.dataFim,
    required this.status,
    required this.valorTotal,
  });

  factory AgendamentoModel.fromJson(Map<String, dynamic> json) {
    return AgendamentoModel(
      id: json['id'] as int,
      quadraId: json['quadraId'] as int,
      quadraNome: (json['quadraNome'] as String?) ?? 'Quadra',
      clienteId: json['clienteId'] as int,
      clienteNome: (json['clienteNome'] as String?) ?? 'Cliente',
      dataInicio: DateTime.parse(json['dataInicio'] as String).toLocal(),
      dataFim: DateTime.parse(json['dataFim'] as String).toLocal(),
      status: (json['status'] as String?) ?? 'pendente',
      valorTotal: (json['valorTotal'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get dataFormatada {
    final d = dataInicio.day.toString().padLeft(2, '0');
    final m = dataInicio.month.toString().padLeft(2, '0');
    return '$d/$m/${dataInicio.year}';
  }

  String get dataRelativa {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dt = DateTime(dataInicio.year, dataInicio.month, dataInicio.day);
    if (dt.isAtSameMomentAs(today)) return 'Hoje';
    return dataFormatada;
  }

  String get horaInicioFormatada {
    final h = dataInicio.hour.toString().padLeft(2, '0');
    final m = dataInicio.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get horaFimFormatada {
    final h = dataFim.hour.toString().padLeft(2, '0');
    final m = dataFim.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get intervaloHorario => '$horaInicioFormatada - $horaFimFormatada';

  String get descricaoCliente => '$intervaloHorario - $quadraNome';

  String get descricaoFuncionario =>
      '$intervaloHorario: $clienteNome\n$quadraNome';
}

class RelatorioMetricasModel {
  final Map<String, double> quadrasUsadas;
  final Map<String, double> clientesFrequentes;
  final Map<String, double> diasMovimentados;

  const RelatorioMetricasModel({
    required this.quadrasUsadas,
    required this.clientesFrequentes,
    required this.diasMovimentados,
  });

  factory RelatorioMetricasModel.fromJson(Map<String, dynamic> json) {
    Map<String, double> converter(dynamic raw) {
      if (raw is! Map) return {};
      return raw.map(
        (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
      );
    }

    return RelatorioMetricasModel(
      quadrasUsadas: converter(json['quadrasUsadas']),
      clientesFrequentes: converter(json['clientesFrequentes']),
      diasMovimentados: converter(json['diasMovimentados']),
    );
  }
}
