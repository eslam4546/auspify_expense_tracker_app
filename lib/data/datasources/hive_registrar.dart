import 'package:hive/hive.dart';

import '../models/category_model.dart';
import '../models/expense_model.dart';

/// Helper to ensure safe, idempotent registration of all Hive TypeAdapters.
class HiveRegistrar {
  HiveRegistrar._();

  static void registerAdapters() {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CategoryModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ExpenseModelAdapter());
    }
  }
}
