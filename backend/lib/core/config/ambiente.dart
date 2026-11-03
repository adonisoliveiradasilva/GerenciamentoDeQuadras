import 'dart:io';

import 'package:dotenv/dotenv.dart';

class Ambiente {
  Ambiente._(this._buscar);

  factory Ambiente.carregar() {
    final arquivos = [
      for (final caminho in ['../.env', '.env'])
        if (File(caminho).existsSync()) caminho,
    ];
    final arquivoEnv = DotEnv(quiet: true)..load(arquivos);
    return Ambiente._((chave) {
      final doSistema = Platform.environment[chave];
      return doSistema == null || doSistema.isEmpty
          ? arquivoEnv[chave]
          : doSistema;
    });
  }

  factory Ambiente.deMapa(Map<String, String> valores) {
    final copia = Map.of(valores);
    return Ambiente._((chave) => copia[chave]);
  }

  static Ambiente? _atual;

  static Ambiente get atual => _atual ??= Ambiente.carregar();

  final String? Function(String chave) _buscar;

  String? opcional(String chave) {
    final valor = _buscar(chave)?.trim();
    return valor == null || valor.isEmpty ? null : valor;
  }

  String obrigatorio(String chave) =>
      opcional(chave) ??
      (throw StateError('Variável de ambiente $chave não configurada.'));

  int inteiro(String chave, {required int padrao}) {
    final valor = opcional(chave);
    if (valor == null) return padrao;
    return int.tryParse(valor) ??
        (throw StateError('Variável de ambiente $chave deve ser um número.'));
  }

  bool booleano(String chave, {required bool padrao}) {
    final valor = opcional(chave)?.toLowerCase();
    return switch (valor) {
      null => padrao,
      'true' || '1' || 'sim' => true,
      'false' || '0' || 'nao' || 'não' => false,
      _ => throw StateError(
        'Variável de ambiente $chave deve ser true ou false.',
      ),
    };
  }

  Uri get urlPublica {
    final valor = opcional('URL_PUBLICA') ?? 'http://localhost:$porta';
    return Uri.tryParse(valor.replaceAll(RegExp(r'/+$'), '')) ??
        (throw StateError('URL_PUBLICA não é uma URL válida.'));
  }

  Uri get urlBanco {
    final valor = obrigatorio('DATABASE_URL');
    return Uri.tryParse(valor) ??
        (throw StateError('DATABASE_URL não é uma URL válida.'));
  }

  int get porta => inteiro('PORTA', padrao: 8080);
}
