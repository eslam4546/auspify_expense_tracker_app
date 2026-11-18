import 'dart:io';

import 'package:expense_tracker/data/datasources/hive_registrar.dart';
import 'package:expense_tracker/data/models/category_model.dart';
import 'package:expense_tracker/data/models/expense_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  final tempDir = Directory.systemTemp.createTempSync('hive_test_');

  setUpAll(() {
    Hive.init(tempDir.path);
    HiveRegistrar.registerAdapters();
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('Hive Adapters Verification', () {
    test(
      'CategoryModel should serialize and deserialize through Hive box',
      () async {
        final box = await Hive.openBox<CategoryModel>('test_categories');
        const category = CategoryModel(
          id: 'food',
          name: 'Food & Dining',
          iconCode: 0xe532,
          colorHex: 0xFFF59E0B,
        );

        await box.put(category.id, category);
        final retrieved = box.get(category.id);

        expect(retrieved, equals(category));
        expect(retrieved?.name, equals('Food & Dining'));
        expect(retrieved?.colorHex, equals(0xFFF59E0B));
        await box.close();
      },
    );

    test(
      'ExpenseModel should serialize and deserialize through Hive box',
      () async {
        final box = await Hive.openBox<ExpenseModel>('test_expenses');
        final expense = ExpenseModel(
          id: 'uuid-1234',
          amount: 45.50,
          categoryId: 'food',
          date: DateTime(2026, 11, 14, 12, 0),
          note: 'Team Lunch',
        );

        await box.put(expense.id, expense);
        final retrieved = box.get(expense.id);

        expect(retrieved, equals(expense));
        expect(retrieved?.amount, equals(45.50));
        expect(retrieved?.note, equals('Team Lunch'));
        await box.close();
      },
    );
  });
}
