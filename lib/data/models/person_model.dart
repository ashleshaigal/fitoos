import 'package:hive/hive.dart';

part 'person_model.g.dart'; // Required for adapter generation

@HiveType(typeId: 1)
class PersonModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;

  PersonModel({required this.id, required this.name});
}
