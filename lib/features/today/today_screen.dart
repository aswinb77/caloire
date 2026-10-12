import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/mallow_theme.dart';
import '../../core/theme/mallow_widgets.dart';
import '../../core/providers/providers.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totals = ref.watch(todayTotalsProvider);
    final remaining = ref.watch(remainingProvider);
    final profile = ref.watch(profileProvider);
    final suggestions = ref.watch(suggestionsProvider);

    return Scaffold(
      backgroundColor: MallowColors.creamBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MallowAvatar(
                    size: 38,
                    onTap: () => context.go('/pet'),
                  ),
                  Row(
                    children: [
                      // "Add food" hot pink pill button
                      MallowPillButton(
                        label: 'Log Food',
                        onTap: () => context.push('/food'),
                        isPrimary: true,
                        height: 38,
                        width: 85,
                      ),
                      const SizedBox(width: 10),
                      // Menu hamburger button
                      MallowCircleButton(
                        size: 38,
                        backgroundColor: MallowColors.cardCream,
                        onTap: () => context.push('/settings'),
                        child: const Icon(
                          Icons.menu,
                          size: 20,
                          color: MallowColors.charcoal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 2. Rings Card
              _buildRingsCard(context, totals, remaining, profile),
              const SizedBox(height: 26),

              // 3. Suggestions Section
              Text(
                'Suggestions',
                style: MallowTypography.headlineSmall(),
              ),
              const SizedBox(height: 14),
              _buildSuggestionsStrip(suggestions),
              const SizedBox(height: 26),

              // 4. Meals Section
              Text(
                'Meals',
                style: MallowTypography.headlineSmall(),
              ),
              const SizedBox(height: 14),
              _buildMealsList(context, totals, profile),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRingsCard(BuildContext context, TodayTotals totals, RemainingData remaining, profile) {
    // Outer: eaten / (goal + burned)
    final outerTarget = remaining.totalBudget > 0 ? remaining.totalBudget : 2000;
    final outerProgress = (totals.eatenKcal / outerTarget).clamp(0.0, 1.0);

    // Middle: protein / 110g (or profile protein goal)
    final middleTarget = profile.proteinGoalG > 0 ? profile.proteinGoalG : 110.0;
    final middleProgress = (totals.proteinG / middleTarget).clamp(0.0, 1.0);

    // Inner: burned / 500 kcal (or profile burn goal)
    final innerTarget = profile.burnGoalKcal > 0 ? profile.burnGoalKcal : 500;
    final innerProgress = (totals.burnedKcal / innerTarget).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        color: MallowColors.cardCream,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          // Concentric Rings
          Expanded(
            flex: 5,
            child: AspectRatio(
              aspectRatio: 1.0,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (context, animValue, child) {
                  return CustomPaint(
                    painter: _ConcentricRingsPainter(
                      outerProgress: outerProgress * animValue,
                      middleProgress: middleProgress * animValue,
                      innerProgress: innerProgress * animValue,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            remaining.isOver
                                ? '-${remaining.remainingKcal.abs()}'
                                : '${remaining.remainingKcal}',
                            style: MallowTypography.bigNumber(
                              fontSize: 30,
                              color: MallowColors.charcoal,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            remaining.isOver ? 'kcal over' : 'kcal left',
                            style: MallowTypography.bodySmall(
                              color: MallowColors.textSubtle,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Legend
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(
                  dotColor: MallowColors.hotPink,
                  label: 'Eaten',
                  value: '${totals.eatenKcal}',
                  onTap: () => context.push('/food'),
                ),
                const SizedBox(height: 16),
                _buildLegendItem(
                  dotColor: MallowColors.oliveGreen,
                  label: 'Protein',
                  value: '${totals.proteinG.round()} g',
                  onTap: () => context.push('/food'),
                ),
                const SizedBox(height: 16),
                _buildLegendItem(
                  dotColor: MallowColors.slateBlue,
                  label: 'Burned',
                  value: '${totals.burnedKcal}',
                  onTap: () => context.go('/workout'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color dotColor,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: MallowTypography.bodySmall(
                    color: MallowColors.textSubtle,
                    weight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: MallowTypography.headlineSmall(
                    color: MallowColors.charcoal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsStrip(List<SuggestionCardData> suggestions) {
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: suggestions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = suggestions[index];
          final bg = item.isOlive ? MallowColors.oliveGreen : MallowColors.slateBlue;
          final textColor = Colors.white;

          return Container(
            width: 180,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.title,
                  style: MallowTypography.headlineSmall(color: textColor),
                ),
                Text(
                  item.subtitle,
                  style: MallowTypography.bodySmall(
                    color: textColor.withValues(alpha: 0.92),
                    weight: FontWeight.w500,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMealsList(BuildContext context, TodayTotals totals, profile) {
    final dailyGoal = profile.dailyTargetKcal;
    final bfastTarget = (dailyGoal * 0.25).round();
    final lunchTarget = (dailyGoal * 0.30).round();
    final dinnerTarget = (dailyGoal * 0.30).round();
    final snackTarget = (dailyGoal * 0.15).round();

    return Column(
      children: [
        _buildMealRow(
          context: context,
          name: 'Breakfast',
          calories: totals.breakfastKcal,
          targetKcal: bfastTarget,
        ),
        const SizedBox(height: 14),
        _buildMealRow(
          context: context,
          name: 'Lunch',
          calories: totals.lunchKcal,
          targetKcal: lunchTarget,
        ),
        const SizedBox(height: 14),
        _buildMealRow(
          context: context,
          name: 'Dinner',
          calories: totals.dinnerKcal,
          targetKcal: dinnerTarget,
        ),
        const SizedBox(height: 14),
        _buildMealRow(
          context: context,
          name: 'Snack',
          calories: totals.snackKcal,
          targetKcal: snackTarget,
        ),
      ],
    );
  }

  Widget _buildMealRow({
    required BuildContext context,
    required String name,
    required int calories,
    required int targetKcal,
  }) {
    final progress = targetKcal > 0 ? (calories / targetKcal).clamp(0.0, 1.0) : 0.0;

    return GestureDetector(
      onTap: () {
        context.push('/food?meal=$name');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: MallowColors.borderSubtle, width: 1.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: MallowTypography.headlineSmall(color: MallowColors.charcoal),
                ),
                Row(
                  children: [
                    Text(
                      '$calories',
                      style: MallowTypography.headlineSmall(color: MallowColors.charcoal),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'kcal',
                      style: MallowTypography.bodySmall(color: MallowColors.textSubtle),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Stack(
                children: [
                  Container(
                    height: 8,
                    width: double.infinity,
                    color: const Color(0xFFEFE8DB),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: calories > 0 ? MallowColors.hotPink : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConcentricRingsPainter extends CustomPainter {
  final double outerProgress;
  final double middleProgress;
  final double innerProgress;

  _ConcentricRingsPainter({
    required this.outerProgress,
    required this.middleProgress,
    required this.innerProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = size.width * 0.072;
    final spacing = strokeWidth * 1.35;

    final outerRadius = (size.width / 2) - (strokeWidth / 2);
    final middleRadius = outerRadius - spacing;
    final innerRadius = middleRadius - spacing;

    // Draw background tracks
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = const Color(0xFFDDD5C7)
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, outerRadius, bgPaint);
    canvas.drawCircle(center, middleRadius, bgPaint);
    canvas.drawCircle(center, innerRadius, bgPaint);

    // Helper to draw progress arc starting from top (-pi / 2)
    void drawArc(double radius, double progress, Color color) {
      if (progress <= 0) return;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = color;

      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        paint,
      );
    }

    // Outer: Pink
    drawArc(outerRadius, outerProgress, MallowColors.hotPink);
    // Middle: Olive
    drawArc(middleRadius, middleProgress, MallowColors.oliveGreen);
    // Inner: Blue
    drawArc(innerRadius, innerProgress, MallowColors.slateBlue);
  }

  @override
  bool shouldRepaint(covariant _ConcentricRingsPainter oldDelegate) {
    return oldDelegate.outerProgress != outerProgress ||
        oldDelegate.middleProgress != middleProgress ||
        oldDelegate.innerProgress != innerProgress;
  }
}
