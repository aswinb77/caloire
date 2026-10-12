import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../database/database_helper.dart';
import '../formulas/formulas.dart';
import '../theme/mallow_characters.dart';

// 1. Database Provider
final dbProvider = Provider<DatabaseHelper>((ref) => DatabaseHelper.instance);

// 2. Profile StateNotifier
class ProfileNotifier extends StateNotifier<UserProfile> {
  final DatabaseHelper _db;

  ProfileNotifier(this._db) : super(const UserProfile()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final p = await _db.getProfile();
      state = p;
    } catch (_) {}
  }

  Future<void> setGoal(String goal) async {
    int target = 2000;
    if (goal == 'lose') {
      target = 1700;
    } else if (goal == 'build') {
      target = 2300;
    } else {
      target = 2000;
    }
    final updated = state.copyWith(goal: goal, dailyTargetKcal: target);
    state = updated;
    try {
      await _db.updateProfile(updated);
    } catch (_) {}
  }

  Future<void> updateWeight(double newWeight) async {
    final clamped = newWeight.clamp(40.0, 180.0);
    final rounded = double.parse(clamped.toStringAsFixed(1));
    final updated = state.copyWith(weightKg: rounded);
    state = updated;
    try {
      await _db.updateProfile(updated);
    } catch (_) {}
  }

  Future<void> updateHeight(double heightCm) async {
    final updated = state.copyWith(heightCm: heightCm);
    state = updated;
    try {
      await _db.updateProfile(updated);
    } catch (_) {}
  }

  Future<void> updateWaist(double waistCm) async {
    final updated = state.copyWith(waistCm: waistCm);
    state = updated;
    try {
      await _db.updateProfile(updated);
    } catch (_) {}
  }

  Future<void> updateTargetWeight(double targetWeightKg) async {
    final updated = state.copyWith(targetWeightKg: targetWeightKg);
    state = updated;
    try {
      await _db.updateProfile(updated);
    } catch (_) {}
  }

  Future<void> updateProfile(UserProfile profile) async {
    state = profile;
    try {
      await _db.updateProfile(profile);
    } catch (_) {}
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, UserProfile>((ref) {
  return ProfileNotifier(ref.watch(dbProvider));
});

// 3. Meal Logs Notifier
class MealLogsNotifier extends StateNotifier<List<MealLog>> {
  final DatabaseHelper _db;
  final Ref _ref;

  MealLogsNotifier(this._db, this._ref) : super([]) {
    _load();
  }

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _load() async {
    final logs = await _db.getMealLogsForDate(_todayStr());
    state = logs;
  }

  Future<void> logFood({
    required String mealType,
    required FoodItem food,
    int quantity = 1,
  }) async {
    final log = MealLog(
      id: const Uuid().v4(),
      date: _todayStr(),
      mealType: mealType,
      foodItemId: food.id,
      foodName: food.name,
      calories: food.calories * quantity,
      proteinG: food.proteinG * quantity,
      quantity: quantity,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    state = [...state, log];
    _ref.read(undoStackProvider.notifier).pushUndo(log);
    try {
      await _db.insertMealLog(log);
    } catch (_) {}
  }

  Future<void> logBatchFoods({
    required String mealType,
    required Map<FoodItem, int> items,
  }) async {
    for (final entry in items.entries) {
      if (entry.value > 0) {
        await logFood(
          mealType: mealType,
          food: entry.key,
          quantity: entry.value,
        );
      }
    }
  }

  Future<MealLog?> undoLast() async {
    if (state.isEmpty) return null;
    final lastLog = state.last;
    state = state.sublist(0, state.length - 1);
    try {
      await _db.deleteMealLog(lastLog.id);
    } catch (_) {}
    return lastLog;
  }
}

final mealLogsProvider = StateNotifierProvider<MealLogsNotifier, List<MealLog>>((ref) {
  return MealLogsNotifier(ref.watch(dbProvider), ref);
});

// 4. Undo Stack Provider
class UndoStackNotifier extends StateNotifier<List<MealLog>> {
  UndoStackNotifier() : super([]);

  void pushUndo(MealLog log) {
    state = [...state, log];
  }

  MealLog? popUndo() {
    if (state.isEmpty) return null;
    final last = state.last;
    state = state.sublist(0, state.length - 1);
    return last;
  }
}

final undoStackProvider = StateNotifierProvider<UndoStackNotifier, List<MealLog>>((ref) {
  return UndoStackNotifier();
});

// 5. Workout Logs Notifier
class WorkoutLogsNotifier extends StateNotifier<List<WorkoutLog>> {
  final DatabaseHelper _db;

  WorkoutLogsNotifier(this._db) : super([]) {
    _load();
  }

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _load() async {
    final logs = await _db.getWorkoutLogsForDate(_todayStr());
    state = logs;
  }

  Future<void> logWorkout({
    required String exerciseName,
    required double met,
    required int minutes,
    required double weightKg,
    int? caloriesBurned,
    String? category,
  }) async {
    final burn = caloriesBurned ?? MallowFormulas.calculateWorkoutBurn(
      met: met,
      weightKg: weightKg,
      minutes: minutes,
    );
    final log = WorkoutLog(
      id: const Uuid().v4(),
      date: _todayStr(),
      exerciseName: exerciseName,
      category: category ?? 'Gym',
      met: met,
      minutes: minutes,
      caloriesBurned: burn,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    state = [log, ...state];
    try {
      await _db.insertWorkoutLog(log);
    } catch (_) {}
  }

  Future<void> deleteWorkoutLog(String id) async {
    state = state.where((w) => w.id != id).toList();
    try {
      await _db.deleteWorkoutLog(id);
    } catch (_) {}
  }
}


final workoutLogsProvider = StateNotifierProvider<WorkoutLogsNotifier, List<WorkoutLog>>((ref) {
  return WorkoutLogsNotifier(ref.watch(dbProvider));
});

// 6. Weight Logs Notifier
class WeightLogsNotifier extends StateNotifier<List<WeightLog>> {
  final DatabaseHelper _db;
  final Ref _ref;

  WeightLogsNotifier(this._db, this._ref) : super([]) {
    _load();
  }

  Future<void> _load() async {
    final logs = await _db.getWeightHistory();
    state = logs;
  }

  Future<void> logWeight(double newWeight) async {
    final clamped = newWeight.clamp(45.0, 120.0);
    final rounded = double.parse(clamped.toStringAsFixed(1));
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    
    final log = WeightLog(
      id: const Uuid().v4(),
      date: dateStr,
      weightKg: rounded,
      createdAt: now.millisecondsSinceEpoch,
    );
    await _db.insertWeightLog(log);
    state = [...state, log];
    await _ref.read(profileProvider.notifier).updateWeight(rounded);
  }
}

final weightLogsProvider = StateNotifierProvider<WeightLogsNotifier, List<WeightLog>>((ref) {
  return WeightLogsNotifier(ref.watch(dbProvider), ref);
});

// 7. Pet State Notifier
class PetStateNotifier extends StateNotifier<PetStateData> {
  final DatabaseHelper _db;

  PetStateNotifier(this._db) : super(PetStateData(lastUpdated: DateTime.now().millisecondsSinceEpoch)) {
    _load();
  }

  Future<void> _load() async {
    final s = await _db.getPetState();
    state = s;
  }

  Future<void> play() async {
    final newJoy = (state.joy + 15).clamp(0, 100);
    final newEnergy = (state.energy - 20).clamp(0, 100);
    final updated = state.copyWith(joy: newJoy, energy: newEnergy, lastUpdated: DateTime.now().millisecondsSinceEpoch);
    state = updated;
    await _db.updatePetState(updated);
  }

  Future<void> rest() async {
    final newEnergy = (state.energy + 30).clamp(0, 100);
    final updated = state.copyWith(energy: newEnergy, lastUpdated: DateTime.now().millisecondsSinceEpoch);
    state = updated;
    await _db.updatePetState(updated);
  }
}

final petStateProvider = StateNotifierProvider<PetStateNotifier, PetStateData>((ref) {
  return PetStateNotifier(ref.watch(dbProvider));
});

// 8. Foods Notifier
class FoodsNotifier extends StateNotifier<List<FoodItem>> {
  final DatabaseHelper _db;

  FoodsNotifier(this._db) : super(kDefaultFoodItems) {
    _load();
  }

  Future<void> _load() async {
    final foods = await _db.getFoods();
    if (foods.isNotEmpty) {
      state = foods;
    } else {
      for (final f in kDefaultFoodItems) {
        await _db.insertFood(f);
      }
      state = kDefaultFoodItems;
    }
  }

  Future<FoodItem> addCustomFood({
    required String name,
    required int calories,
    required double proteinG,
  }) async {
    final food = FoodItem(
      id: const Uuid().v4(),
      name: name,
      calories: calories,
      proteinG: proteinG,
      servingLabel: '1 serving',
      category: 'Protein',
      emoji: '🥗',
      isCustom: true,
    );
    try {
      await _db.insertFood(food);
    } catch (_) {}
    state = [...state, food];
    return food;
  }
}

final foodsProvider = StateNotifierProvider<FoodsNotifier, List<FoodItem>>((ref) {
  return FoodsNotifier(ref.watch(dbProvider));
});

// 9. Derived Today Totals Provider
class TodayTotals {
  final int eatenKcal;
  final double proteinG;
  final int burnedKcal;
  final int breakfastKcal;
  final int lunchKcal;
  final int dinnerKcal;
  final int snackKcal;

  const TodayTotals({
    this.eatenKcal = 0,
    this.proteinG = 0.0,
    this.burnedKcal = 0,
    this.breakfastKcal = 0,
    this.lunchKcal = 0,
    this.dinnerKcal = 0,
    this.snackKcal = 0,
  });
}

final todayTotalsProvider = Provider<TodayTotals>((ref) {
  final mealLogs = ref.watch(mealLogsProvider);
  final workoutLogs = ref.watch(workoutLogsProvider);

  int eaten = 0;
  double protein = 0.0;
  int bfast = 0;
  int lunch = 0;
  int dinner = 0;
  int snack = 0;

  for (final log in mealLogs) {
    eaten += log.calories;
    protein += log.proteinG;
    switch (log.mealType.toLowerCase()) {
      case 'breakfast':
        bfast += log.calories;
        break;
      case 'lunch':
        lunch += log.calories;
        break;
      case 'dinner':
        dinner += log.calories;
        break;
      case 'snack':
        snack += log.calories;
        break;
    }
  }

  int burned = 0;
  for (final w in workoutLogs) {
    burned += w.caloriesBurned;
  }

  return TodayTotals(
    eatenKcal: eaten,
    proteinG: protein,
    burnedKcal: burned,
    breakfastKcal: bfast,
    lunchKcal: lunch,
    dinnerKcal: dinner,
    snackKcal: snack,
  );
});

// 10. Derived Remaining Provider
class RemainingData {
  final int dailyTarget;
  final int totalBudget; // target + burned
  final int remainingKcal;
  final bool isOver;
  final double remainingProtein;

  const RemainingData({
    required this.dailyTarget,
    required this.totalBudget,
    required this.remainingKcal,
    required this.isOver,
    required this.remainingProtein,
  });
}

final remainingProvider = Provider<RemainingData>((ref) {
  final profile = ref.watch(profileProvider);
  final totals = ref.watch(todayTotalsProvider);

  final totalBudget = profile.dailyTargetKcal + totals.burnedKcal;
  final remaining = totalBudget - totals.eatenKcal;
  final remProtein = (profile.proteinGoalG - totals.proteinG).clamp(0.0, 999.0);

  return RemainingData(
    dailyTarget: profile.dailyTargetKcal,
    totalBudget: totalBudget,
    remainingKcal: remaining,
    isOver: remaining < 0,
    remainingProtein: remProtein,
  );
});

// 11. Pet Mood Derived Provider
final petMoodProvider = Provider<MallowMood>((ref) {
  final petState = ref.watch(petStateProvider);
  final totals = ref.watch(todayTotalsProvider);
  final profile = ref.watch(profileProvider);

  return MallowFormulas.evaluatePetMood(
    energy: petState.energy,
    joy: petState.joy,
    eatenKcal: totals.eatenKcal,
    targetKcal: profile.dailyTargetKcal,
  );
});

// 12. Suggestions Derived Provider
class SuggestionCardData {
  final String title;
  final String subtitle;
  final bool isOlive; // true = olive card, false = slate blue or white

  const SuggestionCardData({
    required this.title,
    required this.subtitle,
    required this.isOlive,
  });
}

final suggestionsProvider = Provider<List<SuggestionCardData>>((ref) {
  final remaining = ref.watch(remainingProvider);
  final list = <SuggestionCardData>[];

  // Meal suggestion rule
  if (remaining.remainingKcal > 600) {
    list.add(const SuggestionCardData(
      title: 'Dinner idea',
      subtitle: 'Salmon and rice fits, about 420 kcal.',
      isOlive: true,
    ));
  } else if (remaining.remainingKcal >= 0) {
    list.add(const SuggestionCardData(
      title: 'Light snack',
      subtitle: 'Greek yogurt or a sliced apple fits, about 110 kcal.',
      isOlive: true,
    ));
  } else {
    final over = remaining.remainingKcal.abs();
    final walkMins = (over / 4.5).round();
    list.add(SuggestionCardData(
      title: 'Take a stroll',
      subtitle: 'Burn off the extra $over kcal with a $walkMins-minute walk.',
      isOlive: true,
    ));
  }

  // Protein suggestion rule
  if (remaining.remainingProtein > 25.0) {
    list.add(SuggestionCardData(
      title: 'Protein boost',
      subtitle: '${remaining.remainingProtein.round()} g to go. Try Greek yogurt or eggs.',
      isOlive: false,
    ));
  } else {
    list.add(const SuggestionCardData(
      title: 'Protein on track',
      subtitle: 'Great job! You are hitting your daily protein target.',
      isOlive: false,
    ));
  }

  // Always show Hydrate
  list.add(const SuggestionCardData(
    title: 'Hydrate',
    subtitle: 'Keep your energy high with a cool glass of water.',
    isOlive: true,
  ));

  return list;
});

// 13. Streak Provider for New User
class StreakState {
  final int streakDays;
  final bool savedToday;

  const StreakState({
    this.streakDays = 1,
    this.savedToday = false,
  });

  StreakState copyWith({int? streakDays, bool? savedToday}) {
    return StreakState(
      streakDays: streakDays ?? this.streakDays,
      savedToday: savedToday ?? this.savedToday,
    );
  }
}

class StreakNotifier extends StateNotifier<StreakState> {
  StreakNotifier() : super(const StreakState(streakDays: 1, savedToday: false));

  void saveToday() {
    state = state.copyWith(savedToday: true);
  }
}

final streakProvider = StateNotifierProvider<StreakNotifier, StreakState>((ref) {
  return StreakNotifier();
});
