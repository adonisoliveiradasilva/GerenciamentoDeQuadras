// GENERATED CODE - DO NOT MODIFY BY HAND.

import 'package:orm/sql.dart';

/// A complete immutable row from "tasks".
final class Task({
  required final int id,
  required final String title,
  required final bool done,
});
final _taskId = Column<int>(
  "id",
  Codecs.integer,
  nullable: false,
  generated: true,
);
final _taskTitle = Column<String>(
  "title",
  Codecs.text,
  nullable: false,
  generated: false,
);
final _taskDone = Column<bool>(
  "done",
  Codecs.boolean,
  nullable: false,
  generated: false,
  defaultSql: "false",
);
final taskSchema = TableSchema(
  "tasks",
  namespace: "public",
  columns: [_taskId, _taskTitle, _taskDone],
  primaryKey: ["id"],
  uniqueKeys: [],
  indexes: [],
  foreignKeys: [],
);

final class TaskFields extends Fields {
  TaskFields(super.table);
  late final id = column(_taskId);
  late final title = column(_taskTitle);
  late final done = column(_taskDone);
}

final taskTable = Table<Task, TaskFields>(
  taskSchema,
  TaskFields.new,
  (row) => (
    row.id,
    row.title,
    row.done,
  ).map((v0, v1, v2) => Task(id: v0, title: v1, done: v2)),
);

final class TaskTableSet extends TableSet<Task, TaskFields> {
  TaskTableSet(QueryContext db) : super(db, taskTable) {
    db.registerSchema(appSchema);
  }
  Future<Task> create({
    Change<int> id = const Change.keep(),
    required String title,
    Change<bool> done = const Change.keep(),
  }) => createRow(
    (row) => [
      ...row.id.change(id),
      row.title.set(title),
      ...row.done.change(done),
    ],
  );
  Query<Task, TaskFields> byId(int id) => where((row) => row.id.eq(id));
}

extension TaskUpdates on Query<Task, TaskFields> {
  Future<int> patch({
    Change<String> title = const Change.keep(),
    Change<bool> done = const Change.keep(),
  }) =>
      update((row) => [...row.title.change(title), ...row.done.change(done)])
          .execute();
}

final appSchema = List<TableSchema>.unmodifiable([taskSchema]);

extension AppTables on QueryContext {
  TaskTableSet get task => TaskTableSet(this);
}
