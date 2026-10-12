import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/mallow_theme.dart';
import '../../core/theme/mallow_widgets.dart';
import '../../core/theme/mallow_toast.dart';
import '../../core/formulas/formulas.dart';
import '../../core/providers/providers.dart';

class BodyScreen extends ConsumerStatefulWidget {
  const BodyScreen({super.key});

  @override
  ConsumerState<BodyScreen> createState() => _BodyScreenState();
}

class _BodyScreenState extends ConsumerState<BodyScreen> {
  int _selectedPeriodIndex = 0; // 0: Weeks, 1: Months

  void _showLogWeightDialog(double currentWeight) {
    double tempWeight = currentWeight;
    final controller = TextEditingController(text: currentWeight.toStringAsFixed(1));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (modalCtx, setModalState) => Container(
          padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(modalCtx).viewInsets.bottom + 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4CCBF),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                "Log today's weight",
                style: MallowTypography.headlineMedium(),
              ),
              const SizedBox(height: 6),
              Text(
                'Track your progress towards your goal weight.',
                style: MallowTypography.bodySmall(color: MallowColors.textSubtle),
              ),
              const SizedBox(height: 20),

              // Large numeric display with steppers
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: MallowColors.cardCream,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildQuickButton(
                          label: '−1',
                          onTap: () {
                            tempWeight = (tempWeight - 1.0).clamp(35.0, 200.0);
                            controller.text = tempWeight.toStringAsFixed(1);
                            setModalState(() {});
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildQuickButton(
                          label: '−0.1',
                          onTap: () {
                            tempWeight = (tempWeight - 0.1).clamp(35.0, 200.0);
                            controller.text = tempWeight.toStringAsFixed(1);
                            setModalState(() {});
                          },
                        ),
                      ],
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          '${tempWeight.toStringAsFixed(1)} kg',
                          style: MallowTypography.bigNumber(fontSize: 28),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        _buildQuickButton(
                          label: '+0.1',
                          onTap: () {
                            tempWeight = (tempWeight + 0.1).clamp(35.0, 200.0);
                            controller.text = tempWeight.toStringAsFixed(1);
                            setModalState(() {});
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildQuickButton(
                          label: '+1',
                          onTap: () {
                            tempWeight = (tempWeight + 1.0).clamp(35.0, 200.0);
                            controller.text = tempWeight.toStringAsFixed(1);
                            setModalState(() {});
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(sheetCtx);
                    await ref.read(weightLogsProvider.notifier).logWeight(tempWeight);
                    if (!mounted) return;
                    MallowToast.show(context, 'Weight updated to ${tempWeight.toStringAsFixed(1)} kg');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MallowColors.charcoal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                  ),
                  child: Text(
                    'Save Weight',
                    style: MallowTypography.buttonText(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditHeightDialog(double currentHeight) {
    double tempHeight = currentHeight;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (modalCtx, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Update Height', style: MallowTypography.headlineMedium()),
              const SizedBox(height: 6),
              Text('Used for BMR and BMI calculations.', style: MallowTypography.bodySmall(color: MallowColors.textSubtle)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildQuickButton(
                    label: '−1 cm',
                    onTap: () {
                      tempHeight = (tempHeight - 1).clamp(100.0, 240.0);
                      setModalState(() {});
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text('${tempHeight.round()} cm', style: MallowTypography.bigNumber(fontSize: 32)),
                  ),
                  _buildQuickButton(
                    label: '+1 cm',
                    onTap: () {
                      tempHeight = (tempHeight + 1).clamp(100.0, 240.0);
                      setModalState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(sheetCtx);
                    await ref.read(profileProvider.notifier).updateHeight(tempHeight);
                    if (!mounted) return;
                    MallowToast.show(context, 'Height set to ${tempHeight.round()} cm');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MallowColors.charcoal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: Text('Save Height', style: MallowTypography.buttonText(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditWaistDialog(double currentWaist) {
    double tempWaist = currentWaist;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (modalCtx, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Update Waist', style: MallowTypography.headlineMedium()),
              const SizedBox(height: 6),
              Text('Measure around your navel for body composition.', style: MallowTypography.bodySmall(color: MallowColors.textSubtle)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildQuickButton(
                    label: '−1 cm',
                    onTap: () {
                      tempWaist = (tempWaist - 1).clamp(40.0, 180.0);
                      setModalState(() {});
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text('${tempWaist.round()} cm', style: MallowTypography.bigNumber(fontSize: 32)),
                  ),
                  _buildQuickButton(
                    label: '+1 cm',
                    onTap: () {
                      tempWaist = (tempWaist + 1).clamp(40.0, 180.0);
                      setModalState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(sheetCtx);
                    await ref.read(profileProvider.notifier).updateWaist(tempWaist);
                    if (!mounted) return;
                    MallowToast.show(context, 'Waist set to ${tempWaist.round()} cm');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MallowColors.charcoal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: Text('Save Waist', style: MallowTypography.buttonText(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditGoalDialog(double currentGoal) {
    double tempGoal = currentGoal;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (modalCtx, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Target Weight Goal', style: MallowTypography.headlineMedium()),
              const SizedBox(height: 6),
              Text('Set your target weight goal to track progress.', style: MallowTypography.bodySmall(color: MallowColors.textSubtle)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildQuickButton(
                    label: '−0.5 kg',
                    onTap: () {
                      tempGoal = (tempGoal - 0.5).clamp(35.0, 180.0);
                      setModalState(() {});
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text('${tempGoal.toStringAsFixed(1)} kg', style: MallowTypography.bigNumber(fontSize: 30)),
                  ),
                  _buildQuickButton(
                    label: '+0.5 kg',
                    onTap: () {
                      tempGoal = (tempGoal + 0.5).clamp(35.0, 180.0);
                      setModalState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(sheetCtx);
                    await ref.read(profileProvider.notifier).updateTargetWeight(tempGoal);
                    if (!mounted) return;
                    MallowToast.show(context, 'Goal weight set to ${tempGoal.toStringAsFixed(1)} kg');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MallowColors.charcoal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: Text('Save Goal Weight', style: MallowTypography.buttonText(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBmiInfoDialog(double bmi) {
    String category = 'Normal weight';
    Color catColor = MallowColors.oliveGreen;
    if (bmi < 18.5) {
      category = 'Underweight';
      catColor = MallowColors.slateBlue;
    } else if (bmi >= 25.0 && bmi < 30.0) {
      category = 'Overweight';
      catColor = const Color(0xFFD97706);
    } else if (bmi >= 30.0) {
      category = 'Obese range';
      catColor = Colors.redAccent;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('BMI: ${bmi.toStringAsFixed(1)}', style: MallowTypography.headlineMedium()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: catColor, borderRadius: BorderRadius.circular(12)),
              child: Text(category, style: MallowTypography.bodySmall(color: Colors.white, weight: FontWeight.w700)),
            ),
            const SizedBox(height: 12),
            Text(
              'Standard BMI categories:\n• Underweight: < 18.5\n• Normal weight: 18.5 – 24.9\n• Overweight: 25 – 29.9\n• Obese: ≥ 30',
              style: MallowTypography.bodyMedium(color: MallowColors.charcoal),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Got it', style: MallowTypography.buttonText(color: MallowColors.charcoal)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: MallowColors.charcoal, width: 1.5),
        ),
        child: Text(
          label,
          style: MallowTypography.bodySmall(weight: FontWeight.bold, color: MallowColors.charcoal),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final weightHistory = ref.watch(weightLogsProvider);

    // Calculate dynamic values
    final currentWeight = profile.weightKg;
    final bmi = MallowFormulas.calculateBMI(
      weightKg: currentWeight,
      heightCm: profile.heightCm,
    );
    final toGoal = (currentWeight - profile.targetWeightKg).clamp(0.0, 999.0);

    // Weight delta over 7 weeks
    final initialWeight = weightHistory.isNotEmpty ? weightHistory.first.weightKg : 70.1;
    final delta = initialWeight - currentWeight;
    final deltaSign = delta >= 0 ? '↓' : '↑';
    final deltaStr = '$deltaSign ${delta.abs().toStringAsFixed(1)} kg in 7 weeks';

    return Scaffold(
      backgroundColor: MallowColors.creamBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MallowAvatar(
                    size: 38,
                    onTap: () => context.go('/pet'),
                  ),
                  // Weeks / Months Toggle
                  Container(
                    height: 38,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: MallowColors.cardCream,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildPeriodSegment(0, 'Weeks'),
                        _buildPeriodSegment(1, 'Months'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Title and "Log Weight" button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Body',
                    style: MallowTypography.headlineLarge(),
                  ),
                  MallowPillButton(
                    label: '+ Log Weight',
                    height: 36,
                    isPrimary: true,
                    onTap: () => _showLogWeightDialog(currentWeight),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Large Weight Readout (tapping opens dialog)
              GestureDetector(
                onTap: () => _showLogWeightDialog(currentWeight),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      currentWeight.toStringAsFixed(1),
                      style: MallowTypography.bigNumber(fontSize: 54),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'kg',
                      style: MallowTypography.headlineMedium(color: MallowColors.charcoal),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.edit_outlined, size: 20, color: MallowColors.textSubtle),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Green badge for 7-week delta
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: MallowColors.oliveGreen,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  deltaStr,
                  style: MallowTypography.bodySmall(
                    color: Colors.white,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // Chart Card
              Container(
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 16),
                decoration: BoxDecoration(
                  color: MallowColors.cardCream,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 160,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: _WeightChartPainter(
                          weights: weightHistory.map((w) => w.weightKg).toList(),
                          goalWeight: profile.targetWeightKg,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Axis labels
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedPeriodIndex == 0 ? '7 weeks ago' : '6 months ago',
                          style: MallowTypography.bodySmall(color: MallowColors.textSubtle),
                        ),
                        Text(
                          'Today',
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
              const SizedBox(height: 24),

              // Stepper Section: Log today's weight
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Quick adjust (0.1 kg)",
                    style: MallowTypography.headlineSmall(),
                  ),
                  Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: MallowColors.charcoal,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          icon: const Icon(Icons.remove, color: Colors.white, size: 18),
                          onPressed: () async {
                            final newW = (currentWeight - 0.1).clamp(35.0, 200.0);
                            await ref.read(weightLogsProvider.notifier).logWeight(newW);
                            if (context.mounted) {
                              MallowToast.show(context, 'Weight: ${newW.toStringAsFixed(1)} kg');
                            }
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            '0.1',
                            style: MallowTypography.buttonText(color: Colors.white),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          icon: const Icon(Icons.add, color: Colors.white, size: 18),
                          onPressed: () async {
                            final newW = (currentWeight + 0.1).clamp(35.0, 200.0);
                            await ref.read(weightLogsProvider.notifier).logWeight(newW);
                            if (context.mounted) {
                              MallowToast.show(context, 'Weight: ${newW.toStringAsFixed(1)} kg');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 4 Interactive Stat Tiles: Height, BMI, Waist, To goal
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.45,
                children: [
                  _buildStatTile(
                    title: 'Height',
                    value: '${profile.heightCm.round()} cm',
                    hint: 'Tap to edit',
                    onTap: () => _showEditHeightDialog(profile.heightCm),
                  ),
                  _buildStatTile(
                    title: 'BMI',
                    value: bmi.toStringAsFixed(1),
                    hint: 'Tap for info',
                    onTap: () => _showBmiInfoDialog(bmi),
                  ),
                  _buildStatTile(
                    title: 'Waist',
                    value: '${profile.waistCm.round()} cm',
                    hint: 'Tap to edit',
                    onTap: () => _showEditWaistDialog(profile.waistCm),
                  ),
                  _buildStatTile(
                    title: 'To goal',
                    value: '${toGoal.toStringAsFixed(1)} kg',
                    hint: 'Tap to set goal',
                    onTap: () => _showEditGoalDialog(profile.targetWeightKg),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSegment(int index, String label) {
    final isSelected = _selectedPeriodIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriodIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? MallowColors.charcoal : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: MallowTypography.bodySmall(
            color: isSelected ? Colors.white : MallowColors.charcoal,
            weight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildStatTile({
    required String title,
    required String value,
    required String hint,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: MallowColors.cardCream,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.black12, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: MallowTypography.bodySmall(color: MallowColors.textSubtle),
                ),
                const Icon(Icons.edit_outlined, size: 14, color: MallowColors.textSubtle),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: MallowTypography.headlineMedium(color: MallowColors.charcoal),
            ),
            const SizedBox(height: 2),
            Text(
              hint,
              style: MallowTypography.bodySmall(color: MallowColors.textSubtle),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  final List<double> weights;
  final double goalWeight;

  _WeightChartPainter({
    required this.weights,
    required this.goalWeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (weights.isEmpty) return;

    final paintLine = Paint()
      ..color = MallowColors.charcoal
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final paintGoal = Paint()
      ..color = const Color(0xFFDCD4C7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final paintDot = Paint()
      ..color = MallowColors.charcoal
      ..style = PaintingStyle.fill;

    final paintDotInner = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Determine min and max Y
    final allValues = [...weights, goalWeight];
    final minVal = (allValues.reduce(math.min) - 1.0).floorToDouble();
    final maxVal = (allValues.reduce(math.max) + 1.0).ceilToDouble();
    final range = maxVal - minVal;

    double getY(double val) {
      if (range <= 0) return size.height / 2;
      final normalized = (val - minVal) / range;
      return size.height - (normalized * size.height);
    }

    // Draw goal dashed line
    final goalY = getY(goalWeight);
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    double startX = 0.0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, goalY),
        Offset(math.min(startX + dashWidth, size.width), goalY),
        paintGoal,
      );
      startX += dashWidth + dashSpace;
    }

    // Draw weights curve
    final path = Path();
    final stepX = weights.length > 1 ? size.width / (weights.length - 1) : size.width;

    for (int i = 0; i < weights.length; i++) {
      final x = i * stepX;
      final y = getY(weights[i]);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevX = (i - 1) * stepX;
        final prevY = getY(weights[i - 1]);
        final controlX1 = prevX + (x - prevX) / 2;
        final controlX2 = controlX1;
        path.cubicTo(controlX1, prevY, controlX2, y, x, y);
      }
    }

    canvas.drawPath(path, paintLine);

    // Draw dots
    for (int i = 0; i < weights.length; i++) {
      final x = i * stepX;
      final y = getY(weights[i]);
      canvas.drawCircle(Offset(x, y), 5.0, paintDot);
      canvas.drawCircle(Offset(x, y), 2.5, paintDotInner);
    }
  }

  @override
  bool shouldRepaint(covariant _WeightChartPainter oldDelegate) {
    return oldDelegate.weights != weights || oldDelegate.goalWeight != goalWeight;
  }
}
