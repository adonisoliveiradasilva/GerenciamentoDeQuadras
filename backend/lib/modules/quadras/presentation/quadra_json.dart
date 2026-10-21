import '../domain/quadra.dart';

extension QuadraJson on Quadra {
  Map<String, Object?> toJson() => {
    'id': id,
    'nome': nome,
    'localizacao': localizacao,
    'descricao': descricao,
    'duracaoSessaoMin': duracaoSessaoMin,
    'horarios': [
      for (final intervalo in horarios)
        {
          'diaSemana': intervalo.diaSemana,
          'inicio': '${intervalo.inicio}',
          'fim': '${intervalo.fim}',
        },
    ],
    'criadoEm': criadoEm.toUtc().toIso8601String(),
    'atualizadoEm': atualizadoEm.toUtc().toIso8601String(),
  };
}
