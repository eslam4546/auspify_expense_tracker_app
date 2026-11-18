import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/exceptions.dart';
import '../../../core/error/failures.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/expense_entity.dart';
import '../../../domain/usecases/add_expense_usecase.dart';
import '../../../domain/usecases/delete_expense_usecase.dart';
import '../../../domain/usecases/get_categories_usecase.dart';
import '../../../domain/usecases/get_expenses_usecase.dart';
import '../../../domain/usecases/update_expense_usecase.dart';
import 'expense_state.dart';

/// Cubit managing core business logic for CRUD operations and chart aggregations.
class ExpenseCubit extends Cubit<ExpenseState> {
  final GetExpensesUseCase getExpensesUseCase;
  final AddExpenseUseCase addExpenseUseCase;
  final UpdateExpenseUseCase updateExpenseUseCase;
  final DeleteExpenseUseCase deleteExpenseUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;

  ExpenseCubit({
    required this.getExpensesUseCase,
    required this.addExpenseUseCase,
    required this.updateExpenseUseCase,
    required this.deleteExpenseUseCase,
    required this.getCategoriesUseCase,
  }) : super(const ExpenseInitial());

  /// Fetches expenses and categories, then calculates aggregate chart values.
  Future<void> loadExpenses() async {
    try {
      emit(const ExpenseLoading());

      final expenses = await getExpensesUseCase();
      final categories = await getCategoriesUseCase();

      _emitLoadedState(expenses: expenses, categories: categories);
    } catch (e) {
      emit(ExpenseError(_mapErrorToMessage(e)));
    }
  }

  /// Validates input, persists the new entity to Hive, and triggers state reload.
  Future<void> addExpense(ExpenseEntity expense) async {
    try {
      await addExpenseUseCase(expense);
      await _refreshExpenses();
    } catch (e) {
      emit(ExpenseError(_mapErrorToMessage(e)));
    }
  }

  /// Modifies an existing expense record in place.
  Future<void> updateExpense(ExpenseEntity expense) async {
    try {
      await updateExpenseUseCase(expense);
      await _refreshExpenses();
    } catch (e) {
      emit(ExpenseError(_mapErrorToMessage(e)));
    }
  }

  /// Removes the expense record from Hive and triggers a state reload.
  Future<void> deleteExpense(String id) async {
    try {
      await deleteExpenseUseCase(id);
      await _refreshExpenses();
    } catch (e) {
      emit(ExpenseError(_mapErrorToMessage(e)));
    }
  }

  /// Updates the touched slice index for interactive chart focus.
  void touchCategoryIndex(int? index) {
    if (state is ExpenseLoaded) {
      final loaded = state as ExpenseLoaded;
      emit(
        loaded.copyWith(touchedCategoryIndex: index, clearTouch: index == null),
      );
    }
  }

  /// Toggles between Pie Chart and Bar Chart representations.
  void toggleChartView() {
    if (state is ExpenseLoaded) {
      final loaded = state as ExpenseLoaded;
      emit(loaded.copyWith(isBarView: !loaded.isBarView));
    }
  }

  /// Helper to refresh data without resetting categories if already loaded.
  Future<void> _refreshExpenses() async {
    final currentCategories = state is ExpenseLoaded
        ? (state as ExpenseLoaded).categories
        : await getCategoriesUseCase();

    final expenses = await getExpensesUseCase();
    _emitLoadedState(
      expenses: expenses,
      categories: currentCategories,
      isBarView: state is ExpenseLoaded
          ? (state as ExpenseLoaded).isBarView
          : false,
    );
  }

  /// Aggregates expenses by categoryId and calculates total monthly spend.
  void _emitLoadedState({
    required List<ExpenseEntity> expenses,
    required List<CategoryEntity> categories,
    bool isBarView = false,
  }) {
    double totalSpend = 0.0;
    final Map<String, double> categorySpendMap = {};

    for (final expense in expenses) {
      totalSpend += expense.amount;
      categorySpendMap[expense.categoryId] =
          (categorySpendMap[expense.categoryId] ?? 0.0) + expense.amount;
    }

    emit(
      ExpenseLoaded(
        expenses: expenses,
        categories: categories,
        totalMonthlySpend: totalSpend,
        categorySpendMap: categorySpendMap,
        isBarView: isBarView,
      ),
    );
  }

  String _mapErrorToMessage(dynamic error) {
    if (error is ValidationException) {
      return error.message;
    } else if (error is CacheFailure) {
      return error.message;
    } else if (error is CacheException) {
      return error.message;
    }
    return 'An unexpected error occurred: ${error.toString()}';
  }
}
