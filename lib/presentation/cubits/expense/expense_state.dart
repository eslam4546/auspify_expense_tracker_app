import 'package:equatable/equatable.dart';

import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/expense_entity.dart';

/// Base state for expense management.
abstract class ExpenseState extends Equatable {
  const ExpenseState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data loading occurs.
class ExpenseInitial extends ExpenseState {
  const ExpenseInitial();
}

/// State emitted while loading or performing CRUD operations.
class ExpenseLoading extends ExpenseState {
  const ExpenseLoading();
}

/// State containing loaded expenses, categories, and aggregated chart data.
class ExpenseLoaded extends ExpenseState {
  final List<ExpenseEntity> expenses;
  final List<CategoryEntity> categories;
  final double totalMonthlySpend;
  final Map<String, double> categorySpendMap;
  final int? touchedCategoryIndex;
  final bool isBarView;

  const ExpenseLoaded({
    required this.expenses,
    required this.categories,
    required this.totalMonthlySpend,
    required this.categorySpendMap,
    this.touchedCategoryIndex,
    this.isBarView = false,
  });

  /// Helper to find a category by its ID.
  CategoryEntity? getCategoryById(String categoryId) {
    try {
      return categories.firstWhere((cat) => cat.id == categoryId);
    } catch (_) {
      return null;
    }
  }

  /// Calculates percentage of total spend for a given category.
  double getCategoryPercentage(String categoryId) {
    if (totalMonthlySpend <= 0) return 0.0;
    final spend = categorySpendMap[categoryId] ?? 0.0;
    return (spend / totalMonthlySpend) * 100;
  }

  ExpenseLoaded copyWith({
    List<ExpenseEntity>? expenses,
    List<CategoryEntity>? categories,
    double? totalMonthlySpend,
    Map<String, double>? categorySpendMap,
    int? touchedCategoryIndex,
    bool? isBarView,
    bool clearTouch = false,
  }) {
    return ExpenseLoaded(
      expenses: expenses ?? this.expenses,
      categories: categories ?? this.categories,
      totalMonthlySpend: totalMonthlySpend ?? this.totalMonthlySpend,
      categorySpendMap: categorySpendMap ?? this.categorySpendMap,
      touchedCategoryIndex: clearTouch
          ? null
          : (touchedCategoryIndex ?? this.touchedCategoryIndex),
      isBarView: isBarView ?? this.isBarView,
    );
  }

  @override
  List<Object?> get props => [
    expenses,
    categories,
    totalMonthlySpend,
    categorySpendMap,
    touchedCategoryIndex,
    isBarView,
  ];
}

/// State emitted when any expense operation encounters a failure.
class ExpenseError extends ExpenseState {
  final String message;

  const ExpenseError(this.message);

  @override
  List<Object?> get props => [message];
}
