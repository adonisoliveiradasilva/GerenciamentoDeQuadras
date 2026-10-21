import 'hora_do_dia.dart';

class IntervaloDeFuncionamento {
  const IntervaloDeFuncionamento({
    required this.diaSemana,
    required this.inicio,
    required this.fim,
  });

  static const segunda = 1;
  static const domingo = 7;

  final int diaSemana;
  final HoraDoDia inicio;
  final HoraDoDia fim;

  int get duracaoEmMinutos => fim - inicio;

  bool sobrepoe(IntervaloDeFuncionamento outro) =>
      diaSemana == outro.diaSemana && inicio < outro.fim && outro.inicio < fim;

  static int ordenar(IntervaloDeFuncionamento a, IntervaloDeFuncionamento b) {
    final porDia = a.diaSemana.compareTo(b.diaSemana);
    return porDia != 0 ? porDia : a.inicio.compareTo(b.inicio);
  }
}

class Quadra {
  const Quadra({
    required this.id,
    required this.nome,
    required this.localizacao,
    required this.duracaoSessaoMin,
    required this.horarios,
    required this.criadoEm,
    required this.atualizadoEm,
    this.descricao,
  });

  final int id;
  final String nome;
  final String localizacao;
  final String? descricao;
  final int duracaoSessaoMin;
  final List<IntervaloDeFuncionamento> horarios;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
}

class DadosDaQuadra {
  const DadosDaQuadra({
    required this.nome,
    required this.localizacao,
    required this.duracaoSessaoMin,
    required this.horarios,
    this.descricao,
  });

  final String nome;
  final String localizacao;
  final String? descricao;
  final int duracaoSessaoMin;
  final List<IntervaloDeFuncionamento> horarios;
}
