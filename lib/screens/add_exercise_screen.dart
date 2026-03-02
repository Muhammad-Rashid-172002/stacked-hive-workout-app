import 'package:fitness_tracker_app/components/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:fitness_tracker_app/models/exercise_model.dart';
import 'package:fitness_tracker_app/models/category_model.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class AddExerciseScreen extends StatefulWidget {
  final CategoryModel category;
  final int? exerciseIndex;
  final Exercise? exercise;

  const AddExerciseScreen({
    super.key,
    required this.category,
    this.exerciseIndex,
    this.exercise,
  });

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController setsController;
  late TextEditingController repsController;
  late TextEditingController durationController;
  late TextEditingController notesController;

  late AnimationController _btnController;

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(text: widget.exercise?.name ?? '');
    setsController =
        TextEditingController(text: widget.exercise?.sets.toString() ?? "3");
    repsController =
        TextEditingController(text: widget.exercise?.reps.toString() ?? "10");
    durationController =
        TextEditingController(text: widget.exercise?.duration.toString() ?? "60");
    notesController =
        TextEditingController(text: widget.exercise?.notes ?? '');

    _btnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.95,
      upperBound: 1,
      value: 1,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    setsController.dispose();
    repsController.dispose();
    durationController.dispose();
    notesController.dispose();
    _btnController.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  final isEditing = widget.exercise != null;

  return Scaffold(
    backgroundColor: AppTheme.jetBlack,
    body: SafeArea(
      child: Column(
        children: [

          /// 🔥 Dark Premium Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryRed, AppTheme.accentRed],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const CircleAvatar(
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  isEditing ? "Edit Exercise" : "Add Exercise",
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          /// Category Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.primaryRed,
                    child: Icon(Icons.fitness_center,
                        color: AppTheme.textPrimary),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    widget.category.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  )
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// Form Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [

                    buildDarkField(
                      controller: nameController,
                      label: "Exercise Name",
                      icon: Icons.edit,
                      isRequired: true,
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          child: buildDarkField(
                            controller: setsController,
                            label: "Sets",
                            icon: Icons.repeat,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: buildDarkField(
                            controller: repsController,
                            label: "Reps",
                            icon: Icons.fitness_center,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    buildDarkField(
                      controller: durationController,
                      label: "Duration (sec)",
                      icon: Icons.timer,
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 18),

                    buildDarkField(
                      controller: notesController,
                      label: "Notes",
                      icon: Icons.note_alt_outlined,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 30),

                    /// 🔥 Dark Red Gradient Button
                    ScaleTransition(
                      scale: _btnController,
                      child: GestureDetector(
                        onTapDown: (_) => _btnController.reverse(),
                        onTapUp: (_) {
                          _btnController.forward();
                          _saveExercise();
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppTheme.primaryRed,
                                AppTheme.darkRed
                              ],
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Center(
                            child: Text(
                              "Save Exercise",
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
Widget buildDarkField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  TextInputType? keyboardType,
  int maxLines = 1,
  bool isRequired = false,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    maxLines: maxLines,
    style: const TextStyle(color: AppTheme.textPrimary),
    validator: isRequired
        ? (value) =>
            value == null || value.trim().isEmpty ? "Required field" : null
        : null,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppTheme.textSecondary),
      prefixIcon: Icon(icon, color: AppTheme.primaryRed),
      filled: true,
      fillColor: AppTheme.surface,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppTheme.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppTheme.primaryRed),
      ),
    ),
  );
}
  void _saveExercise() {
    if (!_formKey.currentState!.validate()) return;

    final box = Hive.box<CategoryModel>('categories');
    final categoryKey = widget.category.key;

    if (categoryKey == null) return;

    final currentCategory = box.get(categoryKey);
    if (currentCategory == null) return;

    final exercise = Exercise(
      id: widget.exercise?.id ?? const Uuid().v4(),
      name: nameController.text.trim(),
      sets: int.tryParse(setsController.text) ?? 0,
      reps: int.tryParse(repsController.text) ?? 0,
      duration: int.tryParse(durationController.text) ?? 0,
      notes: notesController.text.trim(),
    );

    List<Exercise> updatedExercises =
        List<Exercise>.from(currentCategory.exercises);

    if (widget.exercise != null) {
      updatedExercises.removeWhere((e) => e.id == widget.exercise!.id);
    }

    updatedExercises.add(exercise);

    final updatedCategory =
        currentCategory.copyWith(exercises: updatedExercises);

    box.put(categoryKey, updatedCategory);

    if (mounted) Navigator.pop(context, true);
  }
}
