import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// База лежит в приватной папке приложения, наружу ничего не уходит.
QueryExecutor openDeviceDatabase() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'fitty.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
