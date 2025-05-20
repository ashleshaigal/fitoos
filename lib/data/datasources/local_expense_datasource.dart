import 'package:fitoos/data/models/expense_model.dart';
import 'package:fitoos/domain/entities/expense.dart';
import 'package:hive/hive.dart';

class LocalExpenseDatasource {
  final _box = Hive.box<ExpenseModel>('expenses');

  Future<void> addExpense(ExpenseModel model) async {
    await _box.put(model.id, model);
  }

  List<ExpenseModel> getExpenses() {
    return _box.values.toList();
  }

    Future<void> updateExpense(Expense expense) async {
    final model = ExpenseModel.fromEntity(expense);
    await _box.put(model.id, model); // overwrite by ID
  }
  
}
