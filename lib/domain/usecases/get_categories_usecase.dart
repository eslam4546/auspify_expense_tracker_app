import '../entities/category_entity.dart';
import '../repositories/expense_repository.dart';

/// UseCase to fetch all available expense categories.
class GetCategoriesUseCase {
  final ExpenseRepository repository;

  const GetCategoriesUseCase(this.repository);

  Future<List<CategoryEntity>> call() {
    return repository.getCategories();
  }
}
