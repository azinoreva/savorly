//newmeals.dart

import 'dart:io';
import 'mealPlans.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'meal.dart'; // Import meal-related classes
import 'main.dart'; // Import main app state if required
// Import main app state if required

class MealFormPage extends StatefulWidget {
  @override
  _MealFormPageState createState() => _MealFormPageState();
}

class _MealFormPageState extends State<MealFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _imageUrl = '';
  String _mealType = 'snack';
  String _videoUrl = '';

  final List<TextEditingController> _ingredientControllers = [];
  final List<TextEditingController> _quantityControllers = [];
  final List<TextEditingController> _preparationStepsControllers = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _ingredientControllers.forEach((controller) => controller.dispose());
    _quantityControllers.forEach((controller) => controller.dispose());
    _preparationStepsControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/images');

      if (!imagesDir.existsSync()) {
        imagesDir.createSync();
      }

      final fileName = path.basename(pickedFile.path); // Extract file name
      final savedImage = File('${imagesDir.path}/$fileName');

      await File(pickedFile.path).copy(savedImage.path);

      setState(() {
        _imageUrl = savedImage.path;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No image selected')),
      );
    }
  }

  void _addIngredientField() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
      _quantityControllers.add(TextEditingController());
    });
  }

  void _addPreparationStep() {
    setState(() {
      _preparationStepsControllers.add(TextEditingController());
    });
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final appState = context.read<MyAppState>();
      final mealBox = appState.mealBox;
      final ingredientBox = appState.ingredientBox;

      final newMeal = Meal(
        name: _nameController.text,
        description: _descriptionController.text,
        imageUrl: _imageUrl,
        mealType: _mealType,
        videoUrl: _videoUrl,
      );

      final mealId = mealBox.put(newMeal);

      for (int i = 0; i < _ingredientControllers.length; i++) {
        final ingredientName = _ingredientControllers[i].text;
        final ingredientQuantity = int.tryParse(_quantityControllers[i].text);

        if (ingredientName.isNotEmpty && ingredientQuantity != null) {
          final newIngredient = Ingredient(
            name: ingredientName,
            quantity: ingredientQuantity,
          );
          ingredientBox.put(newIngredient);
          newMeal.ingredients.add(newIngredient);
        }
      }

      for (int i = 0; i < _preparationStepsControllers.length; i++) {
        final instruction = _preparationStepsControllers[i].text;

        if (instruction.isNotEmpty) {
          final newStep = PreparationStep(
            stepNumber: i + 1,
            instruction: instruction,
          );
          newMeal.preparationSteps.add(newStep);
        }
      }

      mealBox.put(newMeal);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(' "${newMeal.name}" added successfully!')),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => (MyHomePage())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add new meal')),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Meal Name'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter meal name' : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Meal Description'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Enter description'
                      : null,
                ),
                DropdownButtonFormField<String>(
                  value: _mealType,
                  decoration: InputDecoration(labelText: 'Meal Type'),
                  onChanged: (String? newValue) {
                    setState(() {
                      _mealType = newValue!;
                    });
                  },
                  items: ['snack', 'breakfast', 'lunch', 'dinner']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Pick Image'),
                ),
                if (_imageUrl != '')
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Image.file(File(_imageUrl)),
                  ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Video URL'),
                  onChanged: (value) => setState(() {
                    _videoUrl = value;
                  }),
                ),
                SizedBox(height: 10),
                ..._ingredientControllers.asMap().entries.map((entry) {
                  int index = entry.key;
                  return Column(
                    children: [
                      TextFormField(
                        controller: _ingredientControllers[index],
                        decoration: InputDecoration(
                            labelText: 'Ingredient ${index + 1} Name'),
                      ),
                      TextFormField(
                        controller: _quantityControllers[index],
                        decoration: InputDecoration(
                            labelText: 'Quantity (in grams or item number)'),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  );
                }),
                ElevatedButton(
                  onPressed: _addIngredientField,
                  child: Text('Add Ingredient'),
                ),
                SizedBox(height: 10),
                ..._preparationStepsControllers.asMap().entries.map((entry) {
                  int index = entry.key;
                  return TextFormField(
                    controller: _preparationStepsControllers[index],
                    decoration: InputDecoration(
                        labelText: 'Step ${index + 1} Instruction'),
                  );
                }),
                ElevatedButton(
                  onPressed: _addPreparationStep,
                  child: Text('Add Preparation Step'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Save Meal'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
