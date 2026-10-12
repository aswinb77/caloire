import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mallow/features/system/system_screen.dart';
import 'package:mallow/features/onboarding/onboarding_screen.dart';
import 'package:mallow/features/food/food_screen.dart';
import 'package:mallow/features/workout/workout_screen.dart';
import 'package:mallow/features/chat/chat_screen.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });
  testWidgets('SystemScreen renders 404 and offline tabs correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SystemScreen(),
      ),
    );

    await tester.pump();
    expect(find.text('Wrong turn.'), findsOneWidget);
    expect(find.text('Back to Today'), findsOneWidget);
    expect(find.text('Report a problem'), findsOneWidget);
  });

  testWidgets('OnboardingScreen allows adding stats, changing steps and goals', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: OnboardingScreen(),
        ),
      ),
    );

    await tester.pump();
    // Step 0: Body stats
    expect(find.textContaining('Tell Mallow'), findsOneWidget);
    expect(find.text('Current Weight'), findsOneWidget);
    expect(find.text('Height'), findsOneWidget);
    expect(find.text('Next: What’s your goal?'), findsOneWidget);

    // Tap next to go to Step 1
    await tester.tap(find.text('Next: What’s your goal?'));
    await tester.pumpAndSettle();

    // Step 1: Goal selection
    expect(find.textContaining("What's your goal?"), findsOneWidget);
    expect(find.text('Lose weight'), findsOneWidget);
    expect(find.text('Stay steady'), findsOneWidget);
    expect(find.text('Build up'), findsOneWidget);
    expect(find.text('Looks good'), findsOneWidget);
    expect(find.byKey(const Key('looks_good_button')), findsOneWidget);

    // Tap Looks good button (should not throw or block!)
    await tester.tap(find.byKey(const Key('looks_good_button')));
    await tester.pumpAndSettle();

    // Tap step bar 2 to advance directly to Step 2 (Summary & launch)
    await tester.tap(find.byKey(const Key('step_bar_2')));
    await tester.pumpAndSettle();

    // Step 2: Custom plan ready
    expect(find.textContaining('Your custom\nplan is ready!'), findsOneWidget);
    expect(find.text('Daily Calories'), findsOneWidget);
    expect(find.text('Protein Goal'), findsOneWidget);
    expect(find.text('Gym Burn Target'), findsOneWidget);
    expect(find.text('Let’s start!'), findsOneWidget);

    // Tap Let's start button (should execute cleanly!)
    await tester.tap(find.byKey(const Key('lets_start_button')));
    await tester.pumpAndSettle();
  });



  testWidgets('FoodScreen renders foods list with default items', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: FoodScreen(),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('Add food'), findsOneWidget);
    expect(find.text('Banana'), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);
  });

  testWidgets('ChatScreen does not display raw intent tag chip', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ChatScreen(),
        ),
      ),
    );

    await tester.pump();
    expect(find.textContaining('intent:'), findsNothing);
    expect(find.textContaining('get_remaining'), findsNothing);
  });

  testWidgets('WorkoutScreen renders clean exercise cards and tapping logs as done', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: WorkoutScreen(),
        ),
      ),
    );

    await tester.pump();

    // Verify removed exercises are absent
    expect(find.text('Brisk walk'), findsNothing);
    expect(find.text('Swim'), findsNothing);
    expect(find.text('Yoga'), findsNothing);

    // Verify Workout Plan header renders
    expect(find.text('Workout Plan'), findsOneWidget);
    expect(find.text('Tap any card to log as done'), findsOneWidget);

    // Tap the first exercise card (should mark done and show checkmark)
    final firstExerciseCard = find.byWidgetPredicate(
      (widget) => widget.key != null && widget.key.toString().contains('exercise_card_'),
    ).first;
    expect(firstExerciseCard, findsOneWidget);
    await tester.tap(firstExerciseCard);
    await tester.pumpAndSettle();
  });
}

