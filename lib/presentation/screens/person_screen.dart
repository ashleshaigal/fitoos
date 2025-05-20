import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../providers/person_provider.dart';
import '../../data/models/person_model.dart';

class PersonScreen extends ConsumerWidget {
  const PersonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final persons = ref.watch(personListProvider);
    final controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Manage People')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(hintText: 'Enter name'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    final name = controller.text.trim();
                    if (name.isNotEmpty) {
                      final newPerson = PersonModel(id: const Uuid().v4(), name: name);
                      ref.read(personListProvider.notifier).addPerson(newPerson);
                      controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: persons.length,
              itemBuilder: (_, i) => ListTile(
                title: Text(persons[i].name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => ref.read(personListProvider.notifier).deletePerson(persons[i].id),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
