import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../data/models/person_model.dart';

final personBoxProvider = Provider<Box<PersonModel>>((ref) {
  return Hive.box<PersonModel>('persons');
});

final personListProvider = StateNotifierProvider<PersonListNotifier, List<PersonModel>>((ref) {
  final box = ref.watch(personBoxProvider);
  return PersonListNotifier(box);
});

class PersonListNotifier extends StateNotifier<List<PersonModel>> {
  final Box<PersonModel> _box;

  PersonListNotifier(this._box) : super(_box.values.toList());

  void addPerson(PersonModel person) {
    _box.put(person.id, person);
    state = _box.values.toList();
  }

  void deletePerson(String id) {
    _box.delete(id);
    state = _box.values.toList();
  }
}
