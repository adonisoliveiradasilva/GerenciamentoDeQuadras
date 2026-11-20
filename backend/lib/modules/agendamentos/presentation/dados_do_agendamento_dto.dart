import '../../../core/http/requisicao.dart';

class DadosDoAgendamentoDto {
  final int quadraId;
  final DateTime dataInicio;
  final DateTime dataFim;

  DadosDoAgendamentoDto({
    required this.quadraId,
    required this.dataInicio,
    required this.dataFim,
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

    return DadosDoAgendamentoDto(
      quadraId: quadraId!,
      dataInicio: dataInicio!,
      dataFim: dataFim!,
    );
  }
}