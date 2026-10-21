import 'dart:io';

import 'package:shelf/shelf.dart';

import 'erros.dart';
import 'respostas.dart';

const _cabecalhosCors = {
  'access-control-allow-origin': '*',
  'access-control-allow-methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
  'access-control-allow-headers': 'Origin, Content-Type, Authorization',
};

Middleware cors() {
  return (Handler interno) {
    return (Request requisicao) async {
      if (requisicao.method == 'OPTIONS') {
        return Response.ok(null, headers: _cabecalhosCors);
      }
      final resposta = await interno(requisicao);
      return resposta.change(headers: _cabecalhosCors);
    };
  };
}

Middleware tratarErros({IOSink? saidaDeErros}) {
  return (Handler interno) {
    return (Request requisicao) async {
      try {
        return await interno(requisicao);
      } on HijackException {
        rethrow;
      } on ErroApi catch (erro) {
        return Respostas.erro(erro);
      } catch (erro, pilha) {
        (saidaDeErros ?? stderr).writeln(
          'Erro inesperado em ${requisicao.method} '
          '/${requisicao.url.path}: $erro\n$pilha',
        );
        return Respostas.erro(const ErroInterno());
      }
    };
  };
}
