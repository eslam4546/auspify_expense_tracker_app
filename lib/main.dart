import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'injection_container.dart';
import 'presentation/cubits/expense/expense_cubit.dart';
import 'presentation/cubits/theme/theme_cubit.dart';
import 'presentation/cubits/theme/theme_state.dart';
import 'presentation/pages/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive, open boxes, seed categories, and configure DI
  await InjectionContainer.init();

  runApp(const ExpenseTrackerApp());
}

/// Root widget configuring state providers, themes, and navigation.
class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (_) => InjectionContainer.createThemeCubit(),
        ),
        BlocProvider<ExpenseCubit>(
          create: (_) => InjectionContainer.createExpenseCubit(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: AppConstants.appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.themeMode,
            home: const DashboardPage(),
          );
        },
      ),
    );
  }
}
