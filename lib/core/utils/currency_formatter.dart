import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

/// Utility class for formatting currency, numbers, and dates.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: AppConstants.currencySymbol,
    decimalDigits: 2,
  );

  static final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy');

  /// Formats amount into standard currency string, e.g. `$1,250.00`.
  static String formatAmount(double amount) {
    return _currencyFormat.format(amount);
  }

  /// Formats amount into negative expense string, e.g. `-$45.50`.
  static String formatExpense(double amount) {
    return '-${_currencyFormat.format(amount)}';
  }

  /// Formats a DateTime into `MMM dd, yyyy` (e.g., `Nov 14, 2026`).
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Formats a DateTime into `MMMM yyyy` (e.g., `November 2026`).
  static String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  /// Returns true if date is today.
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
