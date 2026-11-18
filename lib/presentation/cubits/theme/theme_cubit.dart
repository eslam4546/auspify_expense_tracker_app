import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/datasources/expense_local_data_source.dart';
import 'theme_state.dart';

/// Cubit managing dynamic theme mode switching and persistent storage.
class ThemeCubit extends Cubit<ThemeState> {
  final ExpenseLocalDataSource localDataSource;

  ThemeCubit({required this.localDataSource}) : super(const ThemeState()) {
    loadTheme();
  }

  /// Loads saved theme preference from local storage.
  void loadTheme() {
    final isDark = localDataSource.getThemeMode();
    emit(ThemeState(themeMode: isDark ? ThemeMode.dark : ThemeMode.light));
  }

  /// Toggles between light and dark modes and persists the choice.
  Future<void> toggleTheme() async {
    final newMode = state.themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    await localDataSource.setThemeMode(newMode == ThemeMode.dark);
    emit(ThemeState(themeMode: newMode));
  }

  /// Explicitly sets a specific theme mode.
  Future<void> setTheme(ThemeMode mode) async {
    await localDataSource.setThemeMode(mode == ThemeMode.dark);
    emit(ThemeState(themeMode: mode));
  }
}
