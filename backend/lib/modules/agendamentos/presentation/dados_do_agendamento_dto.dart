import '../../../core/http/requisicao.dart';

class DadosDoAgendamentoDto {
  final int quadraId;
  final DateTime dataInicio;
  final DateTime dataFim;
  final double valorTotal;

  DadosDoAgendamentoDto({
    required this.quadraId,
    required this.dataInicio,
    required this.dataFim,
    this.valorTotal = 0.0,
  });

  factory DadosDoAgendamentoDto.deJson(Map<String, Object?> json) {
    final leitor = LeitorDeCampos(json);

    final quadraId = leitor.inteiro('quadraId', minimo: 1);
    final dataInicioStr = leitor.texto('dataInicio');
    final dataFimStr = leitor.texto('dataFim');

    DateTime? dataInicio;
    if (dataInicioStr != null) {
      dataInicio = DateTime.tryParse(dataInicioStr);
      if (dataInicio == null) {
        leitor.adicionarErro(
          'dataInicio',
          'Use uma data e hora válida no formato ISO 8601.',
        );
      }
    }

    DateTime? dataFim;
    if (dataFimStr != null) {
      dataFim = DateTime.tryParse(dataFimStr);
      if (dataFim == null) {
        leitor.adicionarErro(
          'dataFim',
          'Use uma data e hora válida no formato ISO 8601.',
        );
      }
    }

    leitor.validar();

    final rawValor = json['valorTotal'];
    final valorTotal = rawValor is num ? rawValor.toDouble() : 0.0;

    return DadosDoAgendamentoDto(
      quadraId: quadraId!,
      dataInicio: dataInicio!,
      dataFim: dataFim!,
      valorTotal: valorTotal,
    );
  }
}
