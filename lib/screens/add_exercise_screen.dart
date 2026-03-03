import 'package:fitness_tracker_app/components/app_theme.dart';
import 'package:fitness_tracker_app/models/set_model.dart';
import 'package:flutter/material.dart';
import 'package:fitness_tracker_app/models/exercise_model.dart';
import 'package:fitness_tracker_app/models/category_model.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class AddExerciseScreen extends StatefulWidget {
  final CategoryModel category;
  final Exercise? exercise;
  final int categoryIndex;

  const AddExerciseScreen({
    super.key,
    required this.category,
    required this.categoryIndex,
    this.exercise,
  });

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController notesController;

  final List<TextEditingController> weightControllers = [];
  final List<TextEditingController> repsControllers = [];

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(text: widget.exercise?.name ?? '');
    notesController =
        TextEditingController(text: widget.exercise?.notes ?? '');

    /// Load previous sets
    if (widget.exercise != null) {
      for (var set in widget.exercise!.sets) {
        weightControllers
            .add(TextEditingController(text: set.weight.toString()));
        repsControllers
            .add(TextEditingController(text: set.reps.toString()));
      }
    } else {
      _addSet();
    }
  }

  void _addSet() {
    setState(() {
      weightControllers.add(TextEditingController());
      repsControllers.add(TextEditingController());
    });
  }

  void _removeSet(int index) {
    setState(() {
      weightControllers[index].dispose();
      repsControllers[index].dispose();
      weightControllers.removeAt(index);
      repsControllers.removeAt(index);
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    notesController.dispose();
    for (var c in weightControllers) c.dispose();
    for (var c in repsControllers) c.dispose();
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

            /// HEADER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryRed, AppTheme.accentRed],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const CircleAvatar(
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    isEditing ? "Edit Exercise" : "Add Exercise",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [

                      /// NAME
                      buildDarkField(
                        controller: nameController,
                        label: "Exercise Name",
                        icon: Icons.edit,
                        isRequired: true,
                      ),

                      const SizedBox(height: 20),

                      /// SETS
                      Column(
                        children: List.generate(weightControllers.length, (i) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: buildDarkField(
                                    controller: weightControllers[i],
                                    label: "Weight",
                                    icon: Icons.fitness_center,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: buildDarkField(
                                    controller: repsControllers[i],
                                    label: "Reps",
                                    icon: Icons.repeat,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeSet(i),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 10),

                      /// ADD SET
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _addSet,
                          icon: const Icon(Icons.add),
                          label: const Text("Add Set"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryRed,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// NOTES
                      buildDarkField(
                        controller: notesController,
                        label: "Notes",
                        icon: Icons.note,
                        maxLines: 3,
                      ),

                      const SizedBox(height: 30),

                      /// SAVE BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isSaving ? null : _saveExercise,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryRed,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: isSaving
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  "Save Exercise",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 30),
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

  /// ================= SAVE LOGIC =================
  Future<void> _saveExercise() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    try {
      final box = Hive.box<CategoryModel>('categories');
      final category = box.getAt(widget.categoryIndex);
      if (category == null) return;

      /// Create Sets
      List<ExerciseSet> sets = [];
      for (int i = 0; i < weightControllers.length; i++) {
        final weight = double.tryParse(weightControllers[i].text) ?? 0;
        final reps = int.tryParse(repsControllers[i].text) ?? 0;
        sets.add(ExerciseSet(weight: weight, reps: reps));
      }

      /// Create Exercise
      final newExercise = Exercise(
        id: widget.exercise?.id ?? const Uuid().v4(),
        name: nameController.text.trim(),
        sets: sets,
        duration: 0, // duration removed per client request
        notes: notesController.text.trim(),
      );

      List<Exercise> updatedExercises = List<Exercise>.from(category.exercises);
      if (widget.exercise != null) {
        updatedExercises.removeWhere((e) => e.id == widget.exercise!.id);
      }
      updatedExercises.add(newExercise);
      category.exercises = updatedExercises;

      /// SAVE
      await box.putAt(widget.categoryIndex, category);

      /// POP BACK
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isSaving = false);
  }

  /// ================= FIELD BUILDER =================
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
      style: const TextStyle(color: Colors.white),
      validator: isRequired
          ? (v) => v == null || v.trim().isEmpty ? "Required" : null
          : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: AppTheme.primaryRed),
        filled: true,
        fillColor: AppTheme.surface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppTheme.primaryRed),
        ),
      ),
    );
  }
}