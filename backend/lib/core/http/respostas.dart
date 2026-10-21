import 'dart:convert';

import 'package:shelf/shelf.dart';

import 'erros.dart';

abstract final class Respostas {
  static const _cabecalhosJson = {
    'content-type': 'application/json; charset=utf-8',
  };

  static Response json(Object? corpo, {int status = 200}) =>
      Response(status, body: jsonEncode(corpo), headers: _cabecalhosJson);

  static Response ok(Object? corpo) => json(corpo);

  static Response criado(Object? corpo) => json(corpo, status: 201);

  static Response semConteudo() => Response(204);

  static Response erro(ErroApi erro) =>
      json(erro.toJson(), status: erro.status);
}
