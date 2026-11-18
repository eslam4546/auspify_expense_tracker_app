import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../core/constants/app_constants.dart';
import '../../core/error/exceptions.dart';
import '../models/category_model.dart';
import '../models/expense_model.dart';

/// Contract for local NoSQL persistence via Hive.
abstract class ExpenseLocalDataSource {
  Future<List<ExpenseModel>> getExpenses();
  Future<void> addExpense(ExpenseModel expense);
  Future<void> updateExpense(ExpenseModel expense);
  Future<void> deleteExpense(String id);
  Future<List<CategoryModel>> getCategories();
  Future<void> seedDefaultCategories();
  bool getThemeMode();
  Future<void> setThemeMode(bool isDark);
}

/// Concrete implementation of [ExpenseLocalDataSource] managing Hive boxes.
class ExpenseLocalDataSourceImpl implements ExpenseLocalDataSource {
  final Box<ExpenseModel> expenseBox;
  final Box<CategoryModel> categoryBox;
  final Box<dynamic> settingsBox;

  ExpenseLocalDataSourceImpl({
    required this.expenseBox,
    required this.categoryBox,
    required this.settingsBox,
  });

  @override
  Future<List<ExpenseModel>> getExpenses() async {
    try {
      final expenses = expenseBox.values.toList();
      // Sort chronologically: newest transaction first
      expenses.sort((a, b) => b.date.compareTo(a.date));
      return expenses;
    } catch (e) {
      throw CacheException('Failed to retrieve expenses: ${e.toString()}');
    }
  }

  @override
  Future<void> addExpense(ExpenseModel expense) async {
    try {
      await expenseBox.put(expense.id, expense);
    } catch (e) {
      throw CacheException('Failed to add expense: ${e.toString()}');
    }
  }

  @override
  Future<void> updateExpense(ExpenseModel expense) async {
    try {
      if (!expenseBox.containsKey(expense.id)) {
        throw CacheException('Expense with ID ${expense.id} does not exist');
      }
      await expenseBox.put(expense.id, expense);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Failed to update expense: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    try {
      if (!expenseBox.containsKey(id)) {
        throw CacheException('Expense with ID $id does not exist');
      }
      await expenseBox.delete(id);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Failed to delete expense: ${e.toString()}');
    }
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      if (categoryBox.isEmpty) {
        await seedDefaultCategories();
      }
      return categoryBox.values.toList();
    } catch (e) {
      throw CacheException('Failed to retrieve categories: ${e.toString()}');
    }
  }

  @override
  Future<void> seedDefaultCategories() async {
    try {
      if (categoryBox.isNotEmpty) return;

      final defaultCategories = [
        CategoryModel(
          id: 'food',
          name: 'Food & Dining',
          iconCode: Icons.restaurant_rounded.codePoint,
          colorHex: 0xFFF59E0B, // Amber
        ),
        CategoryModel(
          id: 'transport',
          name: 'Transportation',
          iconCode: Icons.directions_car_rounded.codePoint,
          colorHex: 0xFF3B82F6, // Blue
        ),
        CategoryModel(
          id: 'utilities',
          name: 'Bills & Utilities',
          iconCode: Icons.bolt_rounded.codePoint,
          colorHex: 0xFF10B981, // Emerald
        ),
        CategoryModel(
          id: 'entertainment',
          name: 'Entertainment',
          iconCode: Icons.movie_rounded.codePoint,
          colorHex: 0xFFEC4899, // Pink
        ),
        CategoryModel(
          id: 'health',
          name: 'Health & Fitness',
          iconCode: Icons.fitness_center_rounded.codePoint,
          colorHex: 0xFF8B5CF6, // Purple
        ),
        CategoryModel(
          id: 'shopping',
          name: 'Shopping',
          iconCode: Icons.shopping_bag_rounded.codePoint,
          colorHex: 0xFF06B6D4, // Cyan
        ),
      ];

      for (final category in defaultCategories) {
        await categoryBox.put(category.id, category);
      }
    } catch (e) {
      throw CacheException('Failed to seed categories: ${e.toString()}');
    }
  }

  @override
  bool getThemeMode() {
    try {
      return settingsBox.get(AppConstants.themeModeKey, defaultValue: false)
          as bool;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> setThemeMode(bool isDark) async {
    try {
      await settingsBox.put(AppConstants.themeModeKey, isDark);
    } catch (e) {
      throw CacheException('Failed to persist theme mode: ${e.toString()}');
    }
  }
}
