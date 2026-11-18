import 'package:expense_tracker/data/datasources/expense_local_data_source.dart';
import 'package:expense_tracker/data/models/category_model.dart';
import 'package:expense_tracker/data/models/expense_model.dart';
import 'package:expense_tracker/data/repositories/expense_repository_impl.dart';
import 'package:expense_tracker/domain/entities/expense_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockExpenseLocalDataSource extends Mock
    implements ExpenseLocalDataSource {}

void main() {
  final tExpenseModel = ExpenseModel(
    id: 'exp-1',
    amount: 100.0,
    categoryId: 'food',
    date: DateTime(2026, 11, 14),
    note: 'Dinner',
  );

  final tExpenseEntity = ExpenseEntity(
    id: 'exp-1',
    amount: 100.0,
    categoryId: 'food',
    date: DateTime(2026, 11, 14),
    note: 'Dinner',
  );

  const tCategoryModel = CategoryModel(
    id: 'food',
    name: 'Food & Dining',
    iconCode: 0xe532,
    colorHex: 0xFFF59E0B,
  );

  late MockExpenseLocalDataSource mockDataSource;
  late ExpenseRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(tExpenseModel);
  });

  setUp(() {
    mockDataSource = MockExpenseLocalDataSource();
    repository = ExpenseRepositoryImpl(localDataSource: mockDataSource);
  });

  group('ExpenseRepositoryImpl', () {
    test(
      'getExpenses should return mapped entities from data source',
      () async {
        when(() => mockDataSource.getExpenses())
            .thenAnswer((_) async => [tExpenseModel]);

        final result = await repository.getExpenses();

        expect(result, equals([tExpenseEntity]));
        verify(() => mockDataSource.getExpenses()).called(1);
      },
    );

    test(
      'addExpense should convert entity to model and invoke data source',
      () async {
        when(() => mockDataSource.addExpense(any())).thenAnswer((_) async {});

        await repository.addExpense(tExpenseEntity);

        verify(() => mockDataSource.addExpense(tExpenseModel)).called(1);
      },
    );

    test('deleteExpense should pass id to data source', () async {
      when(() => mockDataSource.deleteExpense('exp-1'))
          .thenAnswer((_) async {});

      await repository.deleteExpense('exp-1');

      verify(() => mockDataSource.deleteExpense('exp-1')).called(1);
    });

    test('getCategories should return mapped category entities', () async {
      when(() => mockDataSource.getCategories())
          .thenAnswer((_) async => [tCategoryModel]);

      final result = await repository.getCategories();

      expect(result.first.id, equals('food'));
      expect(result.first.name, equals('Food & Dining'));
      verify(() => mockDataSource.getCategories()).called(1);
    });
  });
}
