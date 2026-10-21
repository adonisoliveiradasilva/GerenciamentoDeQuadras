import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'core/http/erros.dart';
import 'core/http/middlewares.dart';
import 'core/http/respostas.dart';

typedef Modulo = ({String prefixo, Handler rotas});

Handler criarApp({
  Iterable<Modulo> modulos = const [],
  bool registrarRequisicoes = true,
  IOSink? saidaDeErros,
}) {
  final roteador = Router(notFoundHandler: _rotaNaoEncontrada)
    ..get(
      '/',
      (Request _) => Respostas.ok({
        'nome': 'API do Gerenciador de Quadras',
        'status': 'ok',
      }),
    );

  for (final modulo in modulos) {
    roteador.mount(modulo.prefixo, modulo.rotas);
  }

  var pipeline = const Pipeline().addMiddleware(cors());
  if (registrarRequisicoes) pipeline = pipeline.addMiddleware(logRequests());
  return pipeline
      .addMiddleware(tratarErros(saidaDeErros: saidaDeErros))
      .addHandler(roteador.call);
}

Response _rotaNaoEncontrada(Request _) => Respostas.erro(
  const NaoEncontrado('Rota não encontrada.', 'ROTA_NAO_ENCONTRADA'),
);
