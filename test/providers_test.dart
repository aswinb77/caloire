import 'package:flutter_test/flutter_test.dart';
import 'package:mallow/core/models/models.dart';
import 'package:mallow/core/providers/providers.dart';

void main() {
  group('Fresh User & Logging Tests', () {
    test('FoodItem equality and hashCode work correctly with id', () {
      const food1 = FoodItem(
        id: '1',
        name: 'Banana',
        calories: 105,
        proteinG: 1.3,
        servingLabel: 'for 1 medium',
        category: 'Fruit',
        emoji: '🍌',
      );
      const food2 = FoodItem(
        id: '1',
        name: 'Banana',
        calories: 105,
        proteinG: 1.3,
        servingLabel: 'for 1 medium',
        category: 'Fruit',
        emoji: '🍌',
      );
      expect(food1, equals(food2));
      expect(food1.hashCode, equals(food2.hashCode));
    });

    test('StreakNotifier starts at Day 1 and saves today on tap', () {
      final notifier = StreakNotifier();
      expect(notifier.state.streakDays, equals(1));
      expect(notifier.state.savedToday, isFalse);

      notifier.saveToday();
      expect(notifier.state.savedToday, isTrue);
    });

    test('TodayTotals calculates totals accurately from zero', () {
      const initial = TodayTotals();
      expect(initial.eatenKcal, equals(0));
      expect(initial.burnedKcal, equals(0));
      expect(initial.proteinG, equals(0.0));
    });
  });
}
