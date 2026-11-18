import '../../core/error/exceptions.dart';
import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

/// UseCase to validate and update an existing expense.
class UpdateExpenseUseCase {
  final ExpenseRepository repository;

  const UpdateExpenseUseCase(this.repository);

  Future<void> call(ExpenseEntity expense) async {
    if (expense.amount <= 0) {
      throw const ValidationException(
        'Expense amount must be greater than zero',
      );
    }
    return repository.updateExpense(expense);
  }
}
