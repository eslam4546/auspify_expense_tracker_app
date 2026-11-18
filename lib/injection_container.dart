import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/app_constants.dart';
import 'data/datasources/expense_local_data_source.dart';
import 'data/datasources/hive_registrar.dart';
import 'data/models/category_model.dart';
import 'data/models/expense_model.dart';
import 'data/repositories/expense_repository_impl.dart';
import 'domain/repositories/expense_repository.dart';
import 'domain/usecases/add_expense_usecase.dart';
import 'domain/usecases/delete_expense_usecase.dart';
import 'domain/usecases/get_categories_usecase.dart';
import 'domain/usecases/get_expenses_usecase.dart';
import 'domain/usecases/update_expense_usecase.dart';
import 'presentation/cubits/expense/expense_cubit.dart';
import 'presentation/cubits/theme/theme_cubit.dart';

/// Lightweight, type-safe dependency injection container following Clean Architecture.
class InjectionContainer {
  InjectionContainer._();

  static late final Box<ExpenseModel> expenseBox;
  static late final Box<CategoryModel> categoryBox;
  static late final Box<dynamic> settingsBox;

  static late final ExpenseLocalDataSource localDataSource;
  static late final ExpenseRepository expenseRepository;

  static late final GetExpensesUseCase getExpensesUseCase;
  static late final AddExpenseUseCase addExpenseUseCase;
  static late final UpdateExpenseUseCase updateExpenseUseCase;
  static late final DeleteExpenseUseCase deleteExpenseUseCase;
  static late final GetCategoriesUseCase getCategoriesUseCase;

  /// Initializes Hive, registers TypeAdapters, opens boxes, and registers all dependencies.
  static Future<void> init() async {
    // 1. Initialize Hive for Flutter
    await Hive.initFlutter();

    // 2. Register Type Adapters
    HiveRegistrar.registerAdapters();

    // 3. Open Hive Boxes
    expenseBox = await Hive.openBox<ExpenseModel>(AppConstants.expensesBox);
    categoryBox = await Hive.openBox<CategoryModel>(AppConstants.categoriesBox);
    settingsBox = await Hive.openBox<dynamic>(AppConstants.settingsBox);

    // 4. Data Layer Instances
    localDataSource = ExpenseLocalDataSourceImpl(
      expenseBox: expenseBox,
      categoryBox: categoryBox,
      settingsBox: settingsBox,
    );

    // Seed initial categories if empty
    await localDataSource.seedDefaultCategories();

    expenseRepository = ExpenseRepositoryImpl(localDataSource: localDataSource);

    // 5. Domain Layer UseCases
    getExpensesUseCase = GetExpensesUseCase(expenseRepository);
    addExpenseUseCase = AddExpenseUseCase(expenseRepository);
    updateExpenseUseCase = UpdateExpenseUseCase(expenseRepository);
    deleteExpenseUseCase = DeleteExpenseUseCase(expenseRepository);
    getCategoriesUseCase = GetCategoriesUseCase(expenseRepository);
  }

  /// Factory for ExpenseCubit
  static ExpenseCubit createExpenseCubit() {
    return ExpenseCubit(
      getExpensesUseCase: getExpensesUseCase,
      addExpenseUseCase: addExpenseUseCase,
      updateExpenseUseCase: updateExpenseUseCase,
      deleteExpenseUseCase: deleteExpenseUseCase,
      getCategoriesUseCase: getCategoriesUseCase,
    );
  }

  /// Factory for ThemeCubit
  static ThemeCubit createThemeCubit() {
    return ThemeCubit(localDataSource: localDataSource);
  }
}
