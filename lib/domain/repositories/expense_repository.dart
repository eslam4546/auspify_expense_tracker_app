import '../entities/category_entity.dart';
import '../entities/expense_entity.dart';

/// Abstract contract defining expense persistence and retrieval operations.
/// Follows Clean Architecture Dependency Inversion Principle.
abstract class ExpenseRepository {
  /// Fetches all recorded expenses, ordered chronologically.
  Future<List<ExpenseEntity>> getExpenses();

  /// Persists a new expense entity to the local storage.
  Future<void> addExpense(ExpenseEntity expense);

  /// Updates an existing expense entity in place.
  Future<void> updateExpense(ExpenseEntity expense);

  /// Removes an expense entity by its unique [id].
  Future<void> deleteExpense(String id);

  /// Retrieves the list of available expense categories.
  Future<List<CategoryEntity>> getCategories();
}
