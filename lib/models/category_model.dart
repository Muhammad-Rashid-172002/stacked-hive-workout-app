import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'exercise_model.dart';

part 'category_model.g.dart';

@HiveType(typeId: 0)
class CategoryModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String iconName; // ← change here from int to String

  @HiveField(3)
  int colorValue;

  @HiveField(4)
  List<Exercise> exercises;

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconName,
    required this.colorValue,
    List<Exercise>? exercises,
  }) : exercises = exercises ?? [];

  // Map string to const IconData
  IconData get icon => _getIconData(iconName);
  Color get color => Color(colorValue);

  static IconData _getIconData(String name) {
    switch (name) {
      case 'fitness_center':
        return Icons.fitness_center;
      case 'directions_run':
        return Icons.directions_run;
      case 'heart':
        return Icons.favorite;
      case 'home':
        return Icons.home;
      default:
        return Icons.category;
    }
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? iconName,
    int? colorValue,
    List<Exercise>? exercises,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      colorValue: colorValue ?? this.colorValue,
      exercises: exercises ?? this.exercises,
    );
  }
}