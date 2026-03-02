
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:fitness_tracker_app/models/category_model.dart';
import 'package:fitness_tracker_app/screens/add_new_category.dart';
import 'package:fitness_tracker_app/screens/category_detail_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Box<CategoryModel>? categoryBox;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    await Hive.initFlutter(); // initialize Hive if not already
    categoryBox = await Hive.openBox<CategoryModel>('categories');
    setState(() {}); // Refresh UI after box is ready
  }

  @override
  Widget build(BuildContext context) {
    if (categoryBox == null) {
      // Show loading until Hive box is ready
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0D), // Jet Black

      floatingActionButton: _buildFAB(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 25),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Workout Categories",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE0E0E0),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: ValueListenableBuilder<Box<CategoryModel>>(
              valueListenable: categoryBox!.listenable(),
              builder: (context, box, _) {
                final categories = box.values.toList();
                if (categories.isEmpty) return const _EmptyState();

                return _buildCategoryGrid(categories);
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🔵 Gradient Header
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0B0B0D), Color(0xFF1A1A1D), Color(0xFF8B0000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome Back!",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE0E0E0),
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Make today count.",
            style: TextStyle(fontSize: 14, color: Color(0xFF9A9A9A)),
          ),
        ],
      ),
    );
  }

  // 🟣 Floating Action Button
  Widget _buildFAB() {
    return Container(
      height: 65,
      width: 65,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF8B0000), Color(0xFF6E0000)],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF8B0000).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: IconButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCategoryScreen()),
          );

          if (result != null && result is CategoryModel) {
            await categoryBox!.add(result); // Store in Hive immediately
          }
        },
        icon: const Icon(Icons.add, size: 30, color: Color(0xFFE0E0E0)),
      ),
    );
  }

  // 🟢 Categories Grid
  Widget _buildCategoryGrid(List<CategoryModel> categories) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          final category = categories[index];

          return GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoryDetailScreen(categoryIndex: index),
                ),
              );

              // If edited, update Hive box
              if (result != null && result is CategoryModel) {
                await categoryBox!.putAt(index, result);
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F1F23),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF2E2E34),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: category.color.withOpacity(0.2),
                          child: Icon(
                            category.icon,
                            color: category.color,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          category.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ✏️ Edit Button
                  Positioned(
                    top: 8,
                    right: 38,
                    child: _iconButton(
                      icon: Icons.edit,
                      color: Colors.blue,
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CategoryDetailScreen(categoryIndex: index),
                          ),
                        );
                        if (result != null && result is CategoryModel) {
                          await categoryBox!.putAt(index, result);
                        }
                      },
                    ),
                  ),
                  // 🗑️ Delete Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _iconButton(
                      icon: Icons.delete,
                      color: Colors.red,
                      onTap: () => _deleteCategory(index),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 🔘 Reusable Icon Button
  Widget _iconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: Color(0xFF26262B),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: Color(0xFF8B0000)),
      ),
    );
  }

  // 🗑️ Delete Category
  void _deleteCategory(int index) async {
    await categoryBox!.deleteAt(index);
  }
}

// ⚪ Empty State
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center, size: 60, color: Color(0xFF5C5C5C)),
          SizedBox(height: 20),
          Text(
            "No categories yet.\nCreate your first one!",
            style: TextStyle(fontSize: 16, color: Color(0xFF9A9A9A)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
