import 'package:flutter/material.dart';

class IntervaloFuncionamentoModel {
  final int diaSemana; // 1 (Segunda) a 7 (Domingo)
  final String inicio; // HH:MM
  final String fim; // HH:MM

  const IntervaloFuncionamentoModel({
    required this.diaSemana,
    required this.inicio,
    required this.fim,
  });

  factory IntervaloFuncionamentoModel.fromJson(Map<String, dynamic> json) {
    return IntervaloFuncionamentoModel(
      diaSemana: json['diaSemana'] as int,
      inicio: json['inicio'] as String,
      fim: json['fim'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'diaSemana': diaSemana,
    'inicio': inicio,
    'fim': fim,
  };

  static TimeOfDay parseTimeOfDay(String hhmm) {
    final partes = hhmm.split(':');
    final hora = int.tryParse(partes[0]) ?? 8;
    final minuto = partes.length > 1 ? (int.tryParse(partes[1]) ?? 0) : 0;
    return TimeOfDay(hour: hora, minute: minuto);
  }

  static String formatTimeOfDay(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class QuadraModel {
  final int id;
  final String nome;
  final String localizacao;
  final String? descricao;
  final int duracaoSessaoMin;
  final List<IntervaloFuncionamentoModel> horarios;

  const QuadraModel({
    required this.id,
    required this.nome,
    required this.localizacao,
    this.descricao,
    required this.duracaoSessaoMin,
    required this.horarios,
  });

  factory QuadraModel.fromJson(Map<String, dynamic> json) {
    final horariosJson = (json['horarios'] as List<dynamic>?) ?? [];
    return QuadraModel(
      id: json['id'] as int,
      nome: json['nome'] as String,
      localizacao: json['localizacao'] as String,
      descricao: json['descricao'] as String?,
      duracaoSessaoMin: json['duracaoSessaoMin'] as int,
      horarios: horariosJson
          .map(
            (e) =>
                IntervaloFuncionamentoModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
