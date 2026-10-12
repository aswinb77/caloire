import 'package:flutter_test/flutter_test.dart';
import 'package:mallow/core/formulas/formulas.dart';
import 'package:mallow/core/theme/mallow_characters.dart';

void main() {
  group('Mallow Formulas & Domain Tests', () {
    test('calculateBMR returns correct value for standard profile', () {
      final bmr = MallowFormulas.calculateBMR(
        weightKg: 68.4,
        heightCm: 172.0,
        age: 26,
        isMale: true,
      );
      // (10 * 68.4) + (6.25 * 172) - (5 * 26) + 5 = 684 + 1075 - 130 + 5 = 1634
      expect(bmr, closeTo(1634.0, 0.5));
    });

    test('calculateDailyTarget applies correct deficits and surpluses', () {
      final lose = MallowFormulas.calculateDailyTarget(
        weightKg: 68.4,
        heightCm: 172.0,
        goal: 'lose',
      );
      final steady = MallowFormulas.calculateDailyTarget(
        weightKg: 68.4,
        heightCm: 172.0,
        goal: 'steady',
      );
      final build = MallowFormulas.calculateDailyTarget(
        weightKg: 68.4,
        heightCm: 172.0,
        goal: 'build',
      );

      expect(lose, equals(steady - 300));
      expect(build, equals(steady + 300));
    });

    test('calculateWorkoutBurn calculates gym MET accurately', () {
      // Bench press MET 4.5, 68.4 kg, 45 min = 4.5 * 68.4 * 0.75 = 230.85 -> 231 kcal
      final burn = MallowFormulas.calculateWorkoutBurn(
        met: 4.5,
        weightKg: 68.4,
        minutes: 45,
      );
      expect(burn, equals(231));
    });

    test('calculateBMI returns correct BMI', () {
      final bmi = MallowFormulas.calculateBMI(
        weightKg: 68.4,
        heightCm: 172.0,
      );
      // 68.4 / (1.72 * 1.72) = 23.12
      expect(bmi, closeTo(23.1, 0.1));
    });

    test('evaluatePetMood transitions through all 4 moods properly', () {
      // 1. Sleepy when energy < 30
      final sleepy = MallowFormulas.evaluatePetMood(
        energy: 20,
        joy: 90,
        eatenKcal: 1500,
        targetKcal: 2000,
      );
      expect(sleepy, equals(MallowMood.sleepy));

      // 2. Hungry when eaten < 20% of goal
      final hungry = MallowFormulas.evaluatePetMood(
        energy: 80,
        joy: 60,
        eatenKcal: 200,
        targetKcal: 2000,
      );
      expect(hungry, equals(MallowMood.hungry));

      // 3. Happy when joy >= 70 or eaten 50-105%
      final happyByJoy = MallowFormulas.evaluatePetMood(
        energy: 80,
        joy: 75,
        eatenKcal: 700,
        targetKcal: 2000,
      );
      expect(happyByJoy, equals(MallowMood.happy));

      final happyByFood = MallowFormulas.evaluatePetMood(
        energy: 80,
        joy: 50,
        eatenKcal: 1500,
        targetKcal: 2000,
      );
      expect(happyByFood, equals(MallowMood.happy));

      // 4. Chill otherwise
      final chill = MallowFormulas.evaluatePetMood(
        energy: 80,
        joy: 50,
        eatenKcal: 600, // 30% of goal (not < 20%, not >= 50%)
        targetKcal: 2000,
      );
      expect(chill, equals(MallowMood.chill));
    });
  });
}
