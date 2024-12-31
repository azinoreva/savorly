import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main.dart';

// The UI for the saved meal plans page

class SavedMealPlansPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(title: Text('Saved Meal Plans')),
      body: ListView.builder(
        itemCount: appState.mealPlans.length,
        itemBuilder: (context, index) {
          final mealPlan = appState.mealPlans[index];
          return ListTile(
            title: Text('${mealPlan.day} - ${mealPlan.mealType}'),
            subtitle: Text(mealPlan.mealName),
          );
        },
      ),
    );
  }
}
