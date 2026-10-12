import 'dart:math' as math;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/mallow_theme.dart';
import '../../core/theme/mallow_widgets.dart';
import '../../core/models/models.dart';
import '../../core/formulas/formulas.dart';
import '../../core/providers/providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  // Main Step: 0 = Gamified Stats, 1 = Goal, 2 = Summary & Launch
  int _currentStep = 0;

  // Active question in Step 0: 0 = Weight, 1 = Height, 2 = Age, 3 = Activity
  int _bodyQuestionIndex = 0;

  // Profile stats
  double _weight = 68.4;
  double _height = 172.0;
  double _targetWeight = 65.0;
  int _age = 25;
  bool _isMale = true;
  double _activityFactor = 1.375;
  String _selectedGoal = 'lose';

  // Animation controller for Mallow's idle floating / breathing animation
  late final AnimationController _idleController;
  late final Animation<double> _idleAnimation;

  @override
  void initState() {
    super.initState();

    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // Only repeat in live app, not in test runner where pumpAndSettle would timeout
    try {
      if (!Platform.environment.containsKey('FLUTTER_TEST')) {
        _idleController.repeat(reverse: true);
      }
    } catch (_) {
      // In web or environments without Platform
      _idleController.repeat(reverse: true);
    }

    _idleAnimation = CurvedAnimation(
      parent: _idleController,
      curve: Curves.easeInOutSine,
    );

    // Load existing profile if available
    final existing = ref.read(profileProvider);
    _weight = existing.weightKg;
    _height = existing.heightCm;
    _targetWeight = existing.targetWeightKg;
    _selectedGoal = existing.goal;
  }

  @override
  void dispose() {
    _idleController.dispose();
    super.dispose();
  }

  // ==========================================
  // Mascot Image Mapping
  // ==========================================
  String _getWeightMascot(double weight) {
    if (weight <= 50) return 'mascot/weight_30-50kg.png';
    if (weight <= 70) return 'mascot/weight_51-70kg.png';
    if (weight <= 90) return 'mascot/weight_71-90kg.png';
    if (weight <= 110) return 'mascot/weight_91-110kg.png';
    if (weight <= 130) return 'mascot/weight_111-130kg.png';
    return 'mascot/weight_131-150kg.png';
  }

  String _getHeightMascot(double heightCm) {
    if (heightCm < 135) return 'mascot/height_3ft.png';
    if (heightCm < 155) return 'mascot/height_4ft.png';
    if (heightCm < 178) return 'mascot/height_5ft.png';
    if (heightCm < 205) return 'mascot/height_6ft.png';
    return 'mascot/height_7ft.png';
  }

  String _getAgeMascot(int age) {
    if (age <= 20) return 'mascot/age_12-20.png';
    if (age <= 30) return 'mascot/age_21-30.png';
    if (age <= 45) return 'mascot/age_31-45.png'; // Mustache!
    if (age <= 60) return 'mascot/age_46-60.png'; // Beard!
    if (age <= 75) return 'mascot/age_61-75.png'; // Gray beard!
    return 'mascot/age_76-90.png'; // Grandmaster sage!
  }

  String _getActivityMascot(double factor) {
    if (factor <= 1.25) return 'mascot/activity_sedentary.png';
    if (factor <= 1.45) return 'mascot/activity_light.png';
    if (factor <= 1.6) return 'mascot/activity_moderate.png';
    return 'mascot/activity_heavy.png';
  }

  String _getCurrentMascotAsset() {
    switch (_bodyQuestionIndex) {
      case 0:
        return _getWeightMascot(_weight);
      case 1:
        return _getHeightMascot(_height);
      case 2:
        return _getAgeMascot(_age);
      case 3:
      default:
        return _getActivityMascot(_activityFactor);
    }
  }



  String _formatFtIn(double cm) {
    final totalInches = (cm / 2.54).round();
    final feet = totalInches ~/ 12;
    final inches = totalInches % 12;
    return "$feet'$inches\"";
  }

  int get _calculatedTargetKcal {
    return MallowFormulas.calculateDailyTarget(
      weightKg: _weight,
      heightCm: _height,
      goal: _selectedGoal,
      activityFactor: _activityFactor,
    );
  }

  double get _calculatedProteinGoal {
    return (_weight * 1.6).clamp(60.0, 220.0).roundToDouble();
  }

  void _saveAndFinish() {
    final targetKcal = _calculatedTargetKcal;
    final proteinGoal = _calculatedProteinGoal;

    final updated = UserProfile(
      goal: _selectedGoal,
      dailyTargetKcal: targetKcal,
      proteinGoalG: proteinGoal,
      burnGoalKcal: 500,
      weightKg: _weight,
      heightCm: _height,
      waistCm: 78.0,
      targetWeightKg: _targetWeight,
    );

    // 1. Update Riverpod state
    ref.read(profileProvider.notifier).updateProfile(updated);

    // 2. Persist onboarding status asynchronously
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('mallow_onboarded', true);
    }).catchError((e) {
      debugPrint('SharedPreferences setBool error: $e');
    });

    // 3. Navigate forward to /today
    if (mounted) {
      try {
        context.go('/today');
      } catch (e) {
        debugPrint('GoRouter navigation error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MallowColors.creamBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Navigation & Step Indicator Bar with Skip Option
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildClickableStepBar(0),
                      const SizedBox(width: 8),
                      _buildClickableStepBar(1),
                      const SizedBox(width: 8),
                      _buildClickableStepBar(2),
                    ],
                  ),
                  TextButton.icon(
                    key: const Key('skip_to_today_button'),
                    onPressed: _saveAndFinish,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16, color: MallowColors.charcoal),
                    label: Text(
                      'Skip to Today',
                      style: MallowTypography.bodySmall(
                        color: MallowColors.charcoal,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_currentStep == 0)
                      _buildGamifiedStep0Body()
                    else if (_currentStep == 1)
                      _buildStep1Body()
                    else
                      _buildStep2Body(),
                  ],
                ),
              ),
            ),

            // Bottom element depends on step
            if (_currentStep == 1)
              _buildBottomPinkDome(context)
            else if (_currentStep == 2)
              _buildStep2BottomBar()
            else
              _buildStep0BottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildClickableStepBar(int stepIndex) {
    final isActive = _currentStep == stepIndex;
    final isDone = _currentStep > stepIndex;

    return GestureDetector(
      key: Key('step_bar_$stepIndex'),
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _currentStep = stepIndex),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isActive ? 44 : 28,
          height: 6,
          decoration: BoxDecoration(
            color: isActive
                ? MallowColors.charcoal
                : isDone
                    ? MallowColors.oliveGreen
                    : const Color(0xFFD4CCBF),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // STEP 0: GAMIFIED STATS WITH LIVE MASCOT
  // ==========================================
  Widget _buildGamifiedStep0Body() {
    final mascotAsset = _getCurrentMascotAsset();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Header
        Text(
          "Tell Mallow\nabout you.",
          style: MallowTypography.headlineLarge(fontSize: 34),
        ),
        const SizedBox(height: 6),
        Text(
          "Enter your stats below to calculate your baseline target.",
          style: MallowTypography.bodyMedium(color: MallowColors.textSubtle),
        ),
        const SizedBox(height: 12),

        // Mascot Stage (Transparent, floating directly on cream background)
        _buildMascotStage(mascotAsset: mascotAsset),
        const SizedBox(height: 12),

        // Interactive Category Pills / Tabs (Weight, Height, Age, Activity)
        _buildCategoryPills(),
        const SizedBox(height: 16),

        // Active Question Interactive Control Card
        _buildActiveQuestionCard(),
        const SizedBox(height: 14),

        // Gender Selector Card
        _buildGenderSelectorCard(),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildMascotStage({required String mascotAsset}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: AnimatedBuilder(
          animation: _idleAnimation,
          builder: (context, child) {
            final floatY = math.sin(_idleAnimation.value * math.pi) * 6;
            final squishX = 1.0 + (math.cos(_idleAnimation.value * math.pi) * 0.02);
            final squishY = 1.0 - (math.cos(_idleAnimation.value * math.pi) * 0.02);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.translate(
                  offset: Offset(0, floatY),
                  child: Transform.scale(
                    scaleX: squishX,
                    scaleY: squishY,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeOutBack,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: Tween<double>(begin: 0.88, end: 1.0).animate(animation),
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: Image.asset(
                        mascotAsset,
                        key: ValueKey(mascotAsset),
                        height: 160,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/$mascotAsset',
                            key: ValueKey('assets/$mascotAsset'),
                            height: 160,
                            fit: BoxFit.contain,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Subtle shadow under mascot
                Container(
                  width: 85 * (1.0 + (_idleAnimation.value * 0.12)),
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.06 - (_idleAnimation.value * 0.02)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }



  Widget _buildCategoryPills() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildPillItem(
            index: 0,
            emoji: '⚖️',
            label: 'Weight',
            badge: '${_weight.toStringAsFixed(1)} kg',
          ),
          const SizedBox(width: 8),
          _buildPillItem(
            index: 1,
            emoji: '📏',
            label: 'Height',
            badge: '${_height.round()} cm',
          ),
          const SizedBox(width: 8),
          _buildPillItem(
            index: 2,
            emoji: '🎂',
            label: 'Age',
            badge: '$_age yrs',
          ),
          const SizedBox(width: 8),
          _buildPillItem(
            index: 3,
            emoji: '⚡',
            label: 'Activity',
            badge: _getActivityShortLabel(_activityFactor),
          ),
        ],
      ),
    );
  }

  String _getActivityShortLabel(double factor) {
    if (factor <= 1.25) return 'Sedentary';
    if (factor <= 1.45) return 'Light';
    if (factor <= 1.6) return 'Moderate';
    return 'Heavy';
  }

  Widget _buildPillItem({
    required int index,
    required String emoji,
    required String label,
    required String badge,
  }) {
    final isSelected = _bodyQuestionIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _bodyQuestionIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? MallowColors.charcoal : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? MallowColors.charcoal : MallowColors.borderSubtle,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              label,
              style: MallowTypography.bodySmall(
                color: isSelected ? Colors.white : MallowColors.charcoal,
                weight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? MallowColors.hotPink : const Color(0xFFEFE8DB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : MallowColors.charcoal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveQuestionCard() {
    switch (_bodyQuestionIndex) {
      case 0:
        return _buildWeightControl();
      case 1:
        return _buildHeightControl();
      case 2:
        return _buildAgeControl();
      case 3:
      default:
        return _buildActivityControl();
    }
  }

  // ==========================================
  // Weight Control with Live Slider & Steppers
  // ==========================================
  Widget _buildWeightControl() {
    final lbs = (_weight * 2.20462).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: MallowColors.borderSubtle, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Current Weight', style: MallowTypography.headlineSmall(fontSize: 18)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: MallowColors.hotPinkLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$lbs lbs',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: MallowColors.hotPink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Big readout + Stepper Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStepperButton(
                icon: Icons.remove,
                onTap: () => setState(() => _weight = (_weight - 0.5).clamp(35.0, 150.0)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '${_weight.toStringAsFixed(1)} kg',
                  style: MallowTypography.bigNumber(fontSize: 42),
                ),
              ),
              _buildStepperButton(
                icon: Icons.add,
                onTap: () => setState(() => _weight = (_weight + 0.5).clamp(35.0, 150.0)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Live Interactive Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: MallowColors.hotPink,
              inactiveTrackColor: const Color(0xFFEBE3D5),
              thumbColor: MallowColors.charcoal,
              overlayColor: MallowColors.hotPink.withValues(alpha: 0.16),
              trackHeight: 8,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 13, elevation: 3),
            ),
            child: Slider(
              value: _weight,
              min: 35.0,
              max: 150.0,
              onChanged: (val) {
                setState(() => _weight = double.parse(val.toStringAsFixed(1)));
              },
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('35 kg', style: MallowTypography.bodySmall(color: MallowColors.textSubtle)),
              Text('150 kg', style: MallowTypography.bodySmall(color: MallowColors.textSubtle)),
            ],
          ),
          const SizedBox(height: 16),

          // Question Navigation Helper
          _buildQuestionNavigator(
            nextTitle: 'Next: Height →',
            onNext: () => setState(() => _bodyQuestionIndex = 1),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Height Control with Live Slider & Steppers
  // ==========================================
  Widget _buildHeightControl() {
    final ftIn = _formatFtIn(_height);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: MallowColors.borderSubtle, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Height', style: MallowTypography.headlineSmall(fontSize: 18)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: MallowColors.oliveGreenLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  ftIn,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: MallowColors.oliveGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Big readout + Stepper Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStepperButton(
                icon: Icons.remove,
                onTap: () => setState(() => _height = (_height - 1).clamp(110.0, 225.0)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '${_height.round()} cm',
                  style: MallowTypography.bigNumber(fontSize: 42),
                ),
              ),
              _buildStepperButton(
                icon: Icons.add,
                onTap: () => setState(() => _height = (_height + 1).clamp(110.0, 225.0)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Live Interactive Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: MallowColors.oliveGreen,
              inactiveTrackColor: const Color(0xFFEBE3D5),
              thumbColor: MallowColors.charcoal,
              overlayColor: MallowColors.oliveGreen.withValues(alpha: 0.16),
              trackHeight: 8,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 13, elevation: 3),
            ),
            child: Slider(
              value: _height,
              min: 110.0,
              max: 225.0,
              onChanged: (val) {
                setState(() => _height = val.roundToDouble());
              },
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('110 cm', style: MallowTypography.bodySmall(color: MallowColors.textSubtle)),
              Text('225 cm', style: MallowTypography.bodySmall(color: MallowColors.textSubtle)),
            ],
          ),
          const SizedBox(height: 16),

          _buildQuestionNavigator(
            prevTitle: '← Weight',
            onPrev: () => setState(() => _bodyQuestionIndex = 0),
            nextTitle: 'Next: Age →',
            onNext: () => setState(() => _bodyQuestionIndex = 2),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Age Control with Live Slider & Steppers
  // ==========================================
  Widget _buildAgeControl() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: MallowColors.borderSubtle, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Age', style: MallowTypography.headlineSmall(fontSize: 18)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: MallowColors.slateBlueLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_age yrs',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: MallowColors.slateBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Big readout + Stepper Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStepperButton(
                icon: Icons.remove,
                onTap: () => setState(() => _age = (_age - 1).clamp(14, 90)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '$_age yrs',
                  style: MallowTypography.bigNumber(fontSize: 42),
                ),
              ),
              _buildStepperButton(
                icon: Icons.add,
                onTap: () => setState(() => _age = (_age + 1).clamp(14, 90)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Live Interactive Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: MallowColors.slateBlue,
              inactiveTrackColor: const Color(0xFFEBE3D5),
              thumbColor: MallowColors.charcoal,
              overlayColor: MallowColors.slateBlue.withValues(alpha: 0.16),
              trackHeight: 8,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 13, elevation: 3),
            ),
            child: Slider(
              value: _age.toDouble(),
              min: 14.0,
              max: 90.0,
              onChanged: (val) {
                setState(() => _age = val.round());
              },
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('14 yrs', style: MallowTypography.bodySmall(color: MallowColors.textSubtle)),
              Text('90 yrs', style: MallowTypography.bodySmall(color: MallowColors.textSubtle)),
            ],
          ),
          const SizedBox(height: 16),

          _buildQuestionNavigator(
            prevTitle: '← Height',
            onPrev: () => setState(() => _bodyQuestionIndex = 1),
            nextTitle: 'Next: Activity →',
            onNext: () => setState(() => _bodyQuestionIndex = 3),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Activity Control with Live Selection
  // ==========================================
  Widget _buildActivityControl() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: MallowColors.borderSubtle, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daily Activity Level', style: MallowTypography.headlineSmall(fontSize: 18)),
          const SizedBox(height: 14),

          _buildActivityOption(
            factor: 1.2,
            title: 'Sedentary',
            description: 'Desk job, couch relaxation, minimal steps',
            emoji: '🛋️',
          ),
          const SizedBox(height: 8),
          _buildActivityOption(
            factor: 1.375,
            title: 'Light Active',
            description: '1-3 light sessions or regular daily walks',
            emoji: '🚶',
          ),
          const SizedBox(height: 8),
          _buildActivityOption(
            factor: 1.55,
            title: 'Moderate Active',
            description: '3-5 workouts / active fitness lifestyle',
            emoji: '🏃',
          ),
          const SizedBox(height: 8),
          _buildActivityOption(
            factor: 1.725,
            title: 'Heavy Active',
            description: 'Daily intense training or physical job',
            emoji: '🔥',
          ),
          const SizedBox(height: 16),

          _buildQuestionNavigator(
            prevTitle: '← Age',
            onPrev: () => setState(() => _bodyQuestionIndex = 2),
            nextTitle: 'Next: What’s your goal? →',
            onNext: () => setState(() => _currentStep = 1),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityOption({
    required double factor,
    required String title,
    required String description,
    required String emoji,
  }) {
    final isSelected = (_activityFactor - factor).abs() < 0.05;

    return GestureDetector(
      onTap: () => setState(() => _activityFactor = factor),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFE8DB) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? MallowColors.charcoal : MallowColors.borderSubtle,
            width: isSelected ? 2.2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isSelected ? MallowColors.hotPink : const Color(0xFFFAF6EE),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: MallowTypography.bodyMedium(
                      weight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: MallowColors.charcoal,
                    ),
                  ),
                  Text(
                    description,
                    style: MallowTypography.bodySmall(color: MallowColors.textSubtle),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
              color: isSelected ? MallowColors.charcoal : MallowColors.borderSubtle,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionNavigator({
    String? prevTitle,
    VoidCallback? onPrev,
    required String nextTitle,
    required VoidCallback onNext,
  }) {
    return Row(
      children: [
        if (prevTitle != null && onPrev != null) ...[
          OutlinedButton(
            onPressed: onPrev,
            style: OutlinedButton.styleFrom(
              foregroundColor: MallowColors.charcoal,
              side: const BorderSide(color: MallowColors.charcoal, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            child: Text(prevTitle, style: MallowTypography.buttonText()),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: MallowColors.charcoal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            child: Text(
              nextTitle,
              style: MallowTypography.buttonText(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelectorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MallowColors.borderSubtle, width: 1.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Biological Gender', style: MallowTypography.bodyMedium(weight: FontWeight.w700)),
              Text('Fine-tunes BMR calorie burn',
                  style: MallowTypography.bodySmall(color: MallowColors.textSubtle)),
            ],
          ),
          Row(
            children: [
              _buildGenderChip(label: 'Male', isMale: true),
              const SizedBox(width: 8),
              _buildGenderChip(label: 'Female', isMale: false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenderChip({required String label, required bool isMale}) {
    final isSelected = _isMale == isMale;

    return GestureDetector(
      onTap: () => setState(() => _isMale = isMale),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? MallowColors.hotPink : const Color(0xFFFAF6EE),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? MallowColors.charcoal : MallowColors.borderSubtle,
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : MallowColors.charcoal,
          ),
        ),
      ),
    );
  }

  Widget _buildStepperButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFEFE8DB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: MallowColors.charcoal, width: 1.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(icon, size: 20, color: MallowColors.charcoal),
        ),
      ),
    );
  }

  Widget _buildStep0BottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: MallowColors.creamBg,
        border: Border(top: BorderSide(color: Color(0xFFE8DFCE), width: 1)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          key: const Key('next_goal_button'),
          onPressed: () => setState(() => _currentStep = 1),
          style: ElevatedButton.styleFrom(
            backgroundColor: MallowColors.charcoal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Next: What’s your goal?',
                style: MallowTypography.buttonText(color: Colors.white),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // STEP 1: Goal Selection
  // ==========================================
  Widget _buildStep1Body() {
    final targetKcal = _calculatedTargetKcal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Headline
        Text(
          "Hi, I'm Mallow.\nWhat's your goal?",
          style: MallowTypography.headlineLarge(fontSize: 34),
        ),
        const SizedBox(height: 28),

        // Option 1: Lose weight
        _buildGoalOption(
          goalKey: 'lose',
          title: 'Lose weight',
          iconData: Icons.arrow_downward,
          tagText: '−300 kcal',
        ),
        const SizedBox(height: 14),

        // Option 2: Stay steady
        _buildGoalOption(
          goalKey: 'steady',
          title: 'Stay steady',
          iconText: '=',
          tagText: 'maintain',
        ),
        const SizedBox(height: 14),

        // Option 3: Build up
        _buildGoalOption(
          goalKey: 'build',
          title: 'Build up',
          iconData: Icons.arrow_upward,
          tagText: '+300 kcal',
        ),
        const SizedBox(height: 26),

        // Target summary card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: MallowColors.cardCream,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Your daily target\nfrom height, weight and\nactivity',
                  style: MallowTypography.bodyMedium(
                    color: MallowColors.charcoal,
                    weight: FontWeight.w500,
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    targetKcal.toString().replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},',
                    ),
                    style: MallowTypography.bigNumber(fontSize: 34),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'kcal',
                    style: MallowTypography.bodySmall(
                      color: MallowColors.charcoal,
                      weight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        Center(
          child: TextButton.icon(
            onPressed: () => setState(() => _currentStep = 2),
            icon: const Icon(Icons.tune, size: 16, color: MallowColors.charcoal),
            label: Text(
              'Detailed Plan Preview & Macros →',
              style: MallowTypography.bodySmall(
                color: MallowColors.charcoal,
                weight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildGoalOption({
    required String goalKey,
    required String title,
    IconData? iconData,
    String? iconText,
    required String tagText,
  }) {
    final isSelected = _selectedGoal == goalKey;
    final bgColor = isSelected ? MallowColors.oliveGreen : Colors.white;
    final textColor = isSelected ? Colors.white : MallowColors.charcoal;
    final subColor = isSelected ? Colors.white70 : MallowColors.textSubtle;

    return GestureDetector(
      onTap: () => setState(() => _selectedGoal = goalKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: MallowColors.charcoal,
            width: 2.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isSelected ? 0.08 : 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFE8E0D2) : const Color(0xFFEFE8DB),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: iconData != null
                    ? Icon(iconData, size: 18, color: MallowColors.charcoal)
                    : Text(
                        iconText ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: MallowColors.charcoal,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: MallowTypography.headlineSmall(color: textColor),
              ),
            ),
            Text(
              tagText,
              style: MallowTypography.bodySmall(
                color: subColor,
                weight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPinkDome(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: const BoxDecoration(
        color: MallowColors.hotPink,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(200),
          topRight: Radius.circular(200),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildEye(),
              const SizedBox(width: 14),
              _buildEye(),
            ],
          ),
          const SizedBox(height: 18),
          Material(
            color: Colors.transparent,
            child: InkWell(
              key: const Key('looks_good_button'),
              borderRadius: BorderRadius.circular(28),
              onTap: _saveAndFinish,
              child: Ink(
                padding: const EdgeInsets.symmetric(horizontal: 46, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.14),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Looks good',
                  style: MallowTypography.buttonText(
                    color: MallowColors.charcoal,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget _buildEye() {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Align(
        alignment: const Alignment(0.4, -0.3),
        child: Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: MallowColors.charcoal,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // STEP 2: Summary & Launch
  // ==========================================
  Widget _buildStep2Body() {
    final targetKcal = _calculatedTargetKcal;
    final proteinGoal = _calculatedProteinGoal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Your custom\nplan is ready!",
          style: MallowTypography.headlineLarge(fontSize: 34),
        ),
        const SizedBox(height: 8),
        Text(
          "Here is what Mallow prepared based on your profile:",
          style: MallowTypography.bodyMedium(color: MallowColors.textSubtle),
        ),
        const SizedBox(height: 24),

        _buildSummaryStat(
          color: MallowColors.hotPink,
          label: 'Daily Calories',
          value: '$targetKcal kcal',
          note: _selectedGoal == 'lose'
              ? '300 kcal deficit for fat loss'
              : _selectedGoal == 'build'
                  ? '300 kcal surplus for muscle gain'
                  : 'Maintenance target',
        ),
        const SizedBox(height: 14),

        _buildSummaryStat(
          color: MallowColors.oliveGreen,
          label: 'Protein Goal',
          value: '${proteinGoal.round()} g',
          note: '1.6 g per kg of body weight',
        ),
        const SizedBox(height: 14),

        _buildSummaryStat(
          color: MallowColors.slateBlue,
          label: 'Gym Burn Target',
          value: '500 kcal',
          note: 'Calculated using MET scores in Gym tracker',
        ),
        const SizedBox(height: 26),
      ],
    );
  }

  Widget _buildSummaryStat({
    required Color color,
    required String label,
    required String value,
    required String note,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: MallowColors.borderSubtle, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: MallowTypography.bodySmall(color: MallowColors.textSubtle),
                ),
                Text(
                  value,
                  style: MallowTypography.headlineSmall(fontSize: 22),
                ),
                Text(
                  note,
                  style: MallowTypography.bodySmall(color: MallowColors.textSubtle),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2BottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: MallowColors.creamBg,
        border: Border(top: BorderSide(color: Color(0xFFE8DFCE), width: 1)),
      ),
      child: Row(
        children: [
          MallowCircleButton(
            size: 48,
            onTap: () => setState(() => _currentStep = 1),
            child: const Icon(Icons.arrow_back, size: 20, color: MallowColors.charcoal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                key: const Key('lets_start_button'),
                onPressed: _saveAndFinish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MallowColors.charcoal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                ),
                child: Text(
                  'Let’s start!',
                  style: MallowTypography.buttonText(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

