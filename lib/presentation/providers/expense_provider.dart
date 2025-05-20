import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/expense.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../data/datasources/local_expense_datasource.dart';

final expenseControllerProvider = StateNotifierProvider<ExpenseController, List<Expense>>((ref) {
  final repo = ExpenseRepositoryImpl(LocalExpenseDatasource());
  return ExpenseController(repo);
});

class ExpenseController extends StateNotifier<List<Expense>> {
  final ExpenseRepositoryImpl _repo;

  ExpenseController(this._repo) : super([]) {
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    state = await _repo.getExpenses();
  }

  Future<void> add(Expense expense) async {
    await _repo.addExpense(expense);
    loadExpenses();
  }

  Future<void> update(Expense updatedExpense) async {
  await _repo.updateExpense(updatedExpense);
  loadExpenses();
}

}
