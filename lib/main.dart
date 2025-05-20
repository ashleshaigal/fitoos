import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'data/models/expense_model.dart';
import 'data/models/person_model.dart';
import 'presentation/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  final appDocDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocDir.path);

  // Register Hive Adapters
  Hive.registerAdapter(ExpenseModelAdapter());
  Hive.registerAdapter(PersonModelAdapter());

  // ✅ Open all required boxes before running app
  await Hive.openBox<ExpenseModel>('expenses');
  await Hive.openBox<PersonModel>('persons');

  runApp(const ProviderScope(child: MyApp()));
}
