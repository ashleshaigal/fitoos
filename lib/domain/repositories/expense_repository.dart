import 'package:fitoos/domain/entities/expense.dart';

abstract class ExpenseRepository {
  Future<void> addExpense(Expense expense);
  Future<List<Expense>> getExpenses();
  Future<void> updateExpense(Expense expense);
}
