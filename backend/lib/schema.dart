import 'package:orm/schema.dart';

final task = model('tasks', (
  id: identity(),
  title: text(),
  done: boolean(defaultValue: false),
));
