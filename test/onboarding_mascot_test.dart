import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mallow/features/onboarding/onboarding_screen.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('Gamified Onboarding displays clean Mallow mascot and responds to stat changes',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: OnboardingScreen(),
        ),
      ),
    );

    await tester.pump();

    // 1. Initial State: Weight question active
    expect(find.textContaining('Tell Mallow'), findsOneWidget);
    expect(find.text('Current Weight'), findsOneWidget);

    // Initial default weight is 68.4 kg -> mascot/weight_51-70kg.png rendered cleanly
    expect(find.byType(Image), findsWidgets);
    expect(find.text('68.4 kg'), findsWidgets);
    expect(find.text('Next: Height →'), findsOneWidget);

    // 2. Switch to Height tab
    await tester.tap(find.text('Height'));
    await tester.pump();

    expect(find.text('172 cm'), findsWidgets);
    expect(find.text('Next: Age →'), findsOneWidget);

    // 3. Switch to Age tab
    await tester.tap(find.text('Age'));
    await tester.pump();

    expect(find.text('25 yrs'), findsWidgets);
    expect(find.text('Next: Activity →'), findsOneWidget);

    // 4. Switch to Activity tab
    await tester.tap(find.text('Activity'));
    await tester.pump();

    expect(find.text('Light Active'), findsOneWidget);
    expect(find.text('Moderate Active'), findsOneWidget);
    expect(find.text('Heavy Active'), findsOneWidget);
    expect(find.text('Sedentary'), findsOneWidget);

    // Scroll to and tap Heavy Active option
    await tester.ensureVisible(find.text('Heavy Active'));
    await tester.pump();
    await tester.tap(find.text('Heavy Active'));
    await tester.pump();

    expect(find.byType(Image), findsWidgets);
  });
}
