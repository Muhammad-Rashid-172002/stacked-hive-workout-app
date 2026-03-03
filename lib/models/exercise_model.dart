import 'package:fitness_tracker_app/models/set_model.dart';
import 'package:hive/hive.dart';
part 'exercise_model.g.dart';

@HiveType(typeId: 1)
class Exercise extends HiveObject {

  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<ExerciseSet> sets;

  @HiveField(3)
  int duration;

  @HiveField(4)
  String notes;

  @HiveField(5)
  bool completed;

  Exercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.duration,
    required this.notes,
    this.completed = false,
  });
}