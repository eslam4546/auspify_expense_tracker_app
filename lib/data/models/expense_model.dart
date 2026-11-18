import 'package:hive/hive.dart';

import '../../domain/entities/expense_entity.dart';

/// Data model for [ExpenseEntity] with Hive persistence support.
class ExpenseModel extends ExpenseEntity {
  const ExpenseModel({
    required super.id,
    required super.amount,
    required super.categoryId,
    required super.date,
    super.note,
  });

  /// Creates an [ExpenseModel] from a domain [ExpenseEntity].
  factory ExpenseModel.fromEntity(ExpenseEntity entity) {
    return ExpenseModel(
      id: entity.id,
      amount: entity.amount,
      categoryId: entity.categoryId,
      date: entity.date,
      note: entity.note,
    );
  }

  /// Converts this model back to its domain [ExpenseEntity].
  ExpenseEntity toEntity() {
    return ExpenseEntity(
      id: id,
      amount: amount,
      categoryId: categoryId,
      date: date,
      note: note,
    );
  }

  /// Deserialization helper for Map representation.
  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      categoryId: map['categoryId'] as String,
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
    );
  }

  /// Serialization helper for Map representation.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'categoryId': categoryId,
      'date': date.toIso8601String(),
      'note': note,
    };
  }
}

/// Hive TypeAdapter for [ExpenseModel] (TypeId: 1).
class ExpenseModelAdapter extends TypeAdapter<ExpenseModel> {
  @override
  final int typeId = 1;

  @override
  ExpenseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExpenseModel(
      id: fields[0] as String,
      amount: (fields[1] as num).toDouble(),
      categoryId: fields[2] as String,
      date: fields[3] as DateTime,
      note: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.categoryId)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
