import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mallow/features/food/food_screen.dart';
import 'package:mallow/core/providers/providers.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('FoodScreen chat logger parses casual text with calories, protein, fat and categorizes by timing',
      (WidgetTester tester) async {
    final container = ProviderContainer();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: FoodScreen(),
        ),
      ),
    );

    await tester.pump();

    // Verify Chat Log mode is active and shows meal timing chips
    expect(find.text('Add food'), findsOneWidget);
    expect(find.textContaining('Chat Log'), findsOneWidget);
    expect(find.text('Breakfast'), findsOneWidget);
    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('Dinner'), findsOneWidget);

    // 1. Enter casual text with calories, protein, and fat explicitly for breakfast
    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    await tester.enterText(
      textField,
      'I had 2 eggs and toast with 350 calories, 20g protein, 12g fat for breakfast',
    );
    await tester.pump();

    // Tap send button (arrow up icon)
    await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
    await tester.pumpAndSettle();

    // Check that assistant logged to Breakfast with the macros
    expect(find.textContaining('Logged to Breakfast'), findsOneWidget);
    expect(find.text('350 kcal'), findsWidgets);
    expect(find.text('20g P'), findsOneWidget);
    expect(find.text('12g F'), findsOneWidget);

    // Verify Riverpod state updated
    final mealLogs = container.read(mealLogsProvider);
    expect(mealLogs.any((m) => m.mealType == 'Breakfast' && m.calories == 350), isTrue);

    // 2. Enter another casual text with lunch
    await tester.enterText(
      textField,
      'Chicken rice bowl, 600 cal, 45g protein, 15g fat for lunch',
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
    await tester.pumpAndSettle();

    expect(find.textContaining('Logged to Lunch'), findsOneWidget);
    expect(find.text('600 kcal'), findsWidgets);
    expect(find.text('45g P'), findsOneWidget);
    expect(find.text('15g F'), findsOneWidget);

    final updatedLogs = container.read(mealLogsProvider);
    expect(updatedLogs.any((m) => m.mealType == 'Lunch' && m.calories == 600), isTrue);

    // 3. Test Undo button on the latest card
    expect(find.text('Undo'), findsWidgets);
    await tester.tap(find.text('Undo').last);
    await tester.pumpAndSettle();

    expect(find.text('Removed from log'), findsOneWidget);

    // 4. Test Routine Preset option (e.g. Same Protein)
    expect(find.textContaining('Same Protein'), findsOneWidget);
    await tester.tap(find.textContaining('Same Protein'));
    await tester.pumpAndSettle();

    expect(find.textContaining('180 kcal'), findsWidgets);
    expect(find.text('30g P'), findsOneWidget);
  });
}
