import 'package:hive/hive.dart';
part 'exercise_model.g.dart';

@HiveType(typeId: 1)
class Exercise extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int sets;

  @HiveField(3)
  int reps;

  @HiveField(4)
  int duration;

  @HiveField(5)
  String notes;

  @HiveField(6)
  bool completed; // Track completion

  Exercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.duration,
    required this.notes,
    this.completed = false,
  });
}