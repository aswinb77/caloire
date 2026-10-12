import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/mallow_theme.dart';
import '../../core/theme/mallow_widgets.dart';
import '../../core/theme/mallow_toast.dart';
import '../../core/formulas/formulas.dart';
import '../../core/providers/providers.dart';

enum ExerciseType { strength, cardio }

class ExerciseItem {
  final String name;
  final double met;
  final ExerciseType type;
  final String muscleGroup;
  final double defaultWeightKg;
  final int defaultSets;
  final int defaultReps;

  const ExerciseItem({
    required this.name,
    required this.met,
    this.type = ExerciseType.strength,
    this.muscleGroup = 'Full Body',
    this.defaultWeightKg = 50.0,
    this.defaultSets = 4,
    this.defaultReps = 10,
  });

  bool get isStrength => type == ExerciseType.strength;
}

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  final List<ExerciseItem> _exercises = const [
    ExerciseItem(
      name: 'Bench press',
      met: 5.0,
      type: ExerciseType.strength,
      muscleGroup: 'Chest',
      defaultWeightKg: 60.0,
      defaultSets: 4,
      defaultReps: 10,
    ),
    ExerciseItem(
      name: 'Squat',
      met: 6.0,
      type: ExerciseType.strength,
      muscleGroup: 'Legs & Glutes',
      defaultWeightKg: 70.0,
      defaultSets: 4,
      defaultReps: 10,
    ),
    ExerciseItem(
      name: 'Deadlift',
      met: 6.5,
      type: ExerciseType.strength,
      muscleGroup: 'Back & Posterior Chain',
      defaultWeightKg: 80.0,
      defaultSets: 4,
      defaultReps: 8,
    ),
    ExerciseItem(
      name: 'Overhead press',
      met: 5.0,
      type: ExerciseType.strength,
      muscleGroup: 'Shoulders',
      defaultWeightKg: 40.0,
      defaultSets: 3,
      defaultReps: 10,
    ),
    ExerciseItem(
      name: 'Barbell row',
      met: 5.5,
      type: ExerciseType.strength,
      muscleGroup: 'Upper Back & Lats',
      defaultWeightKg: 50.0,
      defaultSets: 4,
      defaultReps: 10,
    ),
    ExerciseItem(
      name: 'Pull-ups',
      met: 6.0,
      type: ExerciseType.strength,
      muscleGroup: 'Lats & Biceps',
      defaultWeightKg: 0.0,
      defaultSets: 3,
      defaultReps: 8,
    ),
    ExerciseItem(
      name: 'Dumbbell curls',
      met: 4.0,
      type: ExerciseType.strength,
      muscleGroup: 'Arms & Biceps',
      defaultWeightKg: 14.0,
      defaultSets: 3,
      defaultReps: 12,
    ),
    ExerciseItem(
      name: 'Leg press',
      met: 5.5,
      type: ExerciseType.strength,
      muscleGroup: 'Quadriceps',
      defaultWeightKg: 120.0,
      defaultSets: 4,
      defaultReps: 12,
    ),
    ExerciseItem(
      name: 'Run',
      met: 9.8,
      type: ExerciseType.cardio,
      muscleGroup: 'Cardio / Stamina',
    ),
    ExerciseItem(
      name: 'Cycle',
      met: 7.5,
      type: ExerciseType.cardio,
      muscleGroup: 'Cardio / Legs',
    ),
  ];

  late ExerciseItem _selectedExercise;

  // Strength parameters
  int _sets = 4;
  int _reps = 10;
  double _weightKg = 60.0;

  // Cardio parameters
  int _cardioMinutes = 20;
  bool _isHighIntensity = false;

  @override
  void initState() {
    super.initState();
    _selectExercise(_exercises.first);
  }

  void _selectExercise(ExerciseItem ex) {
    setState(() {
      _selectedExercise = ex;
      if (ex.isStrength) {
        _sets = ex.defaultSets;
        _reps = ex.defaultReps;
        _weightKg = ex.defaultWeightKg;
      } else {
        _cardioMinutes = 20;
        _isHighIntensity = false;
      }
    });
  }

  int _calculateBurn(double userWeightKg) {
    if (_selectedExercise.isStrength) {
      return MallowFormulas.calculateStrengthBurn(
        met: _selectedExercise.met,
        userWeightKg: userWeightKg,
        sets: _sets,
        reps: _reps,
        weightLiftedKg: _weightKg,
      );
    } else {
      final effectiveMet = _isHighIntensity
          ? (_selectedExercise.met * 1.25)
          : _selectedExercise.met;
      return MallowFormulas.calculateWorkoutBurn(
        met: effectiveMet,
        weightKg: userWeightKg,
        minutes: _cardioMinutes,
      );
    }
  }

  int get _calculatedMinutes {
    if (_selectedExercise.isStrength) {
      return (_sets * 2.5).round().clamp(5, 120);
    }
    return _cardioMinutes;
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

    return Scaffold(
      backgroundColor: MallowColors.creamBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: Mallow avatar on left, "See Today" pill on right
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MallowAvatar(
                    size: 38,
                    onTap: () => context.go('/pet'),
                  ),
                  MallowPillButton(
                    label: 'See Today',
                    height: 38,
                    isPrimary: true,
                    onTap: () => context.go('/today'),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 1. Burned Today Pink Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: MallowColors.hotPink,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Burned today',
                      style: MallowTypography.bodyMedium(
                        color: MallowColors.charcoal,
                        weight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${totals.burnedKcal}',
                          style: MallowTypography.bigNumber(fontSize: 48, color: MallowColors.charcoal),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'kcal',
                          style: MallowTypography.headlineMedium(color: MallowColors.charcoal),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Formula pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD4E5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _selectedExercise.isStrength
                            ? 'Sets × Reps × Weight + MET'
                            : 'MET × kg × hours',
                        style: MallowTypography.bodySmall(
                          color: MallowColors.charcoal,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. Log a workout section
              Text(
                'Log a workout',
                style: MallowTypography.headlineSmall(),
              ),
              const SizedBox(height: 14),

              // Horizontal Exercise Chips
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _exercises.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final ex = _exercises[index];
                    final isSelected = _selectedExercise.name == ex.name;
                    return GestureDetector(
                      onTap: () => _selectExercise(ex),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? MallowColors.hotPink : Colors.transparent,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: MallowColors.charcoal,
                            width: 1.8,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            ex.name,
                            style: MallowTypography.buttonText(
                              color: MallowColors.charcoal,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Active Workout Config Card (Sets, Reps, Weight instead of slider!)
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: MallowColors.cardCream,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: const Color(0xFFE5DDD0), width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Muscle Group label
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedExercise.name,
                              style: MallowTypography.headlineSmall(
                                fontSize: 20,
                                color: MallowColors.charcoal,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _selectedExercise.muscleGroup,
                              style: MallowTypography.bodySmall(
                                color: MallowColors.textSubtle,
                                weight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: MallowColors.borderSubtle),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _selectedExercise.isStrength
                                    ? Icons.fitness_center
                                    : Icons.directions_run,
                                size: 14,
                                color: MallowColors.charcoal,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _selectedExercise.isStrength ? 'Strength' : 'Cardio',
                                style: MallowTypography.bodySmall(
                                  color: MallowColors.charcoal,
                                  weight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Controls based on type
                    if (_selectedExercise.isStrength) ...[
                      // 1. Sets Stepper & Quick Pills
                      _buildInputRow(
                        label: 'Sets',
                        valueText: '$_sets sets',
                        onDecrement: () => setState(() => _sets = (_sets - 1).clamp(1, 12)),
                        onIncrement: () => setState(() => _sets = (_sets + 1).clamp(1, 12)),
                        chips: [3, 4, 5, 6],
                        currentValue: _sets,
                        onChipSelected: (val) => setState(() => _sets = val),
                      ),
                      const SizedBox(height: 18),

                      // 2. Reps Stepper & Quick Pills
                      _buildInputRow(
                        label: 'Reps per Set',
                        valueText: '$_reps reps',
                        onDecrement: () => setState(() => _reps = (_reps - 1).clamp(1, 30)),
                        onIncrement: () => setState(() => _reps = (_reps + 1).clamp(1, 30)),
                        chips: [6, 8, 10, 12],
                        currentValue: _reps,
                        onChipSelected: (val) => setState(() => _reps = val),
                      ),
                      const SizedBox(height: 18),

                      // 3. Weight Stepper & Quick Pills
                      _buildWeightInputRow(),
                      const SizedBox(height: 22),

                      // Volume & Workout Summary Box (Overflow-safe with Expanded & flexible wrapping)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: MallowColors.borderSubtle),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _weightKg > 0
                                        ? '$_sets sets × $_reps reps @ ${_weightKg.toStringAsFixed(_weightKg % 1 == 0 ? 0 : 1)} kg'
                                        : '$_sets sets × $_reps reps (Bodyweight)',
                                    style: MallowTypography.bodyMedium(
                                      color: MallowColors.charcoal,
                                      weight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _weightKg > 0
                                        ? '${_totalVolumeKg.toStringAsFixed(0)} kg volume • ~$_calculatedMinutes min session'
                                        : 'Bodyweight • ~$_calculatedMinutes min session',
                                    style: MallowTypography.bodySmall(
                                      color: MallowColors.textSubtle,
                                      weight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '+$currentBurn',
                                  style: MallowTypography.headlineMedium(
                                    fontSize: 22,
                                    color: MallowColors.charcoal,
                                  ),
                                ),
                                Text(
                                  'kcal',
                                  style: MallowTypography.bodySmall(
                                    color: MallowColors.textSubtle,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Cardio Duration Stepper & Quick Pills
                      _buildInputRow(
                        label: 'Duration',
                        valueText: '$_cardioMinutes min',
                        onDecrement: () => setState(() => _cardioMinutes = (_cardioMinutes - 5).clamp(5, 120)),
                        onIncrement: () => setState(() => _cardioMinutes = (_cardioMinutes + 5).clamp(5, 120)),
                        chips: [15, 20, 30, 45],
                        currentValue: _cardioMinutes,
                        onChipSelected: (val) => setState(() => _cardioMinutes = val),
                      ),
                      const SizedBox(height: 18),

                      // Intensity Switch
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'High Intensity (Sprint / HIIT)',
                                  style: MallowTypography.bodyMedium(weight: FontWeight.w600),
                                ),
                                Text(
                                  _isHighIntensity ? '1.25× MET multiplier' : 'Standard steady pace',
                                  style: MallowTypography.bodySmall(color: MallowColors.textSubtle),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _isHighIntensity,
                            activeThumbColor: MallowColors.hotPink,
                            onChanged: (val) => setState(() => _isHighIntensity = val),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Cardio Summary Box (Overflow-safe)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: MallowColors.borderSubtle),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '$_cardioMinutes min ${_selectedExercise.name}',
                                    style: MallowTypography.bodyMedium(
                                      color: MallowColors.charcoal,
                                      weight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${profile.weightKg.toStringAsFixed(1)} kg body weight',
                                    style: MallowTypography.bodySmall(
                                      color: MallowColors.textSubtle,
                                      weight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '+$currentBurn',
                                  style: MallowTypography.headlineMedium(
                                    fontSize: 22,
                                    color: MallowColors.charcoal,
                                  ),
                                ),
                                Text(
                                  'kcal',
                                  style: MallowTypography.bodySmall(
                                    color: MallowColors.textSubtle,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Black "Log workout" button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        key: const Key('log_workout_button'),
                        onPressed: () async {
                          final exerciseDetail = _selectedExercise.isStrength
                              ? _selectedExercise.name
                              : '${_selectedExercise.name} ($_cardioMinutes min)';

                          await ref.read(workoutLogsProvider.notifier).logWorkout(
                            exerciseName: exerciseDetail,
                            met: _selectedExercise.met,
                            minutes: _calculatedMinutes,
                            weightKg: profile.weightKg,
                            caloriesBurned: currentBurn,
                            category: _selectedExercise.isStrength ? 'Strength' : 'Cardio',
                          );

                          if (context.mounted) {
                            MallowToast.show(
                              context,
                              'Logged ${_selectedExercise.name} (+$currentBurn kcal)',
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MallowColors.charcoal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        child: Text(
                          'Log ${_selectedExercise.name} (+$currentBurn kcal)',
                          style: MallowTypography.buttonText(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),

              // 3. Today List section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Today',
                    style: MallowTypography.headlineSmall(),
                  ),
                  if (workouts.isNotEmpty)
                    Text(
                      '${workouts.length} logged',
                      style: MallowTypography.bodySmall(
                        color: MallowColors.textSubtle,
                        weight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),

              if (workouts.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: MallowColors.borderSubtle),
                  ),
                  child: Center(
                    child: Text(
                      'No workouts logged today yet.',
                      style: MallowTypography.bodyMedium(color: MallowColors.textSubtle),
                    ),
                  ),
                )
              else
                Column(
                  children: workouts.map((w) {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFE8DFCE), width: 1.0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  w.exerciseName,
                                  style: MallowTypography.headlineSmall(
                                    fontSize: 17,
                                    color: MallowColors.charcoal,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${w.minutes} min gym session',
                                  style: MallowTypography.bodySmall(
                                    color: MallowColors.textSubtle,
                                    weight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '+${w.caloriesBurned} kcal',
                                style: MallowTypography.headlineSmall(
                                  fontSize: 18,
                                  color: MallowColors.charcoal,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.close, size: 18, color: MallowColors.textSubtle),
                                onPressed: () {
                                  ref.read(workoutLogsProvider.notifier).deleteWorkoutLog(w.id);
                                  MallowToast.show(context, 'Removed ${w.exerciseName}');
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputRow({
    required String label,
    required String valueText,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    required List<int> chips,
    required int currentValue,
    required ValueChanged<int> onChipSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: MallowTypography.bodyMedium(weight: FontWeight.w600),
            ),
            Row(
              children: [
                _buildRoundStepperBtn(Icons.remove, onDecrement),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    valueText,
                    style: MallowTypography.headlineSmall(fontSize: 18),
                  ),
                ),
                _buildRoundStepperBtn(Icons.add, onIncrement),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: chips.map((c) {
            final isSelected = currentValue == c;
            return GestureDetector(
              onTap: () => onChipSelected(c),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? MallowColors.charcoal : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? MallowColors.charcoal : MallowColors.borderSubtle,
                  ),
                ),
                child: Text(
                  '$c',
                  style: MallowTypography.bodySmall(
                    color: isSelected ? Colors.white : MallowColors.charcoal,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );

  }

  Widget _buildWeightInputRow() {
    final isPullUps = _selectedExercise.name == 'Pull-ups';
    final weightLabel = isPullUps && _weightKg == 0 ? 'Bodyweight' : '${_weightKg.toStringAsFixed(_weightKg % 1 == 0 ? 0 : 1)} kg';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weight (kg)',
                  style: MallowTypography.bodyMedium(weight: FontWeight.w600),
                ),
                Text(
                  'Weight per set',
                  style: MallowTypography.bodySmall(color: MallowColors.textSubtle),
                ),
              ],
            ),
            Row(
              children: [
                _buildRoundStepperBtn(Icons.remove, () {
                  setState(() => _weightKg = (_weightKg - 2.5).clamp(0.0, 350.0));
                }),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    weightLabel,
                    style: MallowTypography.headlineSmall(fontSize: 18),
                  ),
                ),
                _buildRoundStepperBtn(Icons.add, () {
                  setState(() => _weightKg = (_weightKg + 2.5).clamp(0.0, 350.0));
                }),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: (isPullUps ? [0.0, 5.0, 10.0, 15.0, 20.0] : [20.0, 40.0, 60.0, 80.0, 100.0, 120.0]).map((w) {
              final isSelected = (_weightKg - w).abs() < 0.1;
              final chipText = w == 0.0 ? 'Bodyweight' : '${w.toInt()} kg';
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () => setState(() => _weightKg = w),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? MallowColors.charcoal : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? MallowColors.charcoal : MallowColors.borderSubtle,
                      ),
                    ),
                    child: Text(
                      chipText,
                      style: MallowTypography.bodySmall(
                        color: isSelected ? Colors.white : MallowColors.charcoal,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRoundStepperBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: MallowColors.charcoal, width: 1.5),
        ),
        child: Center(
          child: Icon(icon, size: 18, color: MallowColors.charcoal),
        ),
      ),
    );
  }
}
