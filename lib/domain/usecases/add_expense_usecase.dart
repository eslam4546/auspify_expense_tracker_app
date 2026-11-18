import '../../core/error/exceptions.dart';
import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

/// UseCase to validate and record a new expense.
class AddExpenseUseCase {
  final ExpenseRepository repository;

  const AddExpenseUseCase(this.repository);

  Future<void> call(ExpenseEntity expense) async {
    if (expense.amount <= 0) {
      throw const ValidationException(
        'Expense amount must be greater than zero',
      );
    }
    if (expense.categoryId.trim().isEmpty) {
      throw const ValidationException('Expense category must not be empty');
    }
    return repository.addExpense(expense);
  }
}
