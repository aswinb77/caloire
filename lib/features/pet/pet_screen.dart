import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/mallow_theme.dart';
import '../../core/theme/mallow_widgets.dart';
import '../../core/theme/mallow_characters.dart';
import '../../core/theme/mallow_toast.dart';
import '../../core/providers/providers.dart';

class PetScreen extends ConsumerWidget {
  const PetScreen({super.key});

  String _getSpeechBubbleText(MallowMood mood, int eatenKcal, int targetKcal) {
    switch (mood) {
      case MallowMood.sleepy:
        return "I'm feeling so sleepy... Time for a rest!";
      case MallowMood.hungry:
        return "My tummy is rumbling! Log some food to feed me.";
      case MallowMood.happy:
        return "You're doing awesome today! We're crushing it!";
      case MallowMood.chill:
        return "Just chilling and staying steady with you.";
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petState = ref.watch(petStateProvider);
    final mood = ref.watch(petMoodProvider);
    final totals = ref.watch(todayTotalsProvider);
    final profile = ref.watch(profileProvider);

    final fullnessProgress = profile.dailyTargetKcal > 0
        ? (totals.eatenKcal / profile.dailyTargetKcal).clamp(0.0, 1.0)
        : 0.0;
    final energyProgress = (petState.energy / 100.0).clamp(0.0, 1.0);
    final joyProgress = (petState.joy / 100.0).clamp(0.0, 1.0);

    final speech = _getSpeechBubbleText(mood, totals.eatenKcal, profile.dailyTargetKcal);

    return Scaffold(
      backgroundColor: MallowColors.creamBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  Text(
                    'Mallow',
                    style: MallowTypography.headlineMedium(),
                  ),
                  MallowCircleButton(
                    size: 38,
                    backgroundColor: MallowColors.cardCream,
                    onTap: () => context.push('/chat'),
                    child: const Icon(Icons.chat_bubble_outline, size: 20, color: MallowColors.charcoal),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Speech Bubble
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: MallowColors.charcoal, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  speech,
                  textAlign: TextAlign.center,
                  style: MallowTypography.bodyMedium(
                    color: MallowColors.charcoal,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Speech pointer triangle
              CustomPaint(
                size: const Size(16, 10),
                painter: _SpeechArrowPainter(),
              ),
              const SizedBox(height: 16),

              // Pet Bobbing Character
              MallowCharacter(
                width: 170,
                height: 150,
                mood: mood,
                animateBob: true,
              ),
              const SizedBox(height: 12),

              // Mood Tag Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: MallowColors.cardCream,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Mood: ${mood.name.toUpperCase()}',
                  style: MallowTypography.bodySmall(
                    color: MallowColors.charcoal,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Care Actions: Feed, Play, Rest
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCareAction(
                    context: context,
                    label: 'Feed',
                    emoji: '🥣',
                    color: MallowColors.cardCream,
                    onTap: () {
                      context.push('/food');
                    },
                  ),
                  const SizedBox(width: 14),
                  _buildCareAction(
                    context: context,
                    label: 'Play',
                    emoji: '🎾',
                    color: MallowColors.cardCream,
                    onTap: () {
                      ref.read(petStateProvider.notifier).play();
                      MallowToast.show(context, 'Played with Mallow! (+15 Joy, -20 Energy)');
                    },
                  ),
                  const SizedBox(width: 14),
                  _buildCareAction(
                    context: context,
                    label: 'Rest',
                    emoji: '💤',
                    color: MallowColors.cardCream,
                    onTap: () {
                      ref.read(petStateProvider.notifier).rest();
                      MallowToast.show(context, 'Mallow rested! (+30 Energy)');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Three Stat Bars: Fullness, Energy, Joy
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: MallowColors.borderSubtle),
                ),
                child: Column(
                  children: [
                    _buildStatBar(
                      label: 'Fullness',
                      progress: fullnessProgress,
                      barColor: MallowColors.hotPink,
                      valueText: '${(fullnessProgress * 100).round()}%',
                    ),
                    const SizedBox(height: 16),
                    _buildStatBar(
                      label: 'Energy',
                      progress: energyProgress,
                      barColor: MallowColors.oliveGreen,
                      valueText: '${petState.energy}/100',
                    ),
                    const SizedBox(height: 16),
                    _buildStatBar(
                      label: 'Joy',
                      progress: joyProgress,
                      barColor: MallowColors.slateBlue,
                      valueText: '${petState.joy}/100',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCareAction({
    required BuildContext context,
    required String label,
    required String emoji,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 94,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: MallowColors.charcoal, width: 2),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 6),
            Text(
              label,
              style: MallowTypography.buttonText(color: MallowColors.charcoal),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBar({
    required String label,
    required double progress,
    required Color barColor,
    required String valueText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: MallowTypography.bodySmall(
                color: MallowColors.charcoal,
                weight: FontWeight.w700,
              ),
            ),
            Text(
              valueText,
              style: MallowTypography.bodySmall(
                color: MallowColors.textSubtle,
                weight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Container(
                height: 10,
                width: double.infinity,
                color: const Color(0xFFECE5D8),
              ),
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  height: 10,
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SpeechArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = MallowColors.charcoal
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
