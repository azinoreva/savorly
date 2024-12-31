import 'package:flutter/material.dart';
import 'meal.dart'; // Import Meal and Ingredient classes
import 'package:provider/provider.dart';
import 'main.dart';

class IngredientsToMeals extends StatefulWidget {
  @override
  _IngredientsToMealsPageState createState() => _IngredientsToMealsPageState();
}

class _IngredientsToMealsPageState extends State<IngredientsToMeals> {
  final _formKey = GlobalKey<FormState>();
  final _ingredientController = TextEditingController();
  final List<String> _enteredIngredients = [];
  List<Meal> _filteredMeals = [];

  @override
  void dispose() {
    _ingredientController.dispose();
    super.dispose();
  }

  void _filterMeals() {
    final appState = context.read<MyAppState>();
    final mealBox = appState.mealBox;
    setState(() {
      if (_enteredIngredients.isEmpty) {
        _filteredMeals = mealBox.getAll(); // Show all meals if no ingredients
      } else {
        _filteredMeals = mealBox.getAll().where((meal) {
          final ingredientNames = meal.ingredients.map((i) => i.name).toSet();
          return _enteredIngredients.every(ingredientNames.contains);
        }).toList();
      }
    });
  }

  void _addIngredient(String ingredient) {
    if (ingredient.isNotEmpty && !_enteredIngredients.contains(ingredient)) {
      setState(() {
        _enteredIngredients.add(ingredient);
        _filterMeals();
      });
      _ingredientController.clear();
    }
  }

  void _removeIngredient(String ingredient) {
    setState(() {
      _enteredIngredients.remove(ingredient);
      _filterMeals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Meals by Ingredients'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ingredientController,
                      decoration: InputDecoration(
                        labelText: 'Enter Ingredient',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _addIngredient(_ingredientController.text.trim());
                      }
                    },
                    child: Text('Add'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            if (_enteredIngredients.isNotEmpty)
              Wrap(
                spacing: 8.0,
                children: _enteredIngredients
                    .map((ingredient) => Chip(
                          label: Text(ingredient),
                          onDeleted: () => _removeIngredient(ingredient),
                        ))
                    .toList(),
              ),
            SizedBox(height: 20),
            Expanded(
              child: _filteredMeals.isEmpty
                  ? Center(
                      child: Text('No meals match the selected ingredients.'))
                  : ListView.builder(
                      itemCount: _filteredMeals.length,
                      itemBuilder: (context, index) {
                        final meal = _filteredMeals[index];
                        return ListTile(
                          title: Text(meal.name),
                          subtitle: Text(meal.description),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
