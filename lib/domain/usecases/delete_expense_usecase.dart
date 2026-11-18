import '../../core/error/exceptions.dart';
import '../repositories/expense_repository.dart';

/// UseCase to remove an expense by unique identifier.
class DeleteExpenseUseCase {
  final ExpenseRepository repository;

  const DeleteExpenseUseCase(this.repository);

  Future<void> call(String id) async {
    if (id.trim().isEmpty) {
      throw const ValidationException('Expense ID cannot be empty');
    }
    return repository.deleteExpense(id);
  }
}
