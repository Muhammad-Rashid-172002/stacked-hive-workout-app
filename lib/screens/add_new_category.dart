import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../providers/app_provider.dart';

class AddCategoryScreen extends StatefulWidget {
  final CategoryModel? category;
  final int? categoryIndex;

  const AddCategoryScreen({super.key, this.category, this.categoryIndex});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  // Default icon
  IconData _selectedIcon = Icons.fitness_center;

  // Icon options
  final List<IconData> _iconOptions = [
    Icons.fitness_center,
    Icons.directions_run,
    Icons.sports_gymnastics,
    Icons.sports_basketball,
    Icons.directions_bike,
    Icons.sports_handball,
  ];

  // Map IconData to icon names
  final Map<IconData, String> _iconNames = {
    Icons.fitness_center: "fitness_center",
    Icons.directions_run: "directions_run",
    Icons.sports_gymnastics: "sports_gymnastics",
    Icons.sports_basketball: "sports_basketball",
    Icons.directions_bike: "directions_bike",
    Icons.sports_handball: "sports_handball",
  };

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
     // _selectedIcon = IconData(widget.category!.iconCodePoint, fontFamily: 'MaterialIcons');
    }
  }

@override
Widget build(BuildContext context) {
  final app = Provider.of<AppProvider>(context, listen: false);
  final isEditing = widget.category != null;

  return Scaffold(
    backgroundColor: const Color(0xFF0B0B0D),
    body: SafeArea(
      child: Column(
        children: [

          /// 🔥 Gradient Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A1A1D), Color(0xFF8B0000)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? "Edit Category" : "Create Category",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Build your workout structure",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          /// 🧾 Form Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [

                    /// Category Name Field
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F1F23),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: "Category Name",
                          hintStyle: TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(18),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter category name";
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// 🏋️ Icon Selection Title
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Choose Icon",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    /// Modern Icon Grid
                    Wrap(
                      spacing: 15,
                      runSpacing: 15,
                      children: _iconOptions.map((iconData) {
                        final isSelected = _selectedIcon == iconData;

                        return GestureDetector(
                          onTap: () => setState(() => _selectedIcon = iconData),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: isSelected
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFF8B0000),
                                        Color(0xFF6E0000)
                                      ],
                                    )
                                  : null,
                              color: isSelected
                                  ? null
                                  : const Color(0xFF1F1F23),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF8B0000)
                                            .withOpacity(0.6),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Icon(
                              iconData,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white54,
                              size: 28,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const Spacer(),

                    /// 🚀 Gradient Save Button
                    GestureDetector(
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          final newCategory = CategoryModel(
                            id: widget.category?.id ??
                                DateTime.now().toString(),
                            name: _nameController.text.trim(),
                            colorValue: const Color(0xFF8B0000).value,
                            iconName:
                                _iconNames[_selectedIcon] ?? "fitness_center",
                            exercises:
                                widget.category?.exercises ?? [],
                          );

                          if (isEditing &&
                              widget.categoryIndex != null) {
                            app.updateCategory(
                                widget.categoryIndex!, newCategory);
                          } else {
                            app.addCategory(newCategory);
                          }

                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF8B0000),
                              Color(0xFF6E0000)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8B0000)
                                  .withOpacity(0.5),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            isEditing ? "Update Category" : "Save Category",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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

}