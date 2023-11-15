import 'package:hive/hive.dart';
part 'category_model.g.dart';

@HiveType(typeId: 2)
class CategoryModel extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String categoryIcon;

  @HiveField(2)
  String type; // Income or Expense

  CategoryModel(this.title, this.categoryIcon, this.type);
}
