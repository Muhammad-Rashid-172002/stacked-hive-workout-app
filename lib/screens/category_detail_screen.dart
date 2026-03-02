import 'package:fitness_tracker_app/components/app_theme.dart';
import 'package:fitness_tracker_app/components/showCustomSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
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

class _CategoryDetailScreenState
    extends State<CategoryDetailScreen> {
  late Box<CategoryModel> categoryBox;

  @override
  void initState() {
    super.initState();
    categoryBox = Hive.box<CategoryModel>('categories');
  }

  CategoryModel get category =>
      categoryBox.getAt(widget.categoryIndex)!;

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppProvider>(context);
    final currentCategory = category;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0D),

      body: Column(
        children: [

     /// 🔥 Gradient Header with Back Button
Container(
  width: double.infinity,
  padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        const Color(0xFF1A1A1D),
        currentCategory.color,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: const BorderRadius.only(
      bottomLeft: Radius.circular(30),
      bottomRight: Radius.circular(30),
    ),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      /// 🔙 Back Button Row
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
                size: 20,
              ),
            ),
          ),
        ],
      ),

      const SizedBox(height: 20),

      /// Category Name
      Text(
        currentCategory.name,
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      const SizedBox(height: 6),

      /// Exercise Count
      Text(
        "${currentCategory.exercises.length} exercises",
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
        ),
      ),
    ],
  ),
),
   const SizedBox(height: 20),

          /// Exercise List
          Expanded(
            child: currentCategory.exercises.isEmpty
                ? const _EmptyExercises()
                : Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20),
                    child: GridView.builder(
                      itemCount:
                          currentCategory.exercises.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 15,
                        childAspectRatio: 0.78,
                      ),
                      itemBuilder: (context, index) {
                        final exercise =
                            currentCategory
                                .exercises[index];

                        return ExerciseCard(
                          exercise: exercise,
                          onEdit: () async {
                            final result =
                                await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AddExerciseScreen(
                                  category:
                                      currentCategory,
                                  exercise: exercise,
                                  exerciseIndex: index,
                                ),
                              ),
                            );
                            if (result == true)
                              _refresh();
                          },
                          onDelete: () {
                            final updatedExercises =
                                List<Exercise>.from(
                                    currentCategory
                                        .exercises)
                                  ..removeAt(index);

                            final updatedCategory =
                                currentCategory.copyWith(
                              exercises:
                                  updatedExercises,
                            );

                            categoryBox.putAt(
                                widget.categoryIndex,
                                updatedCategory);

                            _refresh();
                          },
                          onComplete: () {
                            app.addHistory(
                              HistoryModel(
                                notes: exercise.notes,
                                categoryName:
                                    currentCategory
                                        .name,
                                exerciseName:
                                    exercise.name,
                                date: DateTime.now(),
                                duration:
                                    exercise.duration,
                              ),
                            );
                            showCustomSnackBar(
                                context,
                                "${exercise.name} completed!",
                                true);
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),

      /// 🔥 Modern Floating Button
      floatingActionButton: Container(
        height: 65,
        width: 65,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              currentCategory.color,
              currentCategory.color
                  .withOpacity(0.7),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: currentCategory.color
                  .withOpacity(0.5),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: IconButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    AddExerciseScreen(
                        category:
                            currentCategory),
              ),
            );
            if (result == true) _refresh();
          },
          icon: const Icon(Icons.add,
              size: 30, color: Colors.white),
        ),
      ),
    );
  }
}

/// =================================================
/// Modern Exercise Card
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
        border: Border.all(
          color: const Color(0xFF2E2E34),
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          /// Name
          Text(
            exercise.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 10),

          /// Details
          Text(
            "Sets: ${exercise.sets}\n"
            "Reps: ${exercise.reps}\n"
            "Duration: ${exercise.duration}s",
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 13,
            ),
          ),

          const Spacer(),

          /// Edit/Delete
          Row(
            mainAxisAlignment:
                MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit,
                    color: Colors.blueAccent),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete,
                    color: Colors.redAccent),
              ),
            ],
          ),

          /// Complete Button
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
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: AppTheme.primaryRed.withOpacity(0.4),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: const Center(
      child: Text(
        "Complete",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: AppTheme.textPrimary,
          letterSpacing: 0.5,
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
/// Empty UI
/// =================================================

class _EmptyExercises
    extends StatelessWidget {
  const _EmptyExercises();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center,
              size: 60,
              color: Colors.white30),
          SizedBox(height: 20),
          Text(
            "No exercises yet.\nStart building your workout!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}
