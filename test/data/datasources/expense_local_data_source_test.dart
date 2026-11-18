import 'dart:io';

import 'package:expense_tracker/data/datasources/expense_local_data_source.dart';
import 'package:expense_tracker/data/datasources/hive_registrar.dart';
import 'package:expense_tracker/data/models/category_model.dart';
import 'package:expense_tracker/data/models/expense_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Box<ExpenseModel> expenseBox;
  late Box<CategoryModel> categoryBox;
  late Box<dynamic> settingsBox;
  late ExpenseLocalDataSourceImpl dataSource;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('datasource_test_');
    Hive.init(tempDir.path);
    HiveRegistrar.registerAdapters();

    expenseBox = await Hive.openBox<ExpenseModel>('test_expenses_ds');
    categoryBox = await Hive.openBox<CategoryModel>('test_categories_ds');
    settingsBox = await Hive.openBox<dynamic>('test_settings_ds');

    dataSource = ExpenseLocalDataSourceImpl(
      expenseBox: expenseBox,
      categoryBox: categoryBox,
      settingsBox: settingsBox,
    );
  });

  tearDown(() async {
    await expenseBox.close();
    await categoryBox.close();
    await settingsBox.close();
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('ExpenseLocalDataSourceImpl', () {
    test('seedDefaultCategories should populate 6 Stitch categories', () async {
      await dataSource.seedDefaultCategories();
      final categories = await dataSource.getCategories();

      expect(categories.length, equals(6));
      expect(categories.any((c) => c.id == 'food'), isTrue);
      expect(categories.any((c) => c.id == 'transport'), isTrue);
      expect(categories.any((c) => c.id == 'utilities'), isTrue);
    });

    test(
      'addExpense and getExpenses should store and sort chronologically',
      () async {
        final exp1 = ExpenseModel(
          id: '1',
          amount: 10.0,
          categoryId: 'food',
          date: DateTime(2026, 11, 10),
        );
        final exp2 = ExpenseModel(
          id: '2',
          amount: 25.0,
          categoryId: 'transport',
          date: DateTime(2026, 11, 14), // newer
        );

        await dataSource.addExpense(exp1);
        await dataSource.addExpense(exp2);

        final expenses = await dataSource.getExpenses();
        expect(expenses.length, equals(2));
        // exp2 is newer, so it should be first
        expect(expenses.first.id, equals('2'));
        expect(expenses.last.id, equals('1'));
      },
    );

    test('deleteExpense should remove expense from box', () async {
      final exp = ExpenseModel(
        id: 'to_delete',
        amount: 15.0,
        categoryId: 'utilities',
        date: DateTime.now(),
      );
      await dataSource.addExpense(exp);
      expect((await dataSource.getExpenses()).length, equals(1));

      await dataSource.deleteExpense('to_delete');
      expect((await dataSource.getExpenses()).length, equals(0));
    });

    test('updateExpense should modify existing record in box', () async {
      final exp = ExpenseModel(
        id: '1',
        amount: 10.0,
        categoryId: 'food',
        date: DateTime(2026, 11, 10),
        note: 'Before',
      );
      await dataSource.addExpense(exp);

      final updated = ExpenseModel(
        id: '1',
        amount: 15.0,
        categoryId: 'food',
        date: DateTime(2026, 11, 10),
        note: 'After',
      );
      await dataSource.updateExpense(updated);

      final result = await dataSource.getExpenses();
      expect(result.first.amount, equals(15.0));
      expect(result.first.note, equals('After'));
    });

    test('theme settings should persist and retrieve correctly', () async {
      expect(dataSource.getThemeMode(), isFalse);

      await dataSource.setThemeMode(true);
      expect(dataSource.getThemeMode(), isTrue);

      await dataSource.setThemeMode(false);
      expect(dataSource.getThemeMode(), isFalse);
    });
  });
}
