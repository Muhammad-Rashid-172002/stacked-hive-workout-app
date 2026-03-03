import 'package:fitness_tracker_app/components/app_theme.dart';
import 'package:fitness_tracker_app/components/showCustomSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fitness_tracker_app/models/category_model.dart';
import 'package:fitness_tracker_app/models/exercise_model.dart';
import 'package:fitness_tracker_app/models/history_model.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import 'add_exercise_screen.dart';

class CategoryDetailScreen extends StatefulWidget {
  final int categoryIndex;

  const CategoryDetailScreen({
    super.key,
    required this.categoryIndex,
  });

  @override
  State<CategoryDetailScreen> createState() =>
      _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  late Box<CategoryModel> categoryBox;

  @override
  void initState() {
    super.initState();
    categoryBox = Hive.box<CategoryModel>('categories');
  }

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0D),

      /// LISTENABLE HIVE BOX
      body: ValueListenableBuilder(
        valueListenable: categoryBox.listenable(),
        builder: (context, Box<CategoryModel> box, _) {

          final currentCategory = box.getAt(widget.categoryIndex);

          if (currentCategory == null) return const SizedBox();

          return Column(
            children: [

              /// HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1A1A1D),
                      currentCategory.color,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// BACK BUTTON
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// CATEGORY NAME
                    Text(
                      currentCategory.name,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// EXERCISE COUNT
                    Text(
                      "${currentCategory.exercises.length} exercises",
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// EXERCISE LIST
              Expanded(
                child: currentCategory.exercises.isEmpty
                    ? const _EmptyExercises()
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GridView.builder(
                          itemCount: currentCategory.exercises.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 15,
                            crossAxisSpacing: 15,
                            childAspectRatio: 0.78,
                          ),
                          itemBuilder: (context, index) {
                            final exercise = currentCategory.exercises[index];

                            return ExerciseCard(
                              exercise: exercise,

                              /// EDIT
                              onEdit: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddExerciseScreen(
                                      category: currentCategory,
                                      exercise: exercise,
                                      categoryIndex: widget.categoryIndex,
                                    ),
                                  ),
                                );
                              },

                              /// DELETE
                              onDelete: () {
                                final updatedExercises =
                                    List<Exercise>.from(currentCategory.exercises)
                                      ..removeAt(index);

                                currentCategory.exercises = updatedExercises;
                                currentCategory.save();
                              },

                              /// COMPLETE
                              onComplete: () {
                                app.addHistory(
                                  HistoryModel(
                                    notes: exercise.notes,
                                    categoryName: currentCategory.name,
                                    exerciseName: exercise.name,
                                    date: DateTime.now(),
                                  ),
                                );

                                showCustomSnackBar(
                                  context,
                                  "${exercise.name} completed!",
                                  true,
                                );
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),

      /// ADD EXERCISE BUTTON
      floatingActionButton: Container(
        height: 65,
        width: 65,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Colors.red,
              Colors.red.withOpacity(0.7),
            ],
          ),
        ),
        child: IconButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddExerciseScreen(
                  category: categoryBox.getAt(widget.categoryIndex)!,
                  categoryIndex: widget.categoryIndex,
                ),
              ),
            );

            if (result == true) setState(() {});
          },
          icon: const Icon(
            Icons.add,
            size: 30,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// =================================================
/// EXERCISE CARD
/// =================================================
class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onComplete;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.onEdit,
    required this.onDelete,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F23),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// NAME
          Text(
            exercise.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          /// SHOW SET COUNT ONLY (DURATION REMOVED)
          Text(
            "Sets: ${exercise.sets.length}",
            style: const TextStyle(
              color: Colors.white60,
            ),
          ),

          const Spacer(),

          /// ACTIONS
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: onEdit,
                icon: const Icon(
                  Icons.edit,
                  color: Colors.blue,
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ),
            ],
          ),

          /// COMPLETE BUTTON
          GestureDetector(
            onTap: onComplete,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppTheme.primaryRed,
                    AppTheme.darkRed,
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text(
                  "Complete",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// =================================================
/// EMPTY SCREEN
/// =================================================
class _EmptyExercises extends StatelessWidget {
  const _EmptyExercises();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 60,
            color: Colors.white30,
          ),
          SizedBox(height: 20),
          Text(
            "No exercises yet.\nStart building your workout!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}