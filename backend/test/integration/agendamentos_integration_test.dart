@Tags(['integration'])
library;

import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';

void main() {
  final baseUrl = Uri.parse('http://localhost:8080');
  late HttpClient client;

  Future<({int status, Map<String, dynamic> body})> requisitar(
    String metodo,
    String caminho, {
    Map<String, dynamic>? payload,
    String? token,
  }) async {
    final request = await client.openUrl(metodo, baseUrl.resolve(caminho));
    request.headers.contentType = ContentType.json;
    if (token != null) {
      request.headers.set('Authorization', 'Bearer $token');
    }
    if (payload != null) {
      request.write(jsonEncode(payload));
    }

    final response = await request.close();
    final texto = await response.transform(utf8.decoder).join();
    final decoded = texto.isNotEmpty ? jsonDecode(texto) : <String, dynamic>{};

    return (
      status: response.statusCode,
      body: decoded is Map<String, dynamic> ? decoded : {'dados': decoded},
    );
  }

  setUp(() {
    client = HttpClient();
  });

  tearDown(() {
    client.close();
  });

  group('API Gerenciador de Quadras - Testes de Integração', () {
    test('GET / deve confirmar que a API está online', () async {
      final res = await requisitar('GET', '/');

      expect(res.status, 200);
      expect(res.body['status'], 'ok');
    });

    test('POST /auth/login deve autenticar gerente e retornar JWT válido', () async {
      final res = await requisitar(
        'POST',
        '/auth/login',
        payload: {'email': 'admin@teste.com', 'senha': 'Senha@1234'},
      );

      expect(res.status, 200);
      expect(res.body['token'], isA<String>());
      expect((res.body['token'] as String).isNotEmpty, isTrue);
    });

    test('GET /quadras sem token deve ser bloqueado (401)', () async {
      final res = await requisitar('GET', '/quadras');

      expect(res.status, 401);
    });

    test('fluxo completo: criar quadra -> login cliente -> agendar -> bloquear conflito', () async {
      // 1. Login como gerente e garante que existe ao menos uma quadra
      final adminLogin = await requisitar(
        'POST',
        '/auth/login',
        payload: {'email': 'admin@teste.com', 'senha': 'Senha@1234'},
      );
      expect(adminLogin.status, 200);
      final tokenAdmin = adminLogin.body['token'] as String;

      var quadrasRes = await requisitar('GET', '/quadras', token: tokenAdmin);
      var listaQuadras = (quadrasRes.body['itens'] ?? quadrasRes.body['dados']) as List?;

      if (listaQuadras == null || listaQuadras.isEmpty) {
        final criarQuadraRes = await requisitar(
          'POST',
          '/quadras',
          token: tokenAdmin,
          payload: {
            'nome': 'Quadra Teste Integração',
            'localizacao': 'Setor A',
            'duracaoSessaoMin': 60,
            'horarios': [
              {'diaSemana': 1, 'inicio': '08:00', 'fim': '22:00'},
              {'diaSemana': 2, 'inicio': '08:00', 'fim': '22:00'},
              {'diaSemana': 3, 'inicio': '08:00', 'fim': '22:00'},
              {'diaSemana': 4, 'inicio': '08:00', 'fim': '22:00'},
              {'diaSemana': 5, 'inicio': '08:00', 'fim': '22:00'},
              {'diaSemana': 6, 'inicio': '08:00', 'fim': '22:00'},
              {'diaSemana': 7, 'inicio': '08:00', 'fim': '22:00'},
            ],
          },
        );
        expect(criarQuadraRes.status, anyOf(200, 201));

        quadrasRes = await requisitar('GET', '/quadras', token: tokenAdmin);
        listaQuadras = (quadrasRes.body['itens'] ?? quadrasRes.body['dados']) as List?;
      }

      expect(listaQuadras, isNotNull);
      expect(listaQuadras!.isNotEmpty, isTrue);
      final quadraId = listaQuadras.first['id'] as int;

      // 2. Login como cliente
      final loginRes = await requisitar(
        'POST',
        '/auth/login',
        payload: {'email': 'cliente@teste.com', 'senha': 'Cliente@1234'},
      );
      expect(loginRes.status, 200);
      final tokenCliente = loginRes.body['token'] as String;

      final dataFutura = DateTime.now().add(const Duration(days: 20));
      final inicio = DateTime.utc(dataFutura.year, dataFutura.month, dataFutura.day, 14, 0);
      final fim = inicio.add(const Duration(hours: 1));

      // 3. Criar agendamento válido
      final criarRes = await requisitar(
        'POST',
        '/agendamentos/',
        token: tokenCliente,
        payload: {
          'quadraId': quadraId,
          'dataInicio': inicio.toIso8601String(),
          'dataFim': fim.toIso8601String(),
          'valorTotal': 100.0,
        },
      );
      expect(criarRes.status, 200);
      expect(criarRes.body['id'], isNotNull);

      // 4. Tentar agendar no mesmo horário (deve rejeitar)
      final conflitoRes = await requisitar(
        'POST',
        '/agendamentos/',
        token: tokenCliente,
        payload: {
          'quadraId': quadraId,
          'dataInicio': inicio.toIso8601String(),
          'dataFim': fim.toIso8601String(),
          'valorTotal': 100.0,
        },
      );
      expect(conflitoRes.status, isNot(200));
    });
  });
}
