import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'core/routes/router.dart';

Future<void> main() async {
  final router = createRouter();

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(router.call);

  await shelf_io.serve(handler, 'localhost', 8080);

  print('Servidor iniciado em http://localhost:8080');
}
