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

  Uri get urlBanco {
    final valor = obrigatorio('DATABASE_URL');
    return Uri.tryParse(valor) ??
        (throw StateError('DATABASE_URL não é uma URL válida.'));
  }

  int get porta => inteiro('PORTA', padrao: 8080);
}
