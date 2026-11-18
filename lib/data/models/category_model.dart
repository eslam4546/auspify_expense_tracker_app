import 'package:hive/hive.dart';

import '../../domain/entities/category_entity.dart';

/// Data model for [CategoryEntity] with Hive persistence support.
class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.iconCode,
    required super.colorHex,
  });

  /// Creates a [CategoryModel] from a domain [CategoryEntity].
  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      iconCode: entity.iconCode,
      colorHex: entity.colorHex,
    );
  }

  /// Converts this model back to its domain [CategoryEntity].
  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      iconCode: iconCode,
      colorHex: colorHex,
    );
  }

  /// Deserialization helper for Map representation.
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      iconCode: map['iconCode'] as int,
      colorHex: map['colorHex'] as int,
    );
  }

  /// Serialization helper for Map representation.
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'iconCode': iconCode, 'colorHex': colorHex};
  }
}

/// Hive TypeAdapter for [CategoryModel] (TypeId: 0).
class CategoryModelAdapter extends TypeAdapter<CategoryModel> {
  @override
  final int typeId = 0;

  @override
  CategoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CategoryModel(
      id: fields[0] as String,
      name: fields[1] as String,
      iconCode: fields[2] as int,
      colorHex: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CategoryModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.iconCode)
      ..writeByte(3)
      ..write(obj.colorHex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
