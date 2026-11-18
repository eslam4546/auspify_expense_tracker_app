import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

/// UseCase to retrieve all expenses.
class GetExpensesUseCase {
  final ExpenseRepository repository;

  const GetExpensesUseCase(this.repository);

  Future<List<ExpenseEntity>> call() {
    return repository.getExpenses();
  }
}
