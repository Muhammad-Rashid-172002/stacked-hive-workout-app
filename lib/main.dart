import 'package:fitness_tracker_app/components/app_theme.dart';
import 'package:fitness_tracker_app/models/category_model.dart';
import 'package:fitness_tracker_app/models/exercise_model.dart';
import 'package:fitness_tracker_app/models/history_model.dart';
import 'package:fitness_tracker_app/providers/app_provider.dart';
import 'package:fitness_tracker_app/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();


  // Register Hive adapters
  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(ExerciseAdapter());
  Hive.registerAdapter(HistoryModelAdapter());

  // Open Hive boxes
  await Hive.openBox('userBox');
  await Hive.openBox<CategoryModel>('categories');
  await Hive.openBox<Exercise>('exercises');
  await Hive.openBox<HistoryModel>('history');

  runApp(const FitForgeApp());
}

class FitForgeApp extends StatelessWidget {
  const FitForgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Stacked',
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
