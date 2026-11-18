import 'package:bloc_test/bloc_test.dart';
import 'package:expense_tracker/domain/entities/category_entity.dart';
import 'package:expense_tracker/domain/entities/expense_entity.dart';
import 'package:expense_tracker/presentation/cubits/expense/expense_cubit.dart';
import 'package:expense_tracker/presentation/cubits/expense/expense_state.dart';
import 'package:expense_tracker/presentation/cubits/theme/theme_cubit.dart';
import 'package:expense_tracker/presentation/cubits/theme/theme_state.dart';
import 'package:expense_tracker/presentation/pages/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockExpenseCubit extends MockCubit<ExpenseState>
    implements ExpenseCubit {}

class MockThemeCubit extends MockCubit<ThemeState> implements ThemeCubit {}

void main() {
  late MockExpenseCubit mockExpenseCubit;
  late MockThemeCubit mockThemeCubit;

  const tCategory = CategoryEntity(
    id: 'food',
    name: 'Food & Dining',
    iconCode: 0xe532,
    colorHex: 0xFFF59E0B,
  );

  final tExpense = ExpenseEntity(
    id: 'exp-1',
    amount: 50.0,
    categoryId: 'food',
    date: DateTime(2026, 11, 14),
    note: 'Lunch at cafe',
  );

  setUp(() {
    mockExpenseCubit = MockExpenseCubit();
    mockThemeCubit = MockThemeCubit();
  });

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>.value(value: mockThemeCubit),
        BlocProvider<ExpenseCubit>.value(value: mockExpenseCubit),
      ],
      child: const MaterialApp(home: DashboardPage()),
    );
  }

  testWidgets('DashboardPage renders AppBar, TotalSpendCard, and FAB', (
    WidgetTester tester,
  ) async {
    when(() => mockThemeCubit.state).thenReturn(const ThemeState());
    when(() => mockExpenseCubit.state).thenReturn(
      ExpenseLoaded(
        expenses: [tExpense],
        categories: const [tCategory],
        totalMonthlySpend: 50.0,
        categorySpendMap: const {'food': 50.0},
      ),
    );
    when(() => mockExpenseCubit.loadExpenses()).thenAnswer((_) async {});

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('My Expenses'), findsOneWidget);
    expect(find.text('Total Monthly Spend'), findsOneWidget);
    expect(find.text('\$50.00'), findsWidgets);
    expect(find.text('Add Expense'), findsOneWidget);
  });
}
