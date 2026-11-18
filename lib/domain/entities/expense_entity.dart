import 'package:equatable/equatable.dart';

/// Primary domain entity representing a single financial transaction.
class ExpenseEntity extends Equatable {
  final String id;
  final double amount;
  final String categoryId;
  final DateTime date;
  final String? note;

  const ExpenseEntity({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.note,
  });

  ExpenseEntity copyWith({
    String? id,
    double? amount,
    String? categoryId,
    DateTime? date,
    String? note,
  }) {
    return ExpenseEntity(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [id, amount, categoryId, date, note];
}
