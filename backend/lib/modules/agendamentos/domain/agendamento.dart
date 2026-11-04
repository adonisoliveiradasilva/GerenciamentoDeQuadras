class Agendamento {
  final int id;
  final int quadraId;
  final int clienteId;
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
    required this.dataInicio,
    required this.dataFim,
    required this.status,
    required this.valorTotal,
    required this.criadoEm,
    required this.atualizadoEm,
  });
}