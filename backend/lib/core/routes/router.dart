import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

Router createRouter() {
  final router = Router();

  router.get('/', (Request request) {
    return Response.ok('API do Gerenciador de Quadras');
  });

  return router;
}
