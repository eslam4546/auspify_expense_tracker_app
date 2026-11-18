import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_local_data_source.dart';
import '../models/expense_model.dart';

/// Concrete implementation of [ExpenseRepository] coordinating data operations.
class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource localDataSource;

  const ExpenseRepositoryImpl({required this.localDataSource});

  @override
  Future<List<ExpenseEntity>> getExpenses() async {
    try {
      final models = await localDataSource.getExpenses();
      return models.map((m) => m.toEntity()).toList();
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw CacheFailure('Unexpected error reading expenses: ${e.toString()}');
    }
  }

  @override
  Future<void> addExpense(ExpenseEntity expense) async {
    try {
      final model = ExpenseModel.fromEntity(expense);
      await localDataSource.addExpense(model);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw CacheFailure('Unexpected error adding expense: ${e.toString()}');
    }
  }

  @override
  Future<void> updateExpense(ExpenseEntity expense) async {
    try {
      final model = ExpenseModel.fromEntity(expense);
      await localDataSource.updateExpense(model);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw CacheFailure('Unexpected error updating expense: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    try {
      await localDataSource.deleteExpense(id);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw CacheFailure('Unexpected error deleting expense: ${e.toString()}');
    }
  }

  @override
  Future<List<CategoryEntity>> getCategories() async {
    try {
      final models = await localDataSource.getCategories();
      return models.map((m) => m.toEntity()).toList();
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw CacheFailure(
        'Unexpected error reading categories: ${e.toString()}',
      );
    }
  }
}
