// Test to verify the bottom navigation bar structure after replacing Goals tab with Reports tab

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker_app/widgets/home_page.dart';
import 'package:finance_tracker_app/service_locator.dart';
import 'package:finance_tracker_app/services/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:provider/provider.dart';
import 'package:finance_tracker_app/providers/user_provider.dart';
import 'package:finance_tracker_app/providers/category_provider.dart';
import 'package:finance_tracker_app/providers/transaction_provider.dart';
import 'package:finance_tracker_app/providers/account_provider.dart';
import 'package:finance_tracker_app/providers/goal_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Initialize FFI for desktop testing
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  setUp(() async {
    // Reset database before each test for isolation
    await DatabaseService.resetForTesting();
    await setupServiceLocator();
  });

  tearDown(() async {
    // Clean up after each test
    await DatabaseService.resetForTesting();
  });

  testWidgets('Bottom navigation bar has 3 items', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => CategoryProvider()),
          ChangeNotifierProvider(create: (_) => TransactionProvider()),
          ChangeNotifierProvider(create: (_) => AccountProvider()),
          ChangeNotifierProvider(create: (_) => GoalProvider()),
        ],
        child: MaterialApp(
          home: HomePage(),
        ),
      ),
    );

    // Wait for the widget to be built
    await tester.pumpAndSettle();

    // Find the BottomNavigationBar
    final bottomNavBar = find.byType(BottomNavigationBar);
    expect(bottomNavBar, findsOneWidget);

    // Verify that there are exactly 3 navigation items
    final navBarWidget = tester.widget<BottomNavigationBar>(bottomNavBar);
    expect(navBarWidget.items.length, 3);

    // Verify the labels
    expect(navBarWidget.items[0].label, 'Обзор');
    expect(navBarWidget.items[1].label, 'История');
    expect(navBarWidget.items[2].label, 'Отчёты');
  });

  testWidgets('Navigation bar items have correct icons', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => CategoryProvider()),
          ChangeNotifierProvider(create: (_) => TransactionProvider()),
          ChangeNotifierProvider(create: (_) => AccountProvider()),
          ChangeNotifierProvider(create: (_) => GoalProvider()),
        ],
        child: MaterialApp(
          home: HomePage(),
        ),
      ),
    );

    // Wait for the widget to be built
    await tester.pumpAndSettle();

    // Find icons in the bottom navigation bar
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.history), findsOneWidget);
    expect(find.byIcon(Icons.assessment), findsOneWidget);

    // Verify Goals icon is not present
    expect(find.byIcon(Icons.monetization_on_outlined), findsNothing);
  });

  testWidgets('Can navigate between all three tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => CategoryProvider()),
          ChangeNotifierProvider(create: (_) => TransactionProvider()),
          ChangeNotifierProvider(create: (_) => AccountProvider()),
          ChangeNotifierProvider(create: (_) => GoalProvider()),
        ],
        child: MaterialApp(
          home: HomePage(),
        ),
      ),
    );

    // Wait for the widget to be built
    await tester.pumpAndSettle();

    // Tap on the History tab (index 1)
    await tester.tap(find.byIcon(Icons.history));
    await tester.pumpAndSettle();

    // Tap on the Reports tab (index 2)
    await tester.tap(find.byIcon(Icons.assessment));
    await tester.pumpAndSettle();

    // Tap back on the Dashboard tab (index 0)
    await tester.tap(find.byIcon(Icons.home));
    await tester.pumpAndSettle();

    // If we got here without errors, navigation works correctly
    expect(find.byType(HomePage), findsOneWidget);
  });
}
