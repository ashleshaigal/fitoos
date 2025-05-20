import 'package:fitoos/data/models/person_model.dart';
import 'package:fitoos/presentation/providers/person_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/expense.dart';
import '../providers/expense_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () => context.push('/people'),
          ),
        ],
      ),
      body:
          expenses.isEmpty
              ? const Center(child: Text('No expenses yet'))
              : ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  final exp = expenses[index];
                  return ListTile(
                    title: Text(exp.title),
                    onTap: () => context.pushNamed('add_expense', extra: exp),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${exp.category} • ${exp.participants.length} people',
                        ),
                        Text(
                          exp.shareAmounts.entries
                              .map((e) {
                                final person = ref
                                    .read(personListProvider)
                                    .firstWhere(
                                      (p) => p.id == e.key,
                                      orElse:
                                          () => PersonModel(
                                            id: e.key,
                                            name: 'Unknown',
                                          ),
                                    );
                                return '${person.name}: ₹${e.value.toStringAsFixed(2)}';
                              })
                              .join(', '),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),

                    trailing: Text('₹${exp.amount.toStringAsFixed(2)}'),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
