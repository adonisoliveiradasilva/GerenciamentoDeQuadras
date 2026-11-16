class Agendamento {
  final int id;
  final int quadraId;
  final int clienteId;
  final String? quadraNome;
  final String? clienteNome;
  final DateTime dataInicio;
  final DateTime dataFim;
  final String status;
  final double valorTotal;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  Agendamento({
    required this.id,
    required this.quadraId,
    required this.clienteId,
    this.quadraNome,
    this.clienteNome,
    required this.dataInicio,
    required this.dataFim,
    required this.status,
    required this.valorTotal,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'quadraId': quadraId,
    'quadraNome': quadraNome ?? 'Quadra #$quadraId',
    'clienteId': clienteId,
    'clienteNome': clienteNome ?? 'Cliente #$clienteId',
    'dataInicio': dataInicio.toIso8601String(),
    'dataFim': dataFim.toIso8601String(),
    'status': status,
    'valorTotal': valorTotal,
  };
}
