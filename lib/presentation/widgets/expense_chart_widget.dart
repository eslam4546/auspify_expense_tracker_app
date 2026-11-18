import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/icon_helper.dart';
import '../../domain/entities/category_entity.dart';

/// Interactive spending distribution chart supporting Donut and Bar views via fl_chart.
class ExpenseChartWidget extends StatelessWidget {
  final Map<String, double> categorySpendMap;
  final List<CategoryEntity> categories;
  final double totalSpend;
  final int? touchedIndex;
  final bool isBarView;
  final ValueChanged<int?> onTouchSlice;
  final VoidCallback onToggleView;

  const ExpenseChartWidget({
    super.key,
    required this.categorySpendMap,
    required this.categories,
    required this.totalSpend,
    required this.touchedIndex,
    required this.isBarView,
    required this.onTouchSlice,
    required this.onToggleView,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter categories that have actual expenses
    final activeEntries = categorySpendMap.entries
        .where((entry) => entry.value > 0)
        .toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header Row with View Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color:
                          (isDark ? AppColors.primaryDark : AppColors.primary)
                              .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.pie_chart_outline_rounded,
                      size: 18,
                      color: isDark ? AppColors.primaryDark : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Spending Breakdown',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              IconButton.filledTonal(
                onPressed: onToggleView,
                icon: Icon(
                  isBarView ? Icons.pie_chart_rounded : Icons.bar_chart_rounded,
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFF1F5F9),
                  foregroundColor: isDark
                      ? AppColors.primaryDark
                      : AppColors.primary,
                  minimumSize: const Size(36, 36),
                  padding: EdgeInsets.zero,
                ),
                tooltip: isBarView ? 'Switch to Donut' : 'Switch to Bar',
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Chart Display or Empty State
          if (activeEntries.isEmpty)
            _buildEmptyChartState(context, isDark)
          else ...[
            SizedBox(
              height: 200,
              child: isBarView
                  ? _buildBarChart(activeEntries, isDark)
                  : _buildDonutChart(activeEntries, isDark),
            ),
            const SizedBox(height: 20),
            // Category Legend
            _buildCategoryLegend(activeEntries, isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildDonutChart(
    List<MapEntry<String, double>> activeEntries,
    bool isDark,
  ) {
    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            pieTouchData: PieTouchData(
              touchCallback: (event, pieTouchResponse) {
                if (!event.isInterestedForInteractions ||
                    pieTouchResponse == null ||
                    pieTouchResponse.touchedSection == null) {
                  onTouchSlice(null);
                  return;
                }
                onTouchSlice(
                  pieTouchResponse.touchedSection!.touchedSectionIndex,
                );
              },
            ),
            borderData: FlBorderData(show: false),
            sectionsSpace: 2.5,
            centerSpaceRadius: 52,
            sections: List.generate(activeEntries.length, (i) {
              final entry = activeEntries[i];
              final category = _findCategory(entry.key);
              final isTouched = i == touchedIndex;
              final double radius = isTouched ? 30.0 : 24.0;
              final color = category != null
                  ? Color(category.colorHex)
                  : AppColors.primary;

              return PieChartSectionData(
                color: color,
                value: entry.value,
                title: '',
                radius: radius,
                badgeWidget: isTouched
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black87 : Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 4),
                          ],
                        ),
                        child: Text(
                          '${((entry.value / totalSpend) * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      )
                    : null,
                badgePositionPercentageOffset: .98,
              );
            }),
          ),
        ),

        // Center readout text
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              touchedIndex != null &&
                      touchedIndex! >= 0 &&
                      touchedIndex! < activeEntries.length
                  ? (_findCategory(activeEntries[touchedIndex!].key)?.name ??
                        'Total')
                  : 'Total',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              touchedIndex != null &&
                      touchedIndex! >= 0 &&
                      touchedIndex! < activeEntries.length
                  ? CurrencyFormatter.formatAmount(
                      activeEntries[touchedIndex!].value,
                    )
                  : CurrencyFormatter.formatAmount(totalSpend),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBarChart(
    List<MapEntry<String, double>> activeEntries,
    bool isDark,
  ) {
    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final category = _findCategory(activeEntries[group.x].key);
              return BarTooltipItem(
                '${category?.name ?? "Category"}\n',
                TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                children: [
                  TextSpan(
                    text: CurrencyFormatter.formatAmount(rod.toY),
                    style: TextStyle(
                      color: category != null
                          ? Color(category.colorHex)
                          : AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= activeEntries.length) {
                  return const SizedBox.shrink();
                }
                final category = _findCategory(activeEntries[index].key);
                return Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Icon(
                    category != null
                        ? IconHelper.getCategoryIcon(category.iconCode)
                        : Icons.category_rounded,
                    size: 16,
                    color: category != null
                        ? Color(category.colorHex)
                        : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(activeEntries.length, (i) {
          final entry = activeEntries[i];
          final category = _findCategory(entry.key);
          final color = category != null
              ? Color(category.colorHex)
              : AppColors.primary;

          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: entry.value,
                color: color,
                width: 16,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCategoryLegend(
    List<MapEntry<String, double>> activeEntries,
    bool isDark,
  ) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: activeEntries.map((entry) {
        final category = _findCategory(entry.key);
        final color = category != null
            ? Color(category.colorHex)
            : AppColors.primary;
        final percentage = totalSpend > 0
            ? ((entry.value / totalSpend) * 100).toStringAsFixed(0)
            : '0';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
              const SizedBox(width: 6),
              Text(
                category?.name ?? 'Category',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$percentage% (${CurrencyFormatter.formatAmount(entry.value)})',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyChartState(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2FF),
            ),
            child: Icon(
              Icons.donut_small_rounded,
              size: 28,
              color: isDark ? AppColors.primaryDark : AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No expenses recorded yet',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap the + button to log your first transaction',
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  CategoryEntity? _findCategory(String categoryId) {
    try {
      return categories.firstWhere((c) => c.id == categoryId);
    } catch (_) {
      return null;
    }
  }
}
