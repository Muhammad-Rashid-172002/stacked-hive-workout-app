import 'package:hive/hive.dart';
part 'history_model.g.dart';

@HiveType(typeId: 2)
class HistoryModel extends HiveObject {
  @HiveField(0)
  String categoryName;

  @HiveField(1)
  String exerciseName;

  // @HiveField(2)
  // int duration;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  String notes;

  HistoryModel({
    required this.categoryName,
    required this.exerciseName,
   // required this.duration,
    required this.date,
    required this.notes,
  });
}