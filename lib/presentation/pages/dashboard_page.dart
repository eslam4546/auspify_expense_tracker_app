import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../domain/entities/expense_entity.dart';
import '../cubits/expense/expense_cubit.dart';
import '../cubits/expense/expense_state.dart';
import '../cubits/theme/theme_cubit.dart';
import '../cubits/theme/theme_state.dart';
import '../widgets/add_expense_bottom_sheet.dart';
import '../widgets/expense_chart_widget.dart';
import '../widgets/expense_list_widget.dart';
import '../widgets/total_spend_card.dart';

/// Primary Dashboard screen assembling the Google Stitch UI layout.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // Load expenses and categories on page mount
    context.read<ExpenseCubit>().loadExpenses();
  }

  void _openAddExpenseSheet(ExpenseLoaded state, {ExpenseEntity? existing}) {
    AddExpenseBottomSheet.show(
      context: context,
      categories: state.categories,
      existingExpense: existing,
      onSave: (expense) {
        if (existing != null) {
          context.read<ExpenseCubit>().updateExpense(expense);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Updated ${CurrencyFormatter.formatAmount(expense.amount)}',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          context.read<ExpenseCubit>().addExpense(expense);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Added ${CurrencyFormatter.formatAmount(expense.amount)}',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }

  void _handleDeleteExpense(ExpenseEntity expense) {
    context.read<ExpenseCubit>().deleteExpense(expense.id);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Deleted ${CurrencyFormatter.formatExpense(expense.amount)}',
        ),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'UNDO',
          textColor: AppColors.primaryDark,
          onPressed: () {
            context.read<ExpenseCubit>().addExpense(expense);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: (isDark ? AppColors.primaryDark : AppColors.primary)
                    .withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                size: 20,
                color: isDark ? AppColors.primaryDark : AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.appTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.4,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.successEmerald,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Offline Ready • Clean Arch',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.successEmerald
                            : const Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, themeState) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: IconButton.filledTonal(
                  onPressed: () {
                    context.read<ThemeCubit>().toggleTheme();
                  },
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, anim) =>
                        RotationTransition(turns: anim, child: child),
                    child: Icon(
                      themeState.isDark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      key: ValueKey(themeState.isDark),
                      size: 20,
                    ),
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFEEF2FF),
                    foregroundColor: isDark
                        ? AppColors.primaryDark
                        : AppColors.primary,
                  ),
                  tooltip: themeState.isDark
                      ? 'Switch to Light Mode'
                      : 'Switch to Dark Mode',
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<ExpenseCubit, ExpenseState>(
        listener: (context, state) {
          if (state is ExpenseError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.expenseRose,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ExpenseLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ExpenseLoaded) {
            return RefreshIndicator(
              onRefresh: () => context.read<ExpenseCubit>().loadExpenses(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Total Spend Hero Card
                    TotalSpendCard(
                      totalSpend: state.totalMonthlySpend,
                      transactionCount: state.expenses.length,
                      currentDate: DateTime.now(),
                    ),
                    const SizedBox(height: 20),

                    // 2. Spending Breakdown Interactive Chart
                    ExpenseChartWidget(
                      categorySpendMap: state.categorySpendMap,
                      categories: state.categories,
                      totalSpend: state.totalMonthlySpend,
                      touchedIndex: state.touchedCategoryIndex,
                      isBarView: state.isBarView,
                      onTouchSlice: (index) {
                        context.read<ExpenseCubit>().touchCategoryIndex(index);
                      },
                      onToggleView: () {
                        context.read<ExpenseCubit>().toggleChartView();
                      },
                    ),
                    const SizedBox(height: 24),

                    // 3. Recent Transactions List
                    ExpenseListWidget(
                      expenses: state.expenses,
                      categories: state.categories,
                      onDelete: _handleDeleteExpense,
                      onTap: (expense) =>
                          _openAddExpenseSheet(state, existing: expense),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is ExpenseError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: AppColors.expenseRose,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.message,
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<ExpenseCubit>().loadExpenses(),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: BlocBuilder<ExpenseCubit, ExpenseState>(
        builder: (context, state) {
          if (state is ExpenseLoaded) {
            return FloatingActionButton.extended(
              onPressed: () => _openAddExpenseSheet(state),
              icon: const Icon(Icons.add_rounded, size: 22),
              label: const Text(
                'Add Expense',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
