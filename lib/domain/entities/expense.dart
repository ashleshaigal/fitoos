// domain/entities/expense.dart
class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final List<String> participants;
  final DateTime date;
  final Map<String, double> splitPercentages;
  final Map<String, double> shareAmounts;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.participants,
    required this.date,
    required this.splitPercentages,
    required this.shareAmounts,
  });
}
