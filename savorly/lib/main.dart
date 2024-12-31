import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'objectbox.g.dart';
import 'mealPlans.dart'; // Import the MealPlans page
import 'newMeals.dart'; // Import the NewMeals page
import 'randomMeals.dart'; // Import the RandomMeals page
import 'ingredientsToMeals.dart'; // Import the IngredientsToMeals page
import 'meal.dart'; // Import the Meal class
import 'savedMealPlans.dart'; // Import the SavedMealPlans page

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Savorly',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 88, 117, 179)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  Meal? current; // Define a variable for the current Meal
  List<Meal> meals = []; // Add this line
  late final Store _store;
  late final Box<Meal> _mealBox;
  late final Box<Ingredient> _ingredientBox;
  late final Box<MealPlan> _mealPlanBox;

  MyAppState() {
    _initializeStore();
  }
  List<MealPlan> get mealPlans => _mealPlanBox.getAll();

  void _initializeStore() {
    _store = Store(getObjectBoxModel());
    _mealBox = _store.box<Meal>();
    _ingredientBox = _store.box<Ingredient>();
    _mealPlanBox = _store.box<MealPlan>();
    _loadMeals();
  }

  void saveMealPlan(MealPlan mealPlan) {
    _mealPlanBox.put(mealPlan);
    notifyListeners();
  }

  void _loadMeals() {
    meals = _mealBox.getAll();
    notifyListeners();
  }

  Box<Meal> get mealBox => _mealBox;
  Box<Ingredient> get ingredientBox => _ingredientBox;
  Box<MealPlan> get mealPlanBox => _mealPlanBox;

  void addMeal(Meal meal) {
    meals.add(meal);
    notifyListeners(); // Notify listeners to update the UI
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  bool isRailExpanded =
      true; // Variable to track the state of the navigation rail

  @override
  Widget build(BuildContext context) {

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = MealPlansPage(); // Pass mealBox to MealPlansPage
        break;
      case 1:
        page = RandomMeals(); // Pass ingredientBox to RandomMeals
        break;
      case 2:
        page = MealFormPage(); // Pass mealBox to MealFormPage
        break;
      case 3:
        page = IngredientsToMeals(); // Pass ingredientBox to IngredientsToMeals
        break;
      case 4:
        page = SavedMealPlansPage(); // Pass mealPlanBox
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      bool isWideScreen =
          constraints.maxWidth > 600; // Check if the screen is wide enough

      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                elevation: 10.0,
                backgroundColor: const Color.fromARGB(255, 236, 241, 241),
                extended: isWideScreen &&
                    isRailExpanded, // Check the state to extend the rail

                destinations: const[
                  NavigationRailDestination(
                    icon: Icon(Icons.calendar_month_rounded),
                    label: Text('Meal Plan'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.restaurant),
                    label: Text('Random Meal'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.add),
                    label: Text('Add New Meals'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.shopping_cart),
                    label: Text('Ingredients to Meals'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.save),
                    label: Text('Saved Meal Plans'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            // Wrap the content area in a widget that resizes
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                padding: const EdgeInsets.all(10),
                child: page,
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              isRailExpanded =
                  !isRailExpanded; // Toggle the rail expanded state
            });
          },
          child:
              Icon(isRailExpanded ? Icons.chevron_left : Icons.chevron_right),
        ),
      );
    });
  }
}

// Meal and Ingredient Models for ObjectBox
