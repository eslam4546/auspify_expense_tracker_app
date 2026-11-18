import 'package:bloc_test/bloc_test.dart';
import 'package:expense_tracker/domain/entities/category_entity.dart';
import 'package:expense_tracker/domain/entities/expense_entity.dart';
import 'package:expense_tracker/domain/usecases/add_expense_usecase.dart';
import 'package:expense_tracker/domain/usecases/delete_expense_usecase.dart';
import 'package:expense_tracker/domain/usecases/get_categories_usecase.dart';
import 'package:expense_tracker/domain/usecases/get_expenses_usecase.dart';
import 'package:expense_tracker/domain/usecases/update_expense_usecase.dart';
import 'package:expense_tracker/presentation/cubits/expense/expense_cubit.dart';
import 'package:expense_tracker/presentation/cubits/expense/expense_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetExpensesUseCase extends Mock implements GetExpensesUseCase {}

class MockAddExpenseUseCase extends Mock implements AddExpenseUseCase {}

class MockUpdateExpenseUseCase extends Mock implements UpdateExpenseUseCase {}

class MockDeleteExpenseUseCase extends Mock implements DeleteExpenseUseCase {}

class MockGetCategoriesUseCase extends Mock implements GetCategoriesUseCase {}

void main() {
  late MockGetExpensesUseCase mockGetExpenses;
  late MockAddExpenseUseCase mockAddExpense;
  late MockUpdateExpenseUseCase mockUpdateExpense;
  late MockDeleteExpenseUseCase mockDeleteExpense;
  late MockGetCategoriesUseCase mockGetCategories;

  final tExpense = ExpenseEntity(
    id: 'exp-1',
    amount: 50.0,
    categoryId: 'food',
    date: DateTime(2026, 11, 14),
    note: 'Groceries',
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
    mockGetExpenses = MockGetExpensesUseCase();
    mockAddExpense = MockAddExpenseUseCase();
    mockUpdateExpense = MockUpdateExpenseUseCase();
    mockDeleteExpense = MockDeleteExpenseUseCase();
    mockGetCategories = MockGetCategoriesUseCase();
  });

  ExpenseCubit buildCubit() => ExpenseCubit(
    getExpensesUseCase: mockGetExpenses,
    addExpenseUseCase: mockAddExpense,
    updateExpenseUseCase: mockUpdateExpense,
    deleteExpenseUseCase: mockDeleteExpense,
    getCategoriesUseCase: mockGetCategories,
  );

  group('ExpenseCubit', () {
    test('initial state should be ExpenseInitial', () {
      expect(buildCubit().state, equals(const ExpenseInitial()));
    });

    blocTest<ExpenseCubit, ExpenseState>(
      'loadExpenses emits [ExpenseLoading, ExpenseLoaded] on success with aggregated spend',
      build: () {
        when(() => mockGetExpenses()).thenAnswer((_) async => [tExpense]);
        when(() => mockGetCategories()).thenAnswer((_) async => [tCategory]);
        return buildCubit();
      },
      act: (cubit) => cubit.loadExpenses(),
      expect: () => [
        const ExpenseLoading(),
        ExpenseLoaded(
          expenses: [tExpense],
          categories: const [tCategory],
          totalMonthlySpend: 50.0,
          categorySpendMap: const {'food': 50.0},
        ),
      ],
      verify: (_) {
        verify(() => mockGetExpenses()).called(1);
        verify(() => mockGetCategories()).called(1);
      },
    );

    blocTest<ExpenseCubit, ExpenseState>(
      'addExpense calls addExpenseUseCase and refreshes data',
      build: () {
        when(() => mockAddExpense(any())).thenAnswer((_) async {});
        when(() => mockGetExpenses()).thenAnswer((_) async => [tExpense]);
        when(() => mockGetCategories()).thenAnswer((_) async => [tCategory]);
        return buildCubit();
      },
      act: (cubit) => cubit.addExpense(tExpense),
      expect: () => [
        ExpenseLoaded(
          expenses: [tExpense],
          categories: const [tCategory],
          totalMonthlySpend: 50.0,
          categorySpendMap: const {'food': 50.0},
        ),
      ],
      verify: (_) {
        verify(() => mockAddExpense(tExpense)).called(1);
        verify(() => mockGetExpenses()).called(1);
      },
    );

    blocTest<ExpenseCubit, ExpenseState>(
      'deleteExpense calls deleteExpenseUseCase and refreshes data',
      build: () {
        when(() => mockDeleteExpense('exp-1')).thenAnswer((_) async {});
        when(() => mockGetExpenses()).thenAnswer((_) async => []);
        when(() => mockGetCategories()).thenAnswer((_) async => [tCategory]);
        return buildCubit();
      },
      act: (cubit) => cubit.deleteExpense('exp-1'),
      expect: () => [
        const ExpenseLoaded(
          expenses: [],
          categories: [tCategory],
          totalMonthlySpend: 0.0,
          categorySpendMap: {},
        ),
      ],
      verify: (_) {
        verify(() => mockDeleteExpense('exp-1')).called(1);
        verify(() => mockGetExpenses()).called(1);
      },
    );
  });
}
