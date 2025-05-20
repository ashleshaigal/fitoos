import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/expense.dart';
import '../providers/expense_provider.dart';
import '../../data/models/person_model.dart';
import '../providers/person_provider.dart';

enum SplitMode { percentage, amount }

class AddExpenseScreen extends ConsumerStatefulWidget {
  final Expense? existingExpense;

  const AddExpenseScreen({super.key, this.existingExpense});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  String _category = 'Food';
  List<String> _selectedPersonIds = [];
  Map<String, TextEditingController> _splitControllers = {};

  SplitMode _splitMode = SplitMode.percentage;

  @override
  void initState() {
    super.initState();

    if (widget.existingExpense != null) {
      final e = widget.existingExpense!;
      _titleController.text = e.title;
      _amountController.text = e.amount.toStringAsFixed(2);
      _category = e.category;
      _selectedPersonIds = List<String>.from(e.participants);

      _splitMode = SplitMode.percentage;

      for (final id in _selectedPersonIds) {
        final textValue =
            (_splitMode == SplitMode.percentage)
                ? e.splitPercentages[id]?.toStringAsFixed(2) ?? '0'
                : e.shareAmounts[id]?.toStringAsFixed(2) ?? '0';
        _addSplitController(id, textValue);
      }
    }

    _amountController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    for (final controller in _splitControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final persons = ref.watch(personListProvider);

    final amount = double.tryParse(_amountController.text) ?? 0;

    final totalSplit = _selectedPersonIds.fold<double>(
      0,
      (sum, id) =>
          sum + (double.tryParse(_splitControllers[id]?.text ?? '0') ?? 0),
    );

    final remaining = amount - totalSplit;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingExpense == null ? 'Add Expense' : 'Edit Expense',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (val) =>
                        val == null || val.trim().isEmpty
                            ? 'Title is required'
                            : null,
              ),
              const SizedBox(height: 16),

              // Amount
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  prefixText: '\$',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty)
                    return 'Amount is required';
                  final parsed = double.tryParse(val);
                  if (parsed == null || parsed <= 0)
                    return 'Enter a valid positive amount';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items:
                    ['Food', 'Transport', 'Entertainment', 'Other']
                        .map(
                          (cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)),
                        )
                        .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _category = val);
                  }
                },
              ),

              const SizedBox(height: 24),

              // Participants
              Text(
                'Select Participants',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    persons.map((person) {
                      final isSelected = _selectedPersonIds.contains(person.id);
                      return FilterChip(
                        label: Text(person.name),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedPersonIds.add(person.id);
                              _addSplitController(person.id, '0');
                            } else {
                              _selectedPersonIds.remove(person.id);
                              _splitControllers[person.id]?.dispose();
                              _splitControllers.remove(person.id);
                            }
                          });
                        },
                      );
                    }).toList(),
              ),

              if (_selectedPersonIds.isNotEmpty) ...[
                const SizedBox(height: 24),

                // Split Mode Toggle Buttons
                Row(
                  children: [
                    const Text('Split by: '),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: const Text('Percentage'),
                      selected: _splitMode == SplitMode.percentage,
                      onSelected: (selected) {
                        if (selected && _splitMode != SplitMode.percentage) {
                          setState(() {
                            _splitMode = SplitMode.percentage;
                            _resetSplitControllers();
                          });
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Amount'),
                      selected: _splitMode == SplitMode.amount,
                      onSelected: (selected) {
                        if (selected && _splitMode != SplitMode.amount) {
                          setState(() {
                            _splitMode = SplitMode.amount;
                            _resetSplitControllers();
                          });
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Text(
                  _splitMode == SplitMode.percentage
                      ? 'Split Percentages (must total exactly 100%)'
                      : 'Split Amounts (must total exactly expense amount)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                const SizedBox(height: 8),

                ..._selectedPersonIds.map((id) {
                  final person = persons.firstWhere((p) => p.id == id);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(person.name)),
                            SizedBox(
                              width: 100,
                              child: TextFormField(
                                controller: _splitControllers[id],
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: InputDecoration(
                                  suffixText:
                                      _splitMode == SplitMode.percentage
                                          ? '%'
                                          : '\$',
                                  border: const OutlineInputBorder(),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty)
                                    return 'Required';
                                  final parsed = double.tryParse(val);
                                  if (parsed == null || parsed < 0) {
                                    return 'Must be a valid non-negative number';
                                  }
                                  if (_splitMode == SplitMode.percentage &&
                                      parsed > 100) {
                                    return 'Max 100%';
                                  }
                                  if (_splitMode == SplitMode.amount &&
                                      parsed >
                                          (double.tryParse(
                                                _amountController.text,
                                              ) ??
                                              double.infinity)) {
                                    return 'Cannot exceed total amount';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),

                        // if (_splitMode == SplitMode.amount)
                        //   Padding(
                        //     padding: const EdgeInsets.only(left: 8, top: 4),
                        //     child: Text(
                        //       'Total Amount: \$${_amountController.text.isEmpty ? '0.00' : double.tryParse(_amountController.text)?.toStringAsFixed(2) ?? '0.00'}',
                        //       style: Theme.of(context).textTheme.bodySmall
                        //           ?.copyWith(color: Colors.grey[600]),
                        //     ),
                        //   ),
                      ],
                    ),
                  );
                }),

                // Live total and remaining feedback
                const SizedBox(height: 12),
                Text(
                  _splitMode == SplitMode.percentage
                      ? 'Total Percentage: ${totalSplit.toStringAsFixed(2)}%'
                      : 'Total Amount: \$${totalSplit.toStringAsFixed(2)}  Remaining: \$${remaining.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: (remaining.abs() < 0.01) ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _saveExpense,
                child: Text(
                  widget.existingExpense == null
                      ? 'Add Expense'
                      : 'Update Expense',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addSplitController(String id, String initialValue) {
    final controller = TextEditingController(text: initialValue);
    controller.addListener(() {
      setState(() {});
    });
    _splitControllers[id] = controller;
  }

  void _resetSplitControllers() {
    for (final controller in _splitControllers.values) {
      controller.dispose();
    }
    _splitControllers.clear();
    for (final id in _selectedPersonIds) {
      _addSplitController(id, '0');
    }
  }

  void _saveExpense() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPersonIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one participant')),
      );
      return;
    }

    final amount = double.parse(_amountController.text);

    if (_splitMode == SplitMode.percentage) {
      final totalPercentage = _selectedPersonIds.fold<double>(
        0,
        (sum, id) =>
            sum + (double.tryParse(_splitControllers[id]?.text ?? '0') ?? 0),
      );

      if ((totalPercentage - 100).abs() > 0.01) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Total percentage must be exactly 100%'),
          ),
        );
        return;
      }

      final splitPercentages = <String, double>{};
      final shareAmounts = <String, double>{};

      for (final id in _selectedPersonIds) {
        final percent = double.parse(_splitControllers[id]?.text ?? '0');
        splitPercentages[id] = percent;
        shareAmounts[id] = amount * (percent / 100);
      }

      final expense = Expense(
        id: widget.existingExpense?.id ?? const Uuid().v4(),
        title: _titleController.text.trim(),
        amount: amount,
        category: _category,
        participants: _selectedPersonIds,
        date: DateTime.now(),
        splitPercentages: splitPercentages,
        shareAmounts: shareAmounts,
      );

      if (widget.existingExpense == null) {
        ref.read(expenseControllerProvider.notifier).add(expense);
      } else {
        ref.read(expenseControllerProvider.notifier).update(expense);
      }

      context.pop();
    } else {
      // SplitMode.amount

      final totalAmount = _selectedPersonIds.fold<double>(
        0,
        (sum, id) =>
            sum + (double.tryParse(_splitControllers[id]?.text ?? '0') ?? 0),
      );

      if ((totalAmount - amount).abs() > 0.01) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Total split amounts must equal total expense amount',
            ),
          ),
        );
        return;
      }

      final splitPercentages = <String, double>{};
      final shareAmounts = <String, double>{};

      for (final id in _selectedPersonIds) {
        final share = double.parse(_splitControllers[id]?.text ?? '0');
        shareAmounts[id] = share;
        splitPercentages[id] = (amount == 0) ? 0 : (share / amount) * 100;
      }

      final expense = Expense(
        id: widget.existingExpense?.id ?? const Uuid().v4(),
        title: _titleController.text.trim(),
        amount: amount,
        category: _category,
        participants: _selectedPersonIds,
        date: DateTime.now(),
        splitPercentages: splitPercentages,
        shareAmounts: shareAmounts,
      );

      if (widget.existingExpense == null) {
        ref.read(expenseControllerProvider.notifier).add(expense);
      } else {
        ref.read(expenseControllerProvider.notifier).update(expense);
      }

      context.pop();
    }
  }
}
