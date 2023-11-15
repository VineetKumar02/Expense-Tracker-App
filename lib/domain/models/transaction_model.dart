import 'package:hive/hive.dart';

import 'category_model.dart';
part 'transaction_model.g.dart';

@HiveType(typeId: 1)
class Transaction extends HiveObject {
  @HiveField(0)
  String type;

  @HiveField(1)
  CategoryModel category;

  @HiveField(2)
  String amount;

  @HiveField(3)
  String description;

  @HiveField(4)
  DateTime createAt;

  Transaction(this.type, this.category, this.amount, this.description, this.createAt);
}
