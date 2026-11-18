import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/domain/entities/category_entity.dart';
import 'package:expense_tracker/domain/entities/expense_entity.dart';
import 'package:expense_tracker/domain/repositories/expense_repository.dart';
import 'package:expense_tracker/domain/usecases/add_expense_usecase.dart';
import 'package:expense_tracker/domain/usecases/delete_expense_usecase.dart';
import 'package:expense_tracker/domain/usecases/get_categories_usecase.dart';
import 'package:expense_tracker/domain/usecases/get_expenses_usecase.dart';
import 'package:expense_tracker/domain/usecases/update_expense_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockExpenseRepository extends Mock implements ExpenseRepository {}

void main() {
  late MockExpenseRepository mockRepository;
  late GetExpensesUseCase getExpensesUseCase;
  late AddExpenseUseCase addExpenseUseCase;
  late UpdateExpenseUseCase updateExpenseUseCase;
  late DeleteExpenseUseCase deleteExpenseUseCase;
  late GetCategoriesUseCase getCategoriesUseCase;

  final tExpense = ExpenseEntity(
    id: 'exp-1',
    amount: 100.0,
    categoryId: 'food',
    date: DateTime(2026, 11, 14),
    note: 'Dinner',
  );

  const tCategory = CategoryEntity(
    id: 'food',
    name: 'Food & Dining',
    iconCode: 0xe532,
    colorHex: 0xFFF59E0B,
  );

  setUpAll(() {
    registerFallbackValue(tExpense);
  });

  setUp(() {
    mockRepository = MockExpenseRepository();
    getExpensesUseCase = GetExpensesUseCase(mockRepository);
    addExpenseUseCase = AddExpenseUseCase(mockRepository);
    updateExpenseUseCase = UpdateExpenseUseCase(mockRepository);
    deleteExpenseUseCase = DeleteExpenseUseCase(mockRepository);
    getCategoriesUseCase = GetCategoriesUseCase(mockRepository);
  });

  group('GetExpensesUseCase', () {
    test('should return list of expenses from repository', () async {
      when(() => mockRepository.getExpenses())
          .thenAnswer((_) async => [tExpense]);

      final result = await getExpensesUseCase();

      expect(result, equals([tExpense]));
      verify(() => mockRepository.getExpenses()).called(1);
    });
  });

  group('AddExpenseUseCase', () {
    test('should call repository when expense is valid', () async {
      when(() => mockRepository.addExpense(any())).thenAnswer((_) async {});

      await addExpenseUseCase(tExpense);

      verify(() => mockRepository.addExpense(tExpense)).called(1);
    });

    test('should throw ValidationException when amount <= 0', () async {
      final invalidExpense = tExpense.copyWith(amount: 0.0);

      expect(
        () => addExpenseUseCase(invalidExpense),
        throwsA(isA<ValidationException>()),
      );
      verifyNever(() => mockRepository.addExpense(any()));
    });

    test('should throw ValidationException when categoryId is empty', () async {
      final invalidExpense = tExpense.copyWith(categoryId: '   ');

      expect(
        () => addExpenseUseCase(invalidExpense),
        throwsA(isA<ValidationException>()),
      );
      verifyNever(() => mockRepository.addExpense(any()));
    });
  });

  group('UpdateExpenseUseCase', () {
    test('should call repository when updated expense is valid', () async {
      when(() => mockRepository.updateExpense(any())).thenAnswer((_) async {});

      await updateExpenseUseCase(tExpense);

      verify(() => mockRepository.updateExpense(tExpense)).called(1);
    });

    test('should throw ValidationException when update amount <= 0', () async {
      final invalidExpense = tExpense.copyWith(amount: -5.0);

      expect(
        () => updateExpenseUseCase(invalidExpense),
        throwsA(isA<ValidationException>()),
      );
      verifyNever(() => mockRepository.updateExpense(any()));
    });
  });

  group('DeleteExpenseUseCase', () {
    test('should call repository when id is valid', () async {
      when(() => mockRepository.deleteExpense('exp-1'))
          .thenAnswer((_) async {});

      await deleteExpenseUseCase('exp-1');

      verify(() => mockRepository.deleteExpense('exp-1')).called(1);
    });

    test('should throw ValidationException when id is empty', () async {
      expect(
        () => deleteExpenseUseCase('  '),
        throwsA(isA<ValidationException>()),
      );
      verifyNever(() => mockRepository.deleteExpense(any()));
    });
  });

  group('GetCategoriesUseCase', () {
    test('should return categories from repository', () async {
      when(() => mockRepository.getCategories())
          .thenAnswer((_) async => [tCategory]);

      final result = await getCategoriesUseCase();

      expect(result, equals([tCategory]));
      verify(() => mockRepository.getCategories()).called(1);
    });
  });
}
