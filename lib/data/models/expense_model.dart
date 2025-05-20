import 'package:fitoos/domain/entities/expense.dart';
import 'package:hive/hive.dart';

part 'expense_model.g.dart'; // Required for adapter generation

@HiveType(typeId: 0)
class ExpenseModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final double amount;
  @HiveField(3)
  final String category;
  @HiveField(4)
  final List<String> participants;
  @HiveField(5)
  final DateTime date;
  @HiveField(6)
  final Map<String, double> splitPercentages;

  @HiveField(7)
  final Map<String, double> shareAmounts;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.participants,
    required this.date,
    Map<String, double>? splitPercentages,
    Map<String, double>? shareAmounts,
  }) : splitPercentages = splitPercentages ?? {},
       shareAmounts = shareAmounts ?? {};

  factory ExpenseModel.fromEntity(Expense entity) {
    return ExpenseModel(
      id: entity.id,
      title: entity.title,
      amount: entity.amount,
      category: entity.category,
      participants: entity.participants,
      date: entity.date,
      splitPercentages: Map<String, double>.from(entity.splitPercentages),
      shareAmounts: Map<String, double>.from(entity.shareAmounts),
    );
  }

  Expense toEntity() {
    return Expense(
      id: id,
      title: title,
      amount: amount,
      category: category,
      participants: participants,
      date: date,
      splitPercentages: Map<String, double>.from(splitPercentages),
      shareAmounts: Map<String, double>.from(shareAmounts),
    );
  }
}
