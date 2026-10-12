import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/mallow_theme.dart';
import '../../core/theme/mallow_widgets.dart';
import '../../core/theme/mallow_toast.dart';
import '../../core/formulas/formulas.dart';
import '../../core/providers/providers.dart';
import '../../core/models/models.dart';

// Model for an exercise in the 5-day split plan
class PlanExercise {
  final String name;
  final String setsReps;
  final String muscleGroup;
  final String imagePath;
  final int defaultSets;
  final int defaultReps;
  final double defaultWeightKg;
  final double met;
  final String tip;

  const PlanExercise({
    required this.name,
    required this.setsReps,
    required this.muscleGroup,
    required this.imagePath,
    required this.defaultSets,
    required this.defaultReps,
    required this.defaultWeightKg,
    this.met = 5.5,
    required this.tip,
  });
}

// Model for each day of the 5-day split
class WorkoutDayPlan {
  final int weekday; // 1: Mon, 2: Tue, 3: Wed, 4: Thu, 5: Fri, 6: Sat, 7: Sun
  final String dayName;
  final String shortDay;
  final String title;
  final String subtitle;
  final String targetMuscles;
  final bool isRestDay;
  final String? restAdvice;
  final List<PlanExercise> exercises;

  const WorkoutDayPlan({
    required this.weekday,
    required this.dayName,
    required this.shortDay,
    required this.title,
    required this.subtitle,
    required this.targetMuscles,
    this.isRestDay = false,
    this.restAdvice,
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
  late PlanExercise _selectedExercise;

  // Active strength workout parameters
  int _sets = 3;
  int _reps = 10;
  double _weightKg = 50.0;

  // 5-DAY GYM WORKOUT PLAN DATA
  final List<WorkoutDayPlan> _weeklyPlans = const [
    // 1. MONDAY: UPPER BODY
    WorkoutDayPlan(
      weekday: 1,
      dayName: 'Monday',
      shortDay: 'Mon',
      title: 'Upper Body',
      subtitle: 'Broader Shoulders, Fuller Chest & Wider Back',
      targetMuscles: 'Chest • Upper Back • Shoulders • Arms',
      exercises: [
        PlanExercise(
          name: 'Incline Dumbbell Press',
          setsReps: '3 × 6–10',
          muscleGroup: 'Upper Chest',
          imagePath: 'assets/workouts/incline_dumbbell_press_upper.png',
          defaultSets: 3,
          defaultReps: 8,
          defaultWeightKg: 24.0,
          met: 5.5,
          tip: '30° incline bench, 2–3m rest',
        ),
        PlanExercise(
          name: 'Lat Pulldown or Pull-Ups',
          setsReps: '3 × 6–10',
          muscleGroup: 'Lats & V-Taper Back',
          imagePath: 'assets/workouts/lat_pulldown.png',
          defaultSets: 3,
          defaultReps: 8,
          defaultWeightKg: 55.0,
          met: 6.0,
          tip: 'Full stretch at top, pull to upper chest',
        ),
        PlanExercise(
          name: 'Bench press',
          setsReps: '3 × 8–12',
          muscleGroup: 'Mid/Lower Chest',
          imagePath: 'assets/workouts/bench_press.png',
          defaultSets: 3,
          defaultReps: 10,
          defaultWeightKg: 60.0,
          met: 5.5,
          tip: 'Controlled descent, plant your feet firmly',
        ),
        PlanExercise(
          name: 'Chest-Supported Row',
          setsReps: '3 × 8–12',
          muscleGroup: 'Upper Back & Rhomboids',
          imagePath: 'assets/workouts/chest_supported_row.png',
          defaultSets: 3,
          defaultReps: 10,
          defaultWeightKg: 40.0,
          met: 5.0,
          tip: 'Squeeze shoulder blades together at peak',
        ),
        PlanExercise(
          name: 'Dumbbell Lateral Raises',
          setsReps: '3 × 12–20',
          muscleGroup: 'Side Delts',
          imagePath: 'assets/workouts/dumbbell_lateral_raise.png',
          defaultSets: 3,
          defaultReps: 15,
          defaultWeightKg: 10.0,
          met: 4.5,
          tip: 'Strict form, lead slightly with elbows',
        ),
        PlanExercise(
          name: 'Cable Triceps Pushdown',
          setsReps: '2 × 10–15',
          muscleGroup: 'Triceps Lateral & Medial Head',
          imagePath: 'assets/workouts/cable_triceps_pushdown.png',
          defaultSets: 2,
          defaultReps: 12,
          defaultWeightKg: 25.0,
          met: 4.5,
          tip: 'Pin elbows to ribs, lock out at bottom',
        ),
        PlanExercise(
          name: 'Dumbbell Biceps Curl',
          setsReps: '2 × 10–15',
          muscleGroup: 'Biceps Brachii',
          imagePath: 'assets/workouts/dumbbell_curl.png',
          defaultSets: 2,
          defaultReps: 12,
          defaultWeightKg: 14.0,
          met: 4.0,
          tip: 'Supinate wrist as you curl upward',
        ),
      ],
    ),

    // 2. TUESDAY: LOWER BODY A
    WorkoutDayPlan(
      weekday: 2,
      dayName: 'Tuesday',
      shortDay: 'Tue',
      title: 'Lower Body A',
      subtitle: 'Quad Strength, Hamstrings & Calves',
      targetMuscles: 'Quads • Glutes • Hamstrings • Calves • Core',
      exercises: [
        PlanExercise(
          name: 'Squat',
          setsReps: '3 × 6–10',
          muscleGroup: 'Quads & Glutes',
          imagePath: 'assets/workouts/leg_press.png',
          defaultSets: 3,
          defaultReps: 8,
          defaultWeightKg: 80.0,
          met: 6.0,
          tip: 'Back Squat or Leg Press, 2–3m rest',
        ),
        PlanExercise(
          name: 'Deadlift',
          setsReps: '3 × 8–10',
          muscleGroup: 'Hamstrings & Posterior Chain',
          imagePath: 'assets/workouts/deadlift.png',
          defaultSets: 3,
          defaultReps: 8,
          defaultWeightKg: 85.0,
          met: 6.5,
          tip: 'Romanian Deadlift, hinge at hips',
        ),
        PlanExercise(
          name: 'Leg Extension',
          setsReps: '3 × 10–15',
          muscleGroup: 'Quadriceps Isolation',
          imagePath: 'assets/workouts/leg_extension.png',
          defaultSets: 3,
          defaultReps: 12,
          defaultWeightKg: 45.0,
          met: 5.0,
          tip: 'Pause for 1 sec at top contraction',
        ),
        PlanExercise(
          name: 'Seated Leg Curl',
          setsReps: '3 × 10–15',
          muscleGroup: 'Hamstrings',
          imagePath: 'assets/workouts/seated_leg_curl.png',
          defaultSets: 3,
          defaultReps: 12,
          defaultWeightKg: 40.0,
          met: 5.0,
          tip: 'Controlled eccentric return, feel the burn',
        ),
        PlanExercise(
          name: 'Standing Calf Raise',
          setsReps: '3 × 10–15',
          muscleGroup: 'Gastrocnemius Calves',
          imagePath: 'assets/workouts/standing_calf_raise.png',
          defaultSets: 3,
          defaultReps: 12,
          defaultWeightKg: 50.0,
          met: 4.5,
          tip: 'Full stretch at bottom, press onto balls of feet',
        ),
        PlanExercise(
          name: 'Cable Crunch',
          setsReps: '3 × 10–15',
          muscleGroup: 'Rectus Abdominis',
          imagePath: 'assets/workouts/cable_crunch.png',
          defaultSets: 3,
          defaultReps: 12,
          defaultWeightKg: 30.0,
          met: 4.5,
          tip: 'Flex spine downwards, do not pull with hips',
        ),
      ],
    ),

    // 3. WEDNESDAY: PUSH
    WorkoutDayPlan(
      weekday: 3,
      dayName: 'Wednesday',
      shortDay: 'Wed',
      title: 'Push',
      subtitle: 'Chest Hypertrophy, Shoulders & Triceps',
      targetMuscles: 'Chest • Shoulders • Triceps',
      exercises: [
        PlanExercise(
          name: 'Incline Dumbbell Press',
          setsReps: '3 × 8–12',
          muscleGroup: 'Upper Chest',
          imagePath: 'assets/workouts/incline_dumbbell_press.png',
          defaultSets: 3,
          defaultReps: 10,
          defaultWeightKg: 22.0,
          met: 5.5,
          tip: 'Incline Machine or DB press, 2–3m rest',
        ),
        PlanExercise(
          name: 'Flat Dumbbell Press',
          setsReps: '3 × 8–12',
          muscleGroup: 'Overall Chest',
          imagePath: 'assets/workouts/flat_dumbbell_press.png',
          defaultSets: 3,
          defaultReps: 10,
          defaultWeightKg: 26.0,
          met: 5.5,
          tip: 'Slight arch in back, drive feet into ground',
        ),
        PlanExercise(
          name: 'Seated Shoulder Press',
          setsReps: '2 × 8–12',
          muscleGroup: 'Anterior & Lateral Delts',
          imagePath: 'assets/workouts/seated_shoulder_press.png',
          defaultSets: 2,
          defaultReps: 10,
          defaultWeightKg: 20.0,
          met: 5.0,
          tip: 'Press straight overhead without flaring elbows',
        ),
        PlanExercise(
          name: 'Cable Lateral Raises',
          setsReps: '3 × 12–20',
          muscleGroup: 'Side Delts Width',
          imagePath: 'assets/workouts/cable_lateral_raise.png',
          defaultSets: 3,
          defaultReps: 15,
          defaultWeightKg: 8.0,
          met: 4.5,
          tip: 'Continuous tension from bottom to shoulder height',
        ),
        PlanExercise(
          name: 'Pec Deck / Cable Fly',
          setsReps: '2 × 12–15',
          muscleGroup: 'Inner/Mid Chest Isolation',
          imagePath: 'assets/workouts/pec_deck_fly.png',
          defaultSets: 2,
          defaultReps: 12,
          defaultWeightKg: 35.0,
          met: 4.5,
          tip: 'Think of hugging a big barrel, chest out',
        ),
        PlanExercise(
          name: 'Overhead Cable Triceps Extension',
          setsReps: '3 × 10–15',
          muscleGroup: 'Triceps Long Head',
          imagePath: 'assets/workouts/overhead_triceps_extension.png',
          defaultSets: 3,
          defaultReps: 12,
          defaultWeightKg: 22.0,
          met: 4.5,
          tip: 'Get a deep stretch behind neck, flare elbows slightly',
        ),
      ],
    ),

    // 4. THURSDAY: REST
    WorkoutDayPlan(
      weekday: 4,
      dayName: 'Thursday',
      shortDay: 'Thu',
      title: 'Rest & Recovery',
      subtitle: 'Light Walking, Mobility & Sleep',
      targetMuscles: 'Active Recovery • CNS Rebuild',
      isRestDay: true,
      restAdvice:
          '• Light walking (20–30 mins)\n• Optional mobility & foam rolling\n• Prioritize 7–9 hours sleep & hydration',
    ),

    // 5. FRIDAY: PULL
    WorkoutDayPlan(
      weekday: 5,
      dayName: 'Friday',
      shortDay: 'Fri',
      title: 'Pull',
      subtitle: 'V-Taper Back, Rear Delts & Biceps',
      targetMuscles: 'Lats • Rhomboids • Rear Delts • Biceps',
      exercises: [
        PlanExercise(
          name: 'Pull-Ups or Lat Pulldown',
          setsReps: '3 × 8–12',
          muscleGroup: 'Lats Width',
          imagePath: 'assets/workouts/lat_pulldown.png',
          defaultSets: 3,
          defaultReps: 10,
          defaultWeightKg: 55.0,
          met: 6.0,
          tip: 'Pull elbows down toward back pockets',
        ),
        PlanExercise(
          name: 'Seated Cable Row',
          setsReps: '3 × 8–12',
          muscleGroup: 'Mid Back Thickness',
          imagePath: 'assets/workouts/cable_row.png',
          defaultSets: 3,
          defaultReps: 10,
          defaultWeightKg: 50.0,
          met: 5.5,
          tip: 'Chest tall, squeeze shoulder blades',
        ),
        PlanExercise(
          name: 'One-Arm Dumbbell Row',
          setsReps: '2 × 10–12 per side',
          muscleGroup: 'Unilateral Lats & Back',
          imagePath: 'assets/workouts/one_arm_dumbbell_row.png',
          defaultSets: 2,
          defaultReps: 10,
          defaultWeightKg: 24.0,
          met: 5.0,
          tip: 'Pull towards hip, avoid twisting torso',
        ),
        PlanExercise(
          name: 'Reverse Pec Deck',
          setsReps: '3 × 12–20',
          muscleGroup: 'Rear Delts & Upper Traps',
          imagePath: 'assets/workouts/reverse_pec_deck.png',
          defaultSets: 3,
          defaultReps: 15,
          defaultWeightKg: 30.0,
          met: 4.5,
          tip: 'Knuckles pointing forward, lead with back of arms',
        ),
        PlanExercise(
          name: 'Straight-Arm Cable Pulldown',
          setsReps: '2 × 12–15',
          muscleGroup: 'Lats Isolation',
          imagePath: 'assets/workouts/straight_arm_pulldown.png',
          defaultSets: 2,
          defaultReps: 12,
          defaultWeightKg: 25.0,
          met: 4.5,
          tip: 'Slight forward lean, keep arms almost straight',
        ),
        PlanExercise(
          name: 'EZ-Bar Curl',
          setsReps: '3 × 8–12',
          muscleGroup: 'Biceps Peak',
          imagePath: 'assets/workouts/ez_bar_curl.png',
          defaultSets: 3,
          defaultReps: 10,
          defaultWeightKg: 25.0,
          met: 4.5,
          tip: 'Comfortable wrist angle on cambered bar',
        ),
        PlanExercise(
          name: 'Incline Dumbbell Curl',
          setsReps: '2 × 10–15',
          muscleGroup: 'Long Head Biceps',
          imagePath: 'assets/workouts/incline_dumbbell_curl.png',
          defaultSets: 2,
          defaultReps: 12,
          defaultWeightKg: 12.0,
          met: 4.0,
          tip: 'Great stretch at the bottom of the movement',
        ),
      ],
    ),

    // 6. SATURDAY: LOWER BODY B + ARMS & SHOULDERS
    WorkoutDayPlan(
      weekday: 6,
      dayName: 'Saturday',
      shortDay: 'Sat',
      title: 'Lower Body B + Arms & Shoulders',
      subtitle: 'Leg Hypertrophy & Direct Arm/Delt Work',
      targetMuscles: 'Legs • Shoulders • Arms',
      exercises: [
        PlanExercise(
          name: 'Hack Squat or Leg Press',
          setsReps: '3 × 8–12',
          muscleGroup: 'Quad Hypertrophy',
          imagePath: 'assets/workouts/leg_press.png',
          defaultSets: 3,
          defaultReps: 10,
          defaultWeightKg: 110.0,
          met: 5.5,
          tip: 'Deep controlled knee flexion, smooth drive',
        ),
        PlanExercise(
          name: 'Hip Thrust',
          setsReps: '3 × 8–12',
          muscleGroup: 'Glutes & Hamstrings',
          imagePath: 'assets/workouts/deadlift.png',
          defaultSets: 3,
          defaultReps: 10,
          defaultWeightKg: 70.0,
          met: 5.5,
          tip: 'Drive through heels, squeeze glutes at the top',
        ),
        PlanExercise(
          name: 'Lying Leg Curl',
          setsReps: '3 × 10–15',
          muscleGroup: 'Hamstrings',
          imagePath: 'assets/workouts/seated_leg_curl.png',
          defaultSets: 3,
          defaultReps: 12,
          defaultWeightKg: 35.0,
          met: 5.0,
          tip: 'Keep hips pressed into bench, do not heave',
        ),
        PlanExercise(
          name: 'Bulgarian Split Squat',
          setsReps: '2 × 8–12 per leg',
          muscleGroup: 'Unilateral Quads & Glutes',
          imagePath: 'assets/workouts/leg_extension.png',
          defaultSets: 2,
          defaultReps: 10,
          defaultWeightKg: 16.0,
          met: 5.5,
          tip: 'Focus on front leg balance and depth',
        ),
        PlanExercise(
          name: 'Seated Calf Raise',
          setsReps: '3 × 12–20',
          muscleGroup: 'Soleus Calves',
          imagePath: 'assets/workouts/standing_calf_raise.png',
          defaultSets: 3,
          defaultReps: 15,
          defaultWeightKg: 40.0,
          met: 4.5,
          tip: 'Pause at bottom for full tendon stretch',
        ),
        PlanExercise(
          name: 'Hanging Knee Raise',
          setsReps: '3 × 10–15',
          muscleGroup: 'Lower Abs',
          imagePath: 'assets/workouts/cable_crunch.png',
          defaultSets: 3,
          defaultReps: 12,
          defaultWeightKg: 0.0,
          met: 4.5,
          tip: 'Curl pelvis up towards ribs without swinging',
        ),
        PlanExercise(
          name: 'Dumbbell Lateral Raise',
          setsReps: '2 × 15–20',
          muscleGroup: 'Side Delts',
          imagePath: 'assets/workouts/dumbbell_lateral_raise.png',
          defaultSets: 2,
          defaultReps: 15,
          defaultWeightKg: 10.0,
          met: 4.5,
          tip: 'High rep burn to stimulate shoulder caps',
        ),
        PlanExercise(
          name: 'Cable Triceps Pushdown',
          setsReps: '2 × 10–15',
          muscleGroup: 'Triceps',
          imagePath: 'assets/workouts/cable_triceps_pushdown.png',
          defaultSets: 2,
          defaultReps: 12,
          defaultWeightKg: 25.0,
          met: 4.5,
          tip: 'Strict form, full squeeze at bottom',
        ),
        PlanExercise(
          name: 'Hammer Curl',
          setsReps: '2 × 10–15',
          muscleGroup: 'Brachialis & Forearms',
          imagePath: 'assets/workouts/dumbbell_curl.png',
          defaultSets: 2,
          defaultReps: 12,
          defaultWeightKg: 14.0,
          met: 4.0,
          tip: 'Neutral grip throughout the curl motion',
        ),
      ],
    ),

    // 7. SUNDAY: REST
    WorkoutDayPlan(
      weekday: 7,
      dayName: 'Sunday',
      shortDay: 'Sun',
      title: 'Rest',
      subtitle: 'Complete Recovery & Nutrition',
      targetMuscles: 'Total Rest • Mental Refresh',
      isRestDay: true,
      restAdvice:
          '• Full recovery day.\n• Stay hydrated, hit protein target, and rest for Monday Upper Body.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Auto-detect today's weekday: 1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat, 7=Sun
    _selectedWeekday = DateTime.now().weekday;
    final todayPlan = _getPlanForWeekday(_selectedWeekday);
    if (!todayPlan.isRestDay && todayPlan.exercises.isNotEmpty) {
      _selectExercise(todayPlan.exercises.first);
    } else {
      // Default to Monday Upper Body first exercise if today is rest
      _selectExercise(_weeklyPlans[0].exercises[2]); // Bench press
    }
  }

  WorkoutDayPlan _getPlanForWeekday(int weekday) {
    return _weeklyPlans.firstWhere(
      (p) => p.weekday == weekday,
      orElse: () => _weeklyPlans.first,
    );
  }

  void _selectExercise(PlanExercise ex) {
    setState(() {
      _selectedExercise = ex;
      _sets = ex.defaultSets;
      _reps = ex.defaultReps;
      _weightKg = ex.defaultWeightKg;
    });
  }

  int _calculateBurn(double userWeightKg) {
    return MallowFormulas.calculateStrengthBurn(
      met: _selectedExercise.met,
      userWeightKg: userWeightKg,
      sets: _sets,
      reps: _reps,
      weightLiftedKg: _weightKg,
    );
  }

  double get _totalVolumeKg {
    return _sets * _reps * _weightKg;
  }

  @override
  Widget build(BuildContext context) {
    final totals = ref.watch(todayTotalsProvider);
    final profile = ref.watch(profileProvider);
    final workouts = ref.watch(workoutLogsProvider);
    final currentBurn = _calculateBurn(profile.weightKg);

    final todayWeekday = DateTime.now().weekday;
    final activePlan = _getPlanForWeekday(_selectedWeekday);

    return Scaffold(
      backgroundColor: MallowColors.creamBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: Back/Avatar & See Today
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      MallowCircleButton(
                        size: 38,
                        onTap: () {
                          if (Navigator.canPop(context)) {
                            context.pop();
                          } else {
                            context.go('/today');
                          }
                        },
                        child: const Icon(Icons.arrow_back, size: 20, color: MallowColors.charcoal),
                      ),
                      const SizedBox(width: 10),
                      MallowAvatar(
                        size: 38,
                        onTap: () => context.go('/pet'),
                      ),
                    ],
                  ),
                  MallowPillButton(
                    label: 'See Today',
                    height: 38,
                    isPrimary: true,
                    onTap: () => context.go('/today'),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Title Header & Training Guide Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '5-Day Workout Plan',
                          style: MallowTypography.headlineMedium(),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Lean Muscle • Broader Shoulders • V-Taper',
                          style: MallowTypography.bodySmall(
                            color: MallowColors.textSubtle,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _showTrainingGuideModal,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: MallowColors.charcoal, width: 1.2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.info_outline, size: 14, color: MallowColors.charcoal),
                          const SizedBox(width: 4),
                          Text(
                            'Guide',
                            style: MallowTypography.buttonText(
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

              // 1. Weekly Interactive Schedule Bar (Mon - Sun)
              _buildWeeklyScheduleBar(todayWeekday),
              const SizedBox(height: 14),

              // 2. Active Day Banner (Highlights Today's Workout)
              _buildActiveDayBanner(activePlan, todayWeekday),
              const SizedBox(height: 16),

              // 3. Exercise Cards or Rest Day Card
              if (activePlan.isRestDay)
                _buildRestDayCard(activePlan)
              else
                _buildExerciseCardsSection(activePlan),

              const SizedBox(height: 24),

              // 4. Quick Logger Stepper Card (Sets, Reps, Weight & Log Workout Button)
              _buildActiveLoggerCard(currentBurn, profile),

              const SizedBox(height: 24),

              // 5. Burned Today Summary Card
              _buildBurnedTodayCard(totals),

              const SizedBox(height: 24),

              // 6. Recent Workouts History
              if (workouts.isNotEmpty) _buildRecentWorkoutsSection(workouts),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 1. Weekly Interactive Schedule Bar
  // ==========================================
  Widget _buildWeeklyScheduleBar(int todayWeekday) {
    return SizedBox(
      height: 58,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _weeklyPlans.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final plan = _weeklyPlans[index];
          final isSelected = _selectedWeekday == plan.weekday;
          final isToday = todayWeekday == plan.weekday;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedWeekday = plan.weekday;
                if (!plan.isRestDay && plan.exercises.isNotEmpty) {
                  _selectExercise(plan.exercises.first);
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 50,
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
                      style: const TextStyle(fontSize: 10),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // 2. Active Day Banner
  // ==========================================
  Widget _buildActiveDayBanner(WorkoutDayPlan plan, int todayWeekday) {
    final isToday = todayWeekday == plan.weekday;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: plan.isRestDay ? const Color(0xFFE8F0FE) : MallowColors.cardCream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isToday ? MallowColors.hotPink : MallowColors.borderSubtle,
          width: isToday ? 2.0 : 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '${plan.dayName.toUpperCase()} — ${plan.title.toUpperCase()}',
                    style: MallowTypography.headlineSmall(
                      fontSize: 15,
                      color: MallowColors.charcoal,
                    ),
                  ),
                ],
              ),
              if (isToday)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: MallowColors.hotPink,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'TODAY’S PLAN',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            plan.subtitle,
            style: MallowTypography.bodySmall(
              color: MallowColors.textSubtle,
              weight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: MallowColors.borderSubtle, width: 1),
                ),
                child: Text(
                  plan.isRestDay
                      ? '🧘 Active Recovery'
                      : '⚡ ${plan.exercises.length} Exercises • ~50 mins',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: MallowColors.charcoal,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '1–3 RIR • Controlled Form',
                  style: MallowTypography.bodySmall(
                    color: MallowColors.textSubtle,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3. Exercise Cards Section
  // ==========================================
  Widget _buildExerciseCardsSection(WorkoutDayPlan plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Exercises for ${plan.dayName}',
              style: MallowTypography.headlineSmall(fontSize: 17),
            ),
            Text(
              'Tap card to track',
              style: MallowTypography.bodySmall(color: MallowColors.textSubtle),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: plan.exercises.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final ex = plan.exercises[index];
            final isSelected = _selectedExercise.name == ex.name;

            return GestureDetector(
              onTap: () => _selectExercise(ex),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFFF7FA) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? MallowColors.hotPink : MallowColors.borderSubtle,
                    width: isSelected ? 2.0 : 1.2,
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
                    // Cropped Workout Cartoon Image Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 84,
                        height: 84,
                        color: MallowColors.cardCream,
                        child: Image.asset(
                          ex.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(Icons.fitness_center, size: 32, color: MallowColors.charcoal),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Exercise Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${index + 1}. ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: MallowColors.hotPink,
                                  fontSize: 14,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  ex.name,
                                  style: MallowTypography.headlineSmall(
                                    fontSize: 15,
                                    color: MallowColors.charcoal,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Sets × Reps Pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: MallowColors.hotPinkLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              ex.setsReps,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: MallowColors.charcoal,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Muscle Group & Form Tip
                          Text(
                            ex.muscleGroup,
                            style: MallowTypography.bodySmall(
                              color: MallowColors.textSubtle,
                              weight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            ex.tip,
                            style: MallowTypography.bodySmall(
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Track / Selected indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? MallowColors.charcoal : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        isSelected ? 'Active' : 'Track',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : MallowColors.charcoal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ==========================================
  // Rest Day Card
  // ==========================================
  Widget _buildRestDayCard(WorkoutDayPlan plan) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: MallowColors.borderSubtle, width: 1.2),
      ),
      child: Column(
        children: [
          const Text('🛌', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 10),
          Text(
            'Rest & Muscle Growth Day',
            style: MallowTypography.headlineSmall(fontSize: 18),
          ),
          const SizedBox(height: 6),
          Text(
            'Muscle fibers rebuild and get stronger while you rest.\nTraining every day without recovery limits gains.',
            textAlign: TextAlign.center,
            style: MallowTypography.bodySmall(color: MallowColors.textSubtle),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F4EF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              plan.restAdvice ?? 'Focus on sleep, hydration and light mobility work.',
              style: MallowTypography.bodySmall(
                color: MallowColors.charcoal,
                weight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 4. Quick Logger Stepper Card
  // ==========================================
  Widget _buildActiveLoggerCard(int currentBurn, UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MallowColors.cardCream,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5DDD0), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Track Exercise',
                    style: MallowTypography.bodySmall(color: MallowColors.textSubtle),
                  ),
                  Text(
                    _selectedExercise.name,
                    style: MallowTypography.headlineSmall(
                      fontSize: 18,
                      color: MallowColors.charcoal,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: MallowColors.hotPinkLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+$currentBurn kcal',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: MallowColors.charcoal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Quick Core Exercises Chips (includes Bench press, Squat, Deadlift for tests & fast logging)
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildQuickChip('Bench press', 3, 10, 60.0, 'assets/workouts/bench_press.png'),
                const SizedBox(width: 6),
                _buildQuickChip('Squat', 3, 8, 80.0, 'assets/workouts/leg_press.png'),
                const SizedBox(width: 6),
                _buildQuickChip('Deadlift', 3, 8, 85.0, 'assets/workouts/deadlift.png'),
                const SizedBox(width: 6),
                _buildQuickChip('Incline Dumbbell Press', 3, 10, 24.0, 'assets/workouts/incline_dumbbell_press.png'),
                const SizedBox(width: 6),
                _buildQuickChip('Dumbbell Lateral Raises', 3, 15, 10.0, 'assets/workouts/dumbbell_lateral_raise.png'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 1. Sets Stepper
          _buildNumericStepper(
            label: 'Sets',
            value: _sets,
            unit: 'sets',
            onChanged: (val) => setState(() => _sets = val.clamp(1, 20)),
          ),
          const SizedBox(height: 12),

          // 2. Reps per Set Stepper
          _buildNumericStepper(
            label: 'Reps per Set',
            value: _reps,
            unit: 'reps',
            onChanged: (val) => setState(() => _reps = val.clamp(1, 100)),
          ),
          const SizedBox(height: 12),

          // 3. Weight (kg) Stepper
          _buildDoubleStepper(
            label: 'Weight (kg)',
            value: _weightKg,
            onChanged: (val) => setState(() => _weightKg = (val < 0 ? 0.0 : val)),
          ),
          const SizedBox(height: 14),

          // Volume summary
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: MallowColors.borderSubtle),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total workout volume',
                  style: MallowTypography.bodySmall(
                    color: MallowColors.charcoal,
                    weight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_totalVolumeKg.toStringAsFixed(0)} kg',
                  style: MallowTypography.bodyMedium(
                    color: MallowColors.charcoal,
                    weight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Log Workout Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: GestureDetector(
              key: const Key('log_workout_button'),
              onTap: () async {
                final durationMin = (_sets * 2.5).round().clamp(5, 120);
                await ref.read(workoutLogsProvider.notifier).logWorkout(
                  exerciseName: _selectedExercise.name,
                  met: _selectedExercise.met,
                  minutes: durationMin,
                  weightKg: profile.weightKg,
                  caloriesBurned: currentBurn,
                  category: 'Gym',
                );

                if (mounted) {
                  MallowToast.show(
                    context,
                    'Logged ${_selectedExercise.name}! +$currentBurn kcal burned',
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: MallowColors.charcoal,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Center(
                  child: Text(
                    'Log workout',
                    style: MallowTypography.buttonText(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip(String name, int sets, int reps, double weight, String img) {
    final isSelected = _selectedExercise.name == name;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedExercise = PlanExercise(
            name: name,
            setsReps: '$sets × $reps',
            muscleGroup: 'Compound',
            imagePath: img,
            defaultSets: sets,
            defaultReps: reps,
            defaultWeightKg: weight,
            tip: 'Focus on progressive overload',
          );
          _sets = sets;
          _reps = reps;
          _weightKg = weight;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? MallowColors.charcoal : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? MallowColors.charcoal : MallowColors.borderSubtle,
          ),
        ),
        child: Text(
          name,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : MallowColors.charcoal,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 5. Burned Today Card
  // ==========================================
  Widget _buildBurnedTodayCard(TodayTotals totals) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MallowColors.hotPink,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Burned today',
                style: MallowTypography.bodyMedium(
                  color: MallowColors.charcoal,
                  weight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${totals.burnedKcal}',
                    style: MallowTypography.bigNumber(fontSize: 40, color: MallowColors.charcoal),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'kcal',
                    style: MallowTypography.headlineMedium(color: MallowColors.charcoal),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD4E5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Sets × Reps × Weight',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: MallowColors.charcoal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 6. Recent Workouts Section
  // ==========================================
  Widget _buildRecentWorkoutsSection(List<WorkoutLog> workouts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Logged workouts',
              style: MallowTypography.headlineSmall(fontSize: 17),
            ),
            Text(
              '${workouts.length} session${workouts.length > 1 ? 's' : ''}',
              style: MallowTypography.bodySmall(color: MallowColors.textSubtle),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: workouts.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final w = workouts[index];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: MallowColors.borderSubtle, width: 1.2),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: MallowColors.hotPinkLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(child: Text('💪', style: TextStyle(fontSize: 16))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          w.exerciseName,
                          style: MallowTypography.bodyMedium(weight: FontWeight.bold),
                        ),
                        Text(
                          '${w.minutes} minutes • ${w.category}',
                          style: MallowTypography.bodySmall(color: MallowColors.textSubtle),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '+${w.caloriesBurned} kcal',
                    style: MallowTypography.bodyMedium(
                      weight: FontWeight.w700,
                      color: MallowColors.charcoal,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      await ref.read(workoutLogsProvider.notifier).deleteWorkoutLog(w.id);
                      if (context.mounted) {
                        MallowToast.show(context, 'Deleted workout');
                      }
                    },
                    child: const Icon(Icons.close, size: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ==========================================
  // Stepper Widgets
  // ==========================================
  Widget _buildNumericStepper({
    required String label,
    required int value,
    required String unit,
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: MallowTypography.bodyMedium(weight: FontWeight.w600)),
            Text('$value $unit', style: MallowTypography.bodySmall(color: MallowColors.textSubtle)),
          ],
        ),
        Row(
          children: [
            _buildCircleStepperBtn(Icons.remove, () => onChanged(value - 1)),
            Container(
              width: 44,
              alignment: Alignment.center,
              child: Text(
                '$value',
                style: MallowTypography.bodyMedium(weight: FontWeight.bold),
              ),
            ),
            _buildCircleStepperBtn(Icons.add, () => onChanged(value + 1)),
          ],
        ),
      ],
    );
  }

  Widget _buildDoubleStepper({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: MallowTypography.bodyMedium(weight: FontWeight.w600)),
            Text('${value.toStringAsFixed(1)} kg', style: MallowTypography.bodySmall(color: MallowColors.textSubtle)),
          ],
        ),
        Row(
          children: [
            _buildCircleStepperBtn(Icons.remove, () => onChanged(value - 2.5)),
            Container(
              width: 52,
              alignment: Alignment.center,
              child: Text(
                value.toStringAsFixed(1),
                style: MallowTypography.bodyMedium(weight: FontWeight.bold),
              ),
            ),
            _buildCircleStepperBtn(Icons.add, () => onChanged(value + 2.5)),
          ],
        ),
      ],
    );
  }

  Widget _buildCircleStepperBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: MallowColors.borderSubtle, width: 1.5),
        ),
        child: Icon(icon, size: 16, color: MallowColors.charcoal),
      ),
    );
  }

  // ==========================================
  // Training Guide Modal (Clean, Non-Cluttered)
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
                desc: 'Compound lifts: 2–3 minutes • Isolation exercises: 60–120 seconds.',
              ),
              _buildGuideRuleItem(
                icon: '⚡',
                title: 'Intensity (1–3 RIR)',
                desc: 'Leave 1–3 repetitions in reserve on working sets. Don’t go to total failure every set.',
              ),
              _buildGuideRuleItem(
                icon: '📈',
                title: 'Progressive Overload',
                desc: 'Hit the top of the rep range first with clean form, then increase weight slightly.',
              ),
              _buildGuideRuleItem(
                icon: '💤',
                title: 'Sleep & Recovery',
                desc: 'Sleep 7–9 hours nightly. Keep Thursday and Sunday strictly as rest days.',
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
