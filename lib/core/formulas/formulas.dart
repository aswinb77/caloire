import '../theme/mallow_characters.dart';

class MallowFormulas {
  /// Calculate Mifflin-St Jeor BMR
  static double calculateBMR({
    required double weightKg,
    required double heightCm,
    int age = 26,
    bool isMale = true,
  }) {
    if (isMale) {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
    } else {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
    }
  }

  /// Calculate daily target calories based on goal
  static int calculateDailyTarget({
    required double weightKg,
    required double heightCm,
    required String goal, // 'lose', 'steady', 'build'
    double activityFactor = 1.35,
  }) {
    final bmr = calculateBMR(weightKg: weightKg, heightCm: heightCm);
    final tdee = bmr * activityFactor;
    switch (goal.toLowerCase()) {
      case 'lose':
        return (tdee - 300).round();
      case 'build':
        return (tdee + 300).round();
      case 'steady':
      default:
        return tdee.round();
    }
  }

  /// Calculate calories burned from gym MET, weight, and minutes
  /// Formula: MET * weightKg * (minutes / 60)
  static int calculateWorkoutBurn({
    required double met,
    required double weightKg,
    required int minutes,
  }) {
    final hours = minutes / 60.0;
    return (met * weightKg * hours).round();
  }

  /// Calculate calories burned from strength training sets, reps, weight lifted, and user body weight
  static int calculateStrengthBurn({
    required double met,
    required double userWeightKg,
    required int sets,
    required int reps,
    required double weightLiftedKg,
  }) {
    final effectiveMinutes = (sets * 2.5).clamp(5.0, 90.0);
    final baseBurn = met * userWeightKg * (effectiveMinutes / 60.0);
    final totalVolumeKg = sets * reps * weightLiftedKg;
    final volumeBonus = (totalVolumeKg / 1000.0) * 8.5;
    return (baseBurn + volumeBonus).round().clamp(15, 800);
  }

  /// Format the math working for the workout card
  /// e.g. "4.5 × 68.4 kg × 0.50 h = 154 kcal"
  static String formatWorkoutWorking({
    required double met,
    required double weightKg,
    required int minutes,
  }) {
    final hours = (minutes / 60.0).toStringAsFixed(2);
    final burn = calculateWorkoutBurn(met: met, weightKg: weightKg, minutes: minutes);
    return '${met.toStringAsFixed(1)} × ${weightKg.toStringAsFixed(1)} kg × $hours h = $burn kcal';
  }


  /// Calculate BMI
  static double calculateBMI({
    required double weightKg,
    required double heightCm,
  }) {
    final heightM = heightCm / 100.0;
    if (heightM <= 0) return 0.0;
    return weightKg / (heightM * heightM);
  }

  /// Evaluate Mallow's mood based on energy, joy, eaten kcal, and target kcal
  /// Rules in exact order:
  /// 1. Sleepy: energy is below 30.
  /// 2. Hungry: you've eaten less than 20% of your goal.
  /// 3. Happy: joy is 70 or more, or you've eaten 50–105% of your goal.
  /// 4. Chill: anything else.
  static MallowMood evaluatePetMood({
    required int energy,
    required int joy,
    required int eatenKcal,
    required int targetKcal,
  }) {
    if (energy < 30) {
      return MallowMood.sleepy;
    }
    
    final ratio = targetKcal > 0 ? (eatenKcal / targetKcal) : 0.0;
    if (ratio < 0.20) {
      return MallowMood.hungry;
    }
    
    if (joy >= 70 || (ratio >= 0.50 && ratio <= 1.05)) {
      return MallowMood.happy;
    }
    
    return MallowMood.chill;
  }
}
