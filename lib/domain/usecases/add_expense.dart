import 'package:fitoos/domain/entities/expense.dart';
import 'package:fitoos/domain/repositories/expense_repository.dart';

class AddExpenseUseCase {
  final ExpenseRepository repo;
  AddExpenseUseCase(this.repo);

  Future<void> call(Expense expense) => repo.addExpense(expense);
}
