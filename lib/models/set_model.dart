import 'package:hive/hive.dart';
part 'set_model.g.dart';

@HiveType(typeId: 3)
class ExerciseSet extends HiveObject {

  @HiveField(0)
  double weight;

  @HiveField(1)
  int reps;

  @HiveField(2)
  bool completed;

  ExerciseSet({
    required this.weight,
    required this.reps,
    this.completed = false,
  });
}