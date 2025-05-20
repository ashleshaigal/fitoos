import 'package:fitoos/data/datasources/local_expense_datasource.dart';
import 'package:fitoos/data/models/expense_model.dart';
import 'package:fitoos/domain/entities/expense.dart';
import 'package:fitoos/domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final LocalExpenseDatasource datasource;

  ExpenseRepositoryImpl(this.datasource);

  @override
  Future<void> addExpense(Expense expense) {
    final model = ExpenseModel(
      id: expense.id,
      title: expense.title,
      amount: expense.amount,
      category: expense.category,
      participants: expense.participants,
      date: expense.date,
      splitPercentages: expense.splitPercentages,
      shareAmounts: expense.shareAmounts,
    );
    return datasource.addExpense(model);
  }

  @override
  Future<List<Expense>> getExpenses() async {
    final models = datasource.getExpenses();
    return models
        .map(
          (m) => Expense(
            id: m.id,
            title: m.title,
            amount: m.amount,
            category: m.category,
            participants: m.participants,
            date: m.date,
            splitPercentages: m.splitPercentages,
            shareAmounts: m.shareAmounts
          ),
        )
        .toList();
  }

    @override
  Future<void> updateExpense(Expense expense) {
    return datasource.updateExpense(expense); // delegate to datasource
  }

}
