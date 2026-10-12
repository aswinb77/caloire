import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/mallow_theme.dart';
import '../../core/theme/mallow_widgets.dart';
import '../../core/theme/mallow_toast.dart';
import '../../core/providers/providers.dart';

class PlanExercise {
  final String id;
  final String name;
  final String setsReps;
  final String muscleGroup;
  final String imagePath;
  final int burnedKcal;
  final double met;

  const PlanExercise({
    required this.id,
    required this.name,
    required this.setsReps,
    required this.muscleGroup,
    required this.imagePath,
    this.burnedKcal = 55,
    this.met = 5.5,
  });
}

class WorkoutDayPlan {
  final int weekday; // 1: Mon, 2: Tue, 3: Wed, 4: Thu, 5: Fri, 6: Sat, 7: Sun
  final String dayName;
  final String shortDay;
  final String title;
  final String targetMuscles;
  final bool isRestDay;
  final List<PlanExercise> exercises;

  const WorkoutDayPlan({
    required this.weekday,
    required this.dayName,
    required this.shortDay,
    required this.title,
    required this.targetMuscles,
    this.isRestDay = false,
    this.exercises = const [],
  });
}

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  late int _selectedWeekday;

  // Track completed exercise IDs for today (in addition to DB logs)
  final Set<String> _completedExerciseNames = {};

  // 5-DAY GYM WORKOUT PLAN
  final List<WorkoutDayPlan> _weeklyPlans = const [
    // 1. MONDAY: UPPER BODY
    WorkoutDayPlan(
      weekday: 1,
      dayName: 'Monday',
      shortDay: 'Mon',
      title: 'Upper Body',
      targetMuscles: 'Chest • Back • Shoulders • Arms',
      exercises: [
        PlanExercise(
          id: 'mon_1',
          name: 'Incline Dumbbell Press',
          setsReps: '3 × 6–10',
          muscleGroup: 'Upper Chest',
          imagePath: 'assets/workouts/incline_dumbbell_press_upper.png',
          burnedKcal: 65,
        ),
        PlanExercise(
          id: 'mon_2',
          name: 'Lat Pulldown',
          setsReps: '3 × 6–10',
          muscleGroup: 'Lats & Back',
          imagePath: 'assets/workouts/lat_pulldown.png',
          burnedKcal: 60,
        ),
        PlanExercise(
          id: 'mon_3',
          name: 'Bench press',
          setsReps: '3 × 8–12',
          muscleGroup: 'Chest',
          imagePath: 'assets/workouts/bench_press.png',
          burnedKcal: 70,
        ),
        PlanExercise(
          id: 'mon_4',
          name: 'Chest-Supported Row',
          setsReps: '3 × 8–12',
          muscleGroup: 'Upper Back',
          imagePath: 'assets/workouts/chest_supported_row.png',
          burnedKcal: 55,
        ),
        PlanExercise(
          id: 'mon_5',
          name: 'Dumbbell Lateral Raises',
          setsReps: '3 × 12–20',
          muscleGroup: 'Shoulders',
          imagePath: 'assets/workouts/dumbbell_lateral_raise.png',
          burnedKcal: 45,
        ),
        PlanExercise(
          id: 'mon_6',
          name: 'Cable Triceps Pushdown',
          setsReps: '2 × 10–15',
          muscleGroup: 'Triceps',
          imagePath: 'assets/workouts/cable_triceps_pushdown.png',
          burnedKcal: 40,
        ),
        PlanExercise(
          id: 'mon_7',
          name: 'Dumbbell Biceps Curl',
          setsReps: '2 × 10–15',
          muscleGroup: 'Biceps',
          imagePath: 'assets/workouts/dumbbell_curl.png',
          burnedKcal: 40,
        ),
      ],
    ),

    // 2. TUESDAY: LOWER BODY A
    WorkoutDayPlan(
      weekday: 2,
      dayName: 'Tuesday',
      shortDay: 'Tue',
      title: 'Lower Body A',
      targetMuscles: 'Quads • Hamstrings • Calves • Core',
      exercises: [
        PlanExercise(
          id: 'tue_1',
          name: 'Squat',
          setsReps: '3 × 6–10',
          muscleGroup: 'Quads & Glutes',
          imagePath: 'assets/workouts/leg_press.png',
          burnedKcal: 85,
        ),
        PlanExercise(
          id: 'tue_2',
          name: 'Deadlift',
          setsReps: '3 × 8–10',
          muscleGroup: 'Hamstrings & Glutes',
          imagePath: 'assets/workouts/deadlift.png',
          burnedKcal: 90,
        ),
        PlanExercise(
          id: 'tue_3',
          name: 'Leg Extension',
          setsReps: '3 × 10–15',
          muscleGroup: 'Quads',
          imagePath: 'assets/workouts/leg_extension.png',
          burnedKcal: 50,
        ),
        PlanExercise(
          id: 'tue_4',
          name: 'Seated Leg Curl',
          setsReps: '3 × 10–15',
          muscleGroup: 'Hamstrings',
          imagePath: 'assets/workouts/seated_leg_curl.png',
          burnedKcal: 50,
        ),
        PlanExercise(
          id: 'tue_5',
          name: 'Standing Calf Raise',
          setsReps: '3 × 10–15',
          muscleGroup: 'Calves',
          imagePath: 'assets/workouts/standing_calf_raise.png',
          burnedKcal: 40,
        ),
        PlanExercise(
          id: 'tue_6',
          name: 'Cable Crunch',
          setsReps: '3 × 10–15',
          muscleGroup: 'Abs & Core',
          imagePath: 'assets/workouts/cable_crunch.png',
          burnedKcal: 40,
        ),
      ],
    ),

    // 3. WEDNESDAY: PUSH
    WorkoutDayPlan(
      weekday: 3,
      dayName: 'Wednesday',
      shortDay: 'Wed',
      title: 'Push',
      targetMuscles: 'Chest • Shoulders • Triceps',
      exercises: [
        PlanExercise(
          id: 'wed_1',
          name: 'Incline Dumbbell Press',
          setsReps: '3 × 8–12',
          muscleGroup: 'Upper Chest',
          imagePath: 'assets/workouts/incline_dumbbell_press.png',
          burnedKcal: 65,
        ),
        PlanExercise(
          id: 'wed_2',
          name: 'Flat Dumbbell Press',
          setsReps: '3 × 8–12',
          muscleGroup: 'Chest',
          imagePath: 'assets/workouts/flat_dumbbell_press.png',
          burnedKcal: 65,
        ),
        PlanExercise(
          id: 'wed_3',
          name: 'Seated Shoulder Press',
          setsReps: '2 × 8–12',
          muscleGroup: 'Shoulders',
          imagePath: 'assets/workouts/seated_shoulder_press.png',
          burnedKcal: 55,
        ),
        PlanExercise(
          id: 'wed_4',
          name: 'Cable Lateral Raises',
          setsReps: '3 × 12–20',
          muscleGroup: 'Side Delts',
          imagePath: 'assets/workouts/cable_lateral_raise.png',
          burnedKcal: 45,
        ),
        PlanExercise(
          id: 'wed_5',
          name: 'Pec Deck / Cable Fly',
          setsReps: '2 × 12–15',
          muscleGroup: 'Chest Fly',
          imagePath: 'assets/workouts/pec_deck_fly.png',
          burnedKcal: 45,
        ),
        PlanExercise(
          id: 'wed_6',
          name: 'Overhead Cable Triceps Extension',
          setsReps: '3 × 10–15',
          muscleGroup: 'Triceps',
          imagePath: 'assets/workouts/overhead_triceps_extension.png',
          burnedKcal: 45,
        ),
      ],
    ),

    // 4. THURSDAY: REST
    WorkoutDayPlan(
      weekday: 4,
      dayName: 'Thursday',
      shortDay: 'Thu',
      title: 'Active Rest',
      targetMuscles: 'Recovery & Sleep',
      isRestDay: true,
    ),

    // 5. FRIDAY: PULL
    WorkoutDayPlan(
      weekday: 5,
      dayName: 'Friday',
      shortDay: 'Fri',
      title: 'Pull',
      targetMuscles: 'Back • Rear Delts • Biceps',
      exercises: [
        PlanExercise(
          id: 'fri_1',
          name: 'Pull-Ups or Lat Pulldown',
          setsReps: '3 × 8–12',
          muscleGroup: 'Lats & Back',
          imagePath: 'assets/workouts/lat_pulldown.png',
          burnedKcal: 65,
        ),
        PlanExercise(
          id: 'fri_2',
          name: 'Seated Cable Row',
          setsReps: '3 × 8–12',
          muscleGroup: 'Mid Back',
          imagePath: 'assets/workouts/cable_row.png',
          burnedKcal: 60,
        ),
        PlanExercise(
          id: 'fri_3',
          name: 'One-Arm Dumbbell Row',
          setsReps: '2 × 10–12',
          muscleGroup: 'Lats',
          imagePath: 'assets/workouts/one_arm_dumbbell_row.png',
          burnedKcal: 55,
        ),
        PlanExercise(
          id: 'fri_4',
          name: 'Reverse Pec Deck',
          setsReps: '3 × 12–20',
          muscleGroup: 'Rear Delts',
          imagePath: 'assets/workouts/reverse_pec_deck.png',
          burnedKcal: 45,
        ),
        PlanExercise(
          id: 'fri_5',
          name: 'Straight-Arm Cable Pulldown',
          setsReps: '2 × 12–15',
          muscleGroup: 'Lats',
          imagePath: 'assets/workouts/straight_arm_pulldown.png',
          burnedKcal: 40,
        ),
        PlanExercise(
          id: 'fri_6',
          name: 'EZ-Bar Curl',
          setsReps: '3 × 8–12',
          muscleGroup: 'Biceps',
          imagePath: 'assets/workouts/ez_bar_curl.png',
          burnedKcal: 45,
        ),
        PlanExercise(
          id: 'fri_7',
          name: 'Incline Dumbbell Curl',
          setsReps: '2 × 10–15',
          muscleGroup: 'Biceps',
          imagePath: 'assets/workouts/incline_dumbbell_curl.png',
          burnedKcal: 40,
        ),
      ],
    ),

    // 6. SATURDAY: LOWER BODY B + ARMS AND SHOULDERS
    WorkoutDayPlan(
      weekday: 6,
      dayName: 'Saturday',
      shortDay: 'Sat',
      title: 'Lower Body B + Arms',
      targetMuscles: 'Legs • Shoulders • Arms',
      exercises: [
        PlanExercise(
          id: 'sat_1',
          name: 'Hack Squat or Leg Press',
          setsReps: '3 × 8–12',
          muscleGroup: 'Quads',
          imagePath: 'assets/workouts/leg_press.png',
          burnedKcal: 80,
        ),
        PlanExercise(
          id: 'sat_2',
          name: 'Hip Thrust',
          setsReps: '3 × 8–12',
          muscleGroup: 'Glutes',
          imagePath: 'assets/workouts/deadlift.png',
          burnedKcal: 75,
        ),
        PlanExercise(
          id: 'sat_3',
          name: 'Lying Leg Curl',
          setsReps: '3 × 10–15',
          muscleGroup: 'Hamstrings',
          imagePath: 'assets/workouts/seated_leg_curl.png',
          burnedKcal: 50,
        ),
        PlanExercise(
          id: 'sat_4',
          name: 'Bulgarian Split Squat',
          setsReps: '2 × 8–12',
          muscleGroup: 'Legs',
          imagePath: 'assets/workouts/leg_extension.png',
          burnedKcal: 60,
        ),
        PlanExercise(
          id: 'sat_5',
          name: 'Seated Calf Raise',
          setsReps: '3 × 12–20',
          muscleGroup: 'Calves',
          imagePath: 'assets/workouts/standing_calf_raise.png',
          burnedKcal: 40,
        ),
        PlanExercise(
          id: 'sat_6',
          name: 'Hanging Knee Raise',
          setsReps: '3 × 10–15',
          muscleGroup: 'Abs',
          imagePath: 'assets/workouts/cable_crunch.png',
          burnedKcal: 40,
        ),
        PlanExercise(
          id: 'sat_7',
          name: 'Dumbbell Lateral Raise',
          setsReps: '2 × 15–20',
          muscleGroup: 'Shoulders',
          imagePath: 'assets/workouts/dumbbell_lateral_raise.png',
          burnedKcal: 45,
        ),
        PlanExercise(
          id: 'sat_8',
          name: 'Cable Triceps Pushdown',
          setsReps: '2 × 10–15',
          muscleGroup: 'Triceps',
          imagePath: 'assets/workouts/cable_triceps_pushdown.png',
          burnedKcal: 40,
        ),
        PlanExercise(
          id: 'sat_9',
          name: 'Hammer Curl',
          setsReps: '2 × 10–15',
          muscleGroup: 'Arms',
          imagePath: 'assets/workouts/dumbbell_curl.png',
          burnedKcal: 40,
        ),
      ],
    ),

    // 7. SUNDAY: REST
    WorkoutDayPlan(
      weekday: 7,
      dayName: 'Sunday',
      shortDay: 'Sun',
      title: 'Rest',
      targetMuscles: 'Complete Recovery',
      isRestDay: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedWeekday = DateTime.now().weekday;
  }

  WorkoutDayPlan _getPlanForWeekday(int weekday) {
    return _weeklyPlans.firstWhere(
      (p) => p.weekday == weekday,
      orElse: () => _weeklyPlans.first,
    );
  }

  // Toggle exercise as Done with a single tap
  Future<void> _toggleExerciseDone(PlanExercise ex) async {
    final workouts = ref.read(workoutLogsProvider);
    final matching = workouts.where((w) => w.exerciseName == ex.name).toList();
    final isDone = _completedExerciseNames.contains(ex.name) || matching.isNotEmpty;
    final profile = ref.read(profileProvider);

    if (isDone) {
      // Unmark as done
      setState(() {
        _completedExerciseNames.remove(ex.name);
      });
      // Delete all matching logs
      for (final log in matching) {
        await ref.read(workoutLogsProvider.notifier).deleteWorkoutLog(log.id);
      }
      if (mounted) {
        MallowToast.show(context, 'Unmarked ${ex.name}');
      }
    } else {
      // Mark as done & log to provider
      setState(() {
        _completedExerciseNames.add(ex.name);
      });
      await ref.read(workoutLogsProvider.notifier).logWorkout(
        exerciseName: ex.name,
        met: ex.met,
        minutes: 10,
        weightKg: profile.weightKg,
        caloriesBurned: ex.burnedKcal,
        category: 'Gym',
      );
      if (mounted) {
        MallowToast.show(context, '✓ Completed ${ex.name}! (+${ex.burnedKcal} kcal)');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totals = ref.watch(todayTotalsProvider);
    final todayWeekday = DateTime.now().weekday;
    final activePlan = _getPlanForWeekday(_selectedWeekday);

    // Sync completed from DB logs
    final dbWorkouts = ref.watch(workoutLogsProvider);
    final loggedNames = dbWorkouts.map((w) => w.exerciseName).toSet();
    final allCompleted = {..._completedExerciseNames, ...loggedNames};

    final totalExCount = activePlan.exercises.length;
    final completedCount = activePlan.exercises.where((e) => allCompleted.contains(e.name)).length;

    return Scaffold(
      backgroundColor: MallowColors.creamBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Clean Top Bar (No redundant back arrow or 'See Today' button when in bottom nav tab)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (Navigator.canPop(context)) ...[
                        MallowCircleButton(
                          size: 38,
                          onTap: () {
                            try {
                              context.pop();
                            } catch (_) {}
                          },
                          child: const Icon(Icons.arrow_back, size: 20, color: MallowColors.charcoal),
                        ),
                        const SizedBox(width: 10),
                      ],
                      MallowAvatar(
                        size: 38,
                        onTap: () {
                          try {
                            context.go('/pet');
                          } catch (_) {}
                        },
                      ),
                    ],
                  ),
                  // Training Guide Button
                  GestureDetector(
                    onTap: _showTrainingGuideModal,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: MallowColors.borderSubtle),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: MallowColors.charcoal),
                          SizedBox(width: 5),
                          Text(
                            'Guide',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: MallowColors.charcoal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Title Header & Today Calories Burned Pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Workout Plan',
                        style: MallowTypography.headlineMedium(),
                      ),
                      Text(
                        'Tap any card to log as done',
                        style: MallowTypography.bodySmall(
                          color: MallowColors.textSubtle,
                        ),
                      ),
                    ],
                  ),
                  // Burned Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: MallowColors.hotPink,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          '${totals.burnedKcal} kcal',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: MallowColors.charcoal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 1. Weekly Schedule Bar (Mon - Sun)
              _buildWeeklyScheduleBar(todayWeekday),
              const SizedBox(height: 14),

              // 2. Active Day Header (Minimalist & Clean)
              _buildActiveDaySummary(activePlan, todayWeekday, completedCount, totalExCount),
              const SizedBox(height: 12),

              // 3. Clean Interactive Exercise Cards (Tap to Complete)
              if (activePlan.isRestDay)
                _buildRestDayCard()
              else
                _buildExerciseCardsList(activePlan, allCompleted),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 1. Weekly Schedule Bar
  // ==========================================
  Widget _buildWeeklyScheduleBar(int todayWeekday) {
    return SizedBox(
      height: 54,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _weeklyPlans.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final plan = _weeklyPlans[index];
          final isSelected = _selectedWeekday == plan.weekday;
          final isToday = todayWeekday == plan.weekday;

          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => setState(() => _selectedWeekday = plan.weekday),
              child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 52,
              decoration: BoxDecoration(
                color: isSelected
                    ? MallowColors.charcoal
                    : isToday
                        ? MallowColors.hotPinkLight
                        : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? MallowColors.charcoal
                      : isToday
                          ? MallowColors.hotPink
                          : MallowColors.borderSubtle,
                  width: isToday || isSelected ? 2.0 : 1.2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    plan.shortDay,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : isToday
                              ? MallowColors.charcoal
                              : MallowColors.textSubtle,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (isToday)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: isSelected ? MallowColors.hotPink : MallowColors.charcoal,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'TODAY',
                        style: TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.w900,
                          color: isSelected ? MallowColors.charcoal : Colors.white,
                        ),
                      ),
                    )
                  else
                    Text(
                      plan.isRestDay ? '💤' : '💪',
                      style: const TextStyle(fontSize: 11),
                    ),
                ],
              ),
            ),
          ),
        );
      },
      ),
    );
  }

  // ==========================================
  // 2. Minimalist Active Day Summary
  // ==========================================
  Widget _buildActiveDaySummary(
    WorkoutDayPlan plan,
    int todayWeekday,
    int completedCount,
    int totalCount,
  ) {
    final isToday = todayWeekday == plan.weekday;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isToday ? MallowColors.hotPink : MallowColors.borderSubtle,
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${plan.dayName} — ${plan.title}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: MallowColors.charcoal,
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: MallowColors.hotPink,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'TODAY',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  plan.targetMuscles,
                  style: MallowTypography.bodySmall(color: MallowColors.textSubtle),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (!plan.isRestDay)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: completedCount == totalCount && totalCount > 0
                    ? MallowColors.oliveGreenLight
                    : MallowColors.cardCream,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$completedCount / $totalCount Done',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: completedCount == totalCount && totalCount > 0
                      ? MallowColors.oliveGreen
                      : MallowColors.charcoal,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // 3. Clean Exercise Cards (Tap to Log Done)
  // ==========================================
  Widget _buildExerciseCardsList(WorkoutDayPlan plan, Set<String> completedSet) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: plan.exercises.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final ex = plan.exercises[index];
        final isDone = completedSet.contains(ex.name);

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            key: Key('exercise_card_${ex.id}'),
            behavior: HitTestBehavior.opaque,
            onTap: () => _toggleExerciseDone(ex),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDone ? const Color(0xFFF2F9EE) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDone ? MallowColors.oliveGreen : MallowColors.borderSubtle,
                  width: isDone ? 1.8 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Clean Cropped Artwork
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 66,
                      height: 66,
                      color: MallowColors.cardCream,
                      child: Image.asset(
                        ex.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(Icons.fitness_center, size: 28, color: MallowColors.charcoal),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Name and Prescribed Sets x Reps
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ex.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDone ? Colors.grey.shade600 : MallowColors.charcoal,
                            decoration: isDone ? TextDecoration.lineThrough : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            // Sets × Reps Pill
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDone
                                    ? MallowColors.oliveGreenLight
                                    : MallowColors.hotPinkLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                ex.setsReps,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isDone
                                      ? MallowColors.oliveGreen
                                      : MallowColors.charcoal,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),

                            // Muscle Tag
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F3EF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                ex.muscleGroup,
                                style: MallowTypography.bodySmall(
                                  color: MallowColors.textSubtle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Clear, Interactive Checkmark Action Button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isDone ? MallowColors.oliveGreen : const Color(0xFFFBF9F6),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDone ? MallowColors.oliveGreen : const Color(0xFFD6D0C7),
                        width: 1.8,
                      ),
                      boxShadow: isDone
                          ? [
                              BoxShadow(
                                color: MallowColors.oliveGreen.withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.check_rounded,
                        size: 20,
                        color: isDone ? Colors.white : const Color(0xFFD6D0C7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // Rest Day Card (Clean & Minimalist)
  // ==========================================
  Widget _buildRestDayCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: MallowColors.borderSubtle, width: 1.2),
      ),
      child: Column(
        children: [
          const Text('🛌', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 10),
          Text(
            'Rest & Recovery Day',
            style: MallowTypography.headlineSmall(fontSize: 18),
          ),
          const SizedBox(height: 6),
          Text(
            'Muscles grow while resting. Keep nutrition high and sleep well!',
            textAlign: TextAlign.center,
            style: MallowTypography.bodySmall(color: MallowColors.textSubtle),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildRestPill('🚶', '20-30 min walk'),
              const SizedBox(width: 8),
              _buildRestPill('😴', '7-9h sleep'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRestPill(String emoji, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: MallowColors.charcoal,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Training Guide Modal (Clean Bottom Sheet)
  // ==========================================
  void _showTrainingGuideModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: MallowColors.creamBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Training Rules', style: MallowTypography.headlineMedium(fontSize: 20)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              _buildGuideRuleItem(
                icon: '🏃',
                title: 'Warm-up',
                desc: '5–8 mins easy cardio + 2–4 warm-up sets before heavy compound lifts.',
              ),
              _buildGuideRuleItem(
                icon: '⏱️',
                title: 'Rest Periods',
                desc: 'Compound: 2–3 min • Isolation: 60–120 sec.',
              ),
              _buildGuideRuleItem(
                icon: '⚡',
                title: 'Intensity (1–3 RIR)',
                desc: 'Leave 1–3 reps in reserve. Avoid training to failure on every set.',
              ),
              _buildGuideRuleItem(
                icon: '📈',
                title: 'Progressive Overload',
                desc: 'Reach top of rep range with good form, then increase weight slightly.',
              ),
              _buildGuideRuleItem(
                icon: '💤',
                title: 'Sleep & Recovery',
                desc: 'Sleep 7–9 hours. Thursday & Sunday are strict rest days.',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGuideRuleItem({required String icon, required String title, required String desc}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: MallowColors.borderSubtle),
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 16))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: MallowTypography.bodyMedium(weight: FontWeight.bold)),
                Text(desc, style: MallowTypography.bodySmall(color: MallowColors.textSubtle)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
