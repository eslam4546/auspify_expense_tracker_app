import 'package:equatable/equatable.dart';

/// Domain entity representing an expense category for grouping and visualization.
class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final int iconCode;
  final int colorHex;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.colorHex,
  });

  CategoryEntity copyWith({
    String? id,
    String? name,
    int? iconCode,
    int? colorHex,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCode: iconCode ?? this.iconCode,
      colorHex: colorHex ?? this.colorHex,
    );
  }

  @override
  List<Object?> get props => [id, name, iconCode, colorHex];
}
