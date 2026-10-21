import 'dart:io';

import 'package:shelf/shelf_io.dart' as shelf_io;

import 'app.dart';
import 'core/config/ambiente.dart';

Future<void> main() async {
  final ambiente = Ambiente.atual;
  final servidor = await shelf_io.serve(
    criarApp(),
    InternetAddress.anyIPv4,
    ambiente.porta,
  );
  print('Servidor iniciado na porta ${servidor.port}');
}
