// randomMeals.dart

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'main.dart'; // For appState
import 'package:provider/provider.dart'; // For Provider
import 'meal.dart';

class RandomMeals extends StatefulWidget {
  @override
  _RandomMealsState createState() => _RandomMealsState();
}

class _RandomMealsState extends State<RandomMeals> {
  String? _selectedMealType;
  Meal? _randomMeal;

  final List<String> _mealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];

  void _pickRandomMeal(String mealType) {
    var appState = context.read<MyAppState>();
    var meals =
        appState.meals.where((meal) => meal.mealType == mealType).toList();
    if (meals.isNotEmpty) {
      meals.shuffle();
      setState(() {
        _randomMeal = meals.first;
      });
    } else {
      setState(() {
        _randomMeal = null;
      });
      _showErrorDialog('No meals available for $mealType.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Random Meal Picker'),
      ),
      body: ListView(
        padding: EdgeInsets.all(12.0),
        children: [
          DropdownButton<String>(
            value: _selectedMealType,
            hint: Text('Select Meal Type'),
            onChanged: (value) {
              setState(() {
                _selectedMealType = value;
                if (value != null) {
                  _pickRandomMeal(value);
                }
              });
            },
            items: _mealTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
          ),
          SizedBox(height: 20),
          if (_randomMeal != null) ...[
            MealDetails(meal: _randomMeal!),
          ] else if (_selectedMealType != null) ...[
            Text(
              'No meal selected yet.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }
}

class MealDetails extends StatelessWidget {
  final Meal meal;

  const MealDetails({required this.meal});

  @override
  Widget build(BuildContext context) {
    String? youtubeId = YoutubePlayer.convertUrlToId(meal.videoUrl);

    return ListView(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      children: [
        Text(
          meal.name,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          'Type: ${meal.mealType}',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 10),
        Text(
          'Ingredients:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        ...meal.ingredients
            .map((ingredient) =>
                Text('- ${ingredient.name} (${ingredient.quantity}) grams'))
            .toList(),
        SizedBox(height: 10),
        Text(
          'Preparation Steps:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        for (var step in meal.preparationSteps)
          Text('${step.stepNumber}. ${step.instruction}'),
        SizedBox(height: 20),
        if (youtubeId != null)
          Text(
            'Preparation Video:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        if (youtubeId != null)
          YoutubePlayer(
            controller: YoutubePlayerController(
              initialVideoId: youtubeId,
              flags: YoutubePlayerFlags(
                autoPlay: false,
                mute: false,
              ),
            ),
            showVideoProgressIndicator: true,
            onReady: () => print('YouTube Player Ready'),
          ),
        if (youtubeId == null) Text('No video available for this meal.'),
      ],
    );
  }
}
