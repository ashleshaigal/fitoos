import 'package:fitoos/domain/entities/expense.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/home_screen.dart';
import 'screens/add_expense_screen.dart';
import 'screens/person_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Expense Splitter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.light,
      ),
      routerConfig: _router,
    );
  }
}

// ------------------------
// ✅ Router Configuration
// ------------------------
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/add',
      name: 'add_expense',
      builder:
          (context, state) =>
              AddExpenseScreen(existingExpense: state.extra as Expense?),
    ),
    GoRoute(
      path: '/people',
      name: 'people',
      builder: (context, state) => const PersonScreen(),
    ),
  ],
);
