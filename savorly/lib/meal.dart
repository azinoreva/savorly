import 'package:objectbox/objectbox.dart';


@Entity()
class Meal{
  @Id()
  int id;
  String name;
  String description;
  String imageUrl;
  String videoUrl;
  String mealType;

  @Backlink()
  final ingredients = ToMany<Ingredient>();
  final preparationSteps = ToMany<PreparationStep>();


  Meal({
    this.id = 0,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.mealType,
    required this.videoUrl,

  }
  ): assert(name.isNotEmpty &&
          description.isNotEmpty &&
          imageUrl.isNotEmpty &&
          videoUrl.isNotEmpty);


  static const List<String> validMealTypes = [
  'breakfast',
  'lunch',
  'dinner',
  'snack',
];

String get validatedMealType {
  if (!validMealTypes.contains(mealType)){
    throw ArgumentError('Invalid Meal type: $mealType');
  }
  return mealType;
}

set validatedMealType(String type){
  if (!validMealTypes.contains(type)){
    throw ArgumentError('Invalid Meal type: $type');
}
  mealType = type;
}
} 

@Entity()
class Ingredient{
  @Id()
  int id;

  String name;
  int quantity;
  final meals = ToMany<Meal>();
  
  Ingredient({
    this.id = 0,
    required this.name,
    required this.quantity,
  }): assert (quantity != 0);
}

@Entity()
class PreparationStep{
  @Id()
  int id;
  int stepNumber;
  String instruction;

  PreparationStep({
    this.id = 0,
    required this.stepNumber,
    required this.instruction,
  }): assert (stepNumber > 0 &&
            instruction.isNotEmpty); 
  }

  @Entity()
  class MealPlan{
    @Id()
    int id = 0;
    String day;
    String mealType;
    String mealName;

    MealPlan({
      required this.day,
      required this.mealType,
      required this.mealName,
    });
  }