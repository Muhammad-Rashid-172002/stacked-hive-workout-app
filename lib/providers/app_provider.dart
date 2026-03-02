import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/category_model.dart';
import '../models/exercise_model.dart';
import '../models/history_model.dart';

class AppProvider extends ChangeNotifier {
  List<CategoryModel> categories = [];
  List<HistoryModel> history = [];
  bool darkMode = false;

  late Box<CategoryModel> categoryBox;
  late Box<HistoryModel> historyBox;

  AppProvider() {
    _initHive();
  }

  Future<void> _initHive() async {
    await Hive.initFlutter();

    // Register adapters if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CategoryModelAdapter());
      Hive.registerAdapter(ExerciseAdapter());
      Hive.registerAdapter(HistoryModelAdapter());
    }

    categoryBox = await Hive.openBox<CategoryModel>('categories');
    historyBox = await Hive.openBox<HistoryModel>('history');

    // Load existing data
    categories = categoryBox.values.toList();
    history = historyBox.values.toList();

    // Seed initial data if empty
    if (categories.isEmpty) {
      _seedData();
    }

    notifyListeners();
  }

  void _seedData() {
    final initialCategories = [
      CategoryModel(
        id: "push",
        name: "Push",
        iconName: 'fitness_center',
        colorValue: Colors.blue.value,
        exercises: [],
      ),
      CategoryModel(
        id: "pull",
        name: "Pull",
        iconName: 'sports_gymnastics',
        colorValue: Colors.purple.value,
        exercises: [],
      ),
      CategoryModel(
        id: "legs",
        name: "Legs",
        iconName: 'directions_run',
        colorValue: Colors.green.value,
        exercises: [],
      ),
    ];

    for (var c in initialCategories) {
      categoryBox.add(c);
    }
    categories = categoryBox.values.toList();
  }

  // Category methods
  void addCategory(CategoryModel category) {
    categoryBox.add(category);
    categories = categoryBox.values.toList();
    notifyListeners();
  }

  void updateCategory(int index, CategoryModel category) {
    categoryBox.putAt(index, category);
    categories = categoryBox.values.toList();
    notifyListeners();
  }

  void deleteCategory(int index) {
    categoryBox.deleteAt(index);
    categories = categoryBox.values.toList();
    notifyListeners();
  }

  // Exercise methods
  void addExercise(int categoryIndex, Exercise exercise) {
    final cat = categories[categoryIndex];
    cat.exercises.add(exercise);
    categoryBox.putAt(categoryIndex, cat);
    categories = categoryBox.values.toList();
    notifyListeners();
  }

  void updateExercise(int categoryIndex, int exerciseIndex, Exercise exercise) {
    final cat = categories[categoryIndex];
    cat.exercises[exerciseIndex] = exercise;
    categoryBox.putAt(categoryIndex, cat);
    categories = categoryBox.values.toList();
    notifyListeners();
  }

  void deleteExercise(int categoryIndex, int exerciseIndex) {
    final cat = categories[categoryIndex];
    cat.exercises.removeAt(exerciseIndex);
    categoryBox.putAt(categoryIndex, cat);
    categories = categoryBox.values.toList();
    notifyListeners();
  }

  // History methods
  void addHistory(HistoryModel h) {
    historyBox.add(h);
    history = historyBox.values.toList();
    notifyListeners();
  }

  void deleteHistory(int index) {
    historyBox.deleteAt(index);
    history = historyBox.values.toList();
    notifyListeners();
  }

  void clearHistory() {
    historyBox.clear();
    history = [];
    notifyListeners();
  }

  // Dark mode toggle
  void toggleDark() {
    darkMode = !darkMode;
    notifyListeners();
  }

  // Reset all data
  void resetAll() {
    categoryBox.clear();
    historyBox.clear();
    categories = [];
    history = [];
    _seedData();
    notifyListeners();
  }
}