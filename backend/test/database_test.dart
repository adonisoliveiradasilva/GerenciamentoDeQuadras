// Teste de integração do ORM. Precisa de um PostgreSQL 18+ acessível via
// DATABASE_URL (variável de ambiente ou .env) com as migrações aplicadas:
//   dart run orm.config.dart migrate apply
//   dart test test/database_test.dart
@Tags(['integration'])
library;

import 'package:backend/core/database/database.dart';
import 'package:test/test.dart';

void main() {
  late Database<Postgres> db;
  final createdIds = <int>[];

  setUpAll(() => db = createDatabase(maxConnections: 2));

  tearDownAll(() async {
    if (createdIds.isNotEmpty) {
      await db.task.where((t) => t.id.isIn(createdIds)).delete().execute();
    }
    await db.close();
  });

  test('cria uma task com valores padrão', () async {
    final task = await db.task.create(title: 'Teste ORM create');
    createdIds.add(task.id);

    expect(task.id, greaterThan(0));
    expect(task.title, 'Teste ORM create');
    expect(task.done, isFalse);
  });

  test('busca por id e filtra com where', () async {
    final task = await db.task.create(
      title: 'Teste ORM busca',
      done: .set(true),
    );
    createdIds.add(task.id);

    final found = await db.task.byId(task.id).single();
    expect(found.title, 'Teste ORM busca');
    expect(found.done, isTrue);

    final done = await db.task
        .where((t) => t.id.isIn(createdIds).and(t.done.eq(true)))
        .get();
    expect(done.map((t) => t.id), contains(task.id));
  });

  test('atualiza com patch', () async {
    final task = await db.task.create(title: 'Teste ORM antes');
    createdIds.add(task.id);

    final affected = await db.task
        .byId(task.id)
        .patch(title: .set('Teste ORM depois'), done: .set(true));
    expect(affected, 1);

    final updated = await db.task.byId(task.id).single();
    expect(updated.title, 'Teste ORM depois');
    expect(updated.done, isTrue);
  });

  test('remove com delete', () async {
    final task = await db.task.create(title: 'Teste ORM delete');

    final deleted = await db.task.byId(task.id).delete().execute();
    expect(deleted, 1);
    expect(await db.task.byId(task.id).exists(), isFalse);
  });

  test('transação faz rollback quando ocorre erro', () async {
    final before = await db.task.count();

    await expectLater(
      db.transaction((tx) async {
        await tx.task.create(title: 'Teste ORM rollback');
        throw StateError('falha proposital');
      }),
      throwsStateError,
    );

    expect(await db.task.count(), before);
  });
}
