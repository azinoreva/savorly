// mealPlans.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'meal.dart';
import 'main.dart';
import 'dart:io';

class MealPlansPage extends StatefulWidget {
  @override
  _MealPlansPageState createState() => _MealPlansPageState();
}

class _MealPlansPageState extends State<MealPlansPage> {
  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  final Map<String, Map<String, Meal?>> _mealPlan = {};
  final int _snackDays = 2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateMealPlan();
    });
  }

  void _generateMealPlan() {
    // Obtain the app state using Provider
    var appState = context.read<MyAppState>();
    var meals = appState.meals;

    /* void _clearMealPlan() {
      setState(() {
        _mealPlan.clear();
      });
    } // Fetch meals from appState
*/

    setState(() {
      _mealPlan.clear();
      for (var day in _daysOfWeek) {
        _mealPlan[day] = {
          'breakfast': _getMealOfType(meals, 'breakfast'),
          'lunch': _getMealOfType(meals, 'lunch'),
          'dinner': _daysOfWeek.indexOf(day) < _snackDays
              ? _getMealOfType(meals, 'snack')
              : _getMealOfType(meals, 'dinner'),
        };
        //save each meal plan to objectbox
        if (_mealPlan[day] != null) {
          _mealPlan[day]!.forEach((time, meal) {
            if (meal != null) {
              appState.saveMealPlan(
                MealPlan(
                    day: day, mealName: meal.name, mealType: meal.mealType),
              );
            }
          });
        }
      }
    });
  }

  Meal? _getMealOfType(List<Meal> meals, String type) {
    final filteredMeals = meals.where((meal) => meal.mealType == type).toList();
    if (filteredMeals.isNotEmpty) {
      filteredMeals.shuffle();
      return filteredMeals.first;
    }
    return null;
  }

  String _updateMeal(String day, String time, Meal meal) {
    setState(() {
      _mealPlan[day]![time] = meal;
    });
    return meal.name;
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var meals = appState.meals;

    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Planner'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _generateMealPlan,
          ),
        ],
      ),
      body: meals.isEmpty
          ? Center(
              child: Text('No meals available. Add meals to the database.'))
          : Column(
              children: [
                Expanded(
                  flex: 2,
                  child: ListView.builder(
                    itemCount: _daysOfWeek.length,
                    itemBuilder: (context, index) {
                      final day = _daysOfWeek[index];
                      return MealPlanDay(
                        day: day,
                        meals: _mealPlan[day] ?? {}, // Empty map if null
                        allMeals: meals,
                        onMealUpdated: _updateMeal,
                      );
                    },
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Drag meals from the list to replace them in the meal plan.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                Expanded(
                  flex: 2,
                  child: MealList(meals: meals),
                ),
              ],
            ),
    );
  }
}

class MealPlanDay extends StatelessWidget {
  final String day;
  final Map<String, Meal?> meals;
  final List<Meal> allMeals;
  final Function(String day, String time, Meal meal) onMealUpdated;

  const MealPlanDay({
    required this.day,
    required this.meals,
    required this.allMeals,
    required this.onMealUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              day,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Column(
            children: meals.keys.map((time) {
              final meal = meals[time];
              return DragTarget<Meal>(
                onAccept: (Meal newMeal) {
                  onMealUpdated(day, time, newMeal);
                },
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    height: 100.0, // Adjust the height as needed
                    padding: EdgeInsets.all(8.0),
                    child: ListTile(
                        title: Text(time),
                        subtitle: Text(
                          meal?.name ?? 'No meal selected',
                          overflow: TextOverflow
                              .ellipsis, // Add this line to handle long text
                        ),
                        trailing: meal != null
                            ? Draggable<Meal>(
                                data: meal,
                                feedback: Material(
                                  color: Colors.blueAccent,
                                  child: _MealCard(meal: meal),
                                ),
                                child: SizedBox(
                                  child: _MealCard(meal: meal),
                                ),
                              )
                            : null),
                  );
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class MealList extends StatelessWidget {
  final List<Meal> meals;

  const MealList({required this.meals});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200.0,
      child: GridView.builder(
        padding: EdgeInsets.all(8.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 2.0, // Adjust the aspect ratio as needed
        ),
        itemCount: meals.length,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final meal = meals[index];
          return Draggable<Meal>(
            data: meal,
            feedback: Material(
              color: Colors.transparent,
              child: Opacity(opacity: 0.8, child: _MealCard(meal: meal)),
            ),
            child: _MealCard(meal: meal),
          );
        },
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final Meal meal;

  const _MealCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200.0,
      height: 200.0,
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
                child: meal.imageUrl.isNotEmpty
                    ? _buildImage(meal.imageUrl)
                    : Icon(
                        Icons.fastfood,
                        size: 48.0,
                        color: Colors.grey[400],
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                meal.name,
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                overflow: TextOverflow
                    .ellipsis, // Ensure the text fits within the card
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.error,
          size: 48.0,
          color: Colors.grey[400],
        ),
      );
    } else {
      //if the image is local
      final file = File(imageUrl);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      } else {
        return Icon(
          Icons.broken_image,
          size: 48.0,
          color: Colors.grey[400],
        );
      }
    }
  }
}
