import 'package:backend/core/database/database.dart';

Future<void> main() async {
  final database = createDatabase();

  try {
    print('1. Inserindo uma tarefa de teste...');
    final newTask = await database.task.create(title: 'Configurar Prisma/ORM Dart');
    print('Tarefa criada com ID: ${newTask.id}, Título: "${newTask.title}", Feita: ${newTask.done}');

    print('2. Buscando todas as tarefas...');
    final tasks = await database.task.get();
    print('Total de tarefas: ${tasks.length}');
    for (final t in tasks) {
      print(' - [${t.id}] ${t.title} (feita: ${t.done})');
    }

    print('Conexão e operações com o PostgreSQL funcionando perfeitamente!');
  } catch (e, stack) {
    print('Erro: $e');
    print('Stacktrace:\n$stack');
  } finally {
    await database.close();
  }
}
