class DadosDoAgendamentoDto {
  final int quadraId;
  final int clienteId; 
  final DateTime dataInicio;
  final DateTime dataFim;
  final double valorTotal;

  DadosDoAgendamentoDto({
    required this.quadraId,
    required this.clienteId,
    required this.dataInicio,
    required this.dataFim,
    required this.valorTotal,
  });

  factory DadosDoAgendamentoDto.fromJson(Map<String, dynamic> json) {
    return DadosDoAgendamentoDto(
      quadraId: json['quadraId'] as int,
      clienteId: json['clienteId'] as int,
      dataInicio: DateTime.parse(json['dataInicio'] as String),
      dataFim: DateTime.parse(json['dataFim'] as String),
      valorTotal: (json['valorTotal'] as num).toDouble(),
    );
  }
}