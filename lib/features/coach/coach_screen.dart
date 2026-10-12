import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/mallow_theme.dart';
import '../../core/theme/mallow_widgets.dart';
import '../../core/theme/mallow_characters.dart';
import '../../core/theme/mallow_toast.dart';
import '../../core/providers/providers.dart';

class CoachScreen extends ConsumerWidget {
  const CoachScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remaining = ref.watch(remainingProvider);
    final totals = ref.watch(todayTotalsProvider);
    final streak = ref.watch(streakProvider);

    final isTodayDone = streak.savedToday || totals.eatenKcal > 0;
    final currentWeekday = DateTime.now().weekday; // 1 (Mon) to 7 (Sun)
    final daysOfWeek = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    // Tip 1: Calorie rule
    String tip1Title;
    String tip1Body;
    if (totals.eatenKcal == 0) {
      tip1Title = 'Fresh day';
      tip1Body = '${remaining.remainingKcal} kcal budget ready. Log your first meal to kick off your streak!';
    } else if (remaining.remainingKcal > 900) {
      tip1Title = 'Room to eat';
      tip1Body = '${remaining.remainingKcal} kcal left. A proper dinner fits nicely.';
    } else if (remaining.remainingKcal >= 0) {
      tip1Title = 'Nearly there';
      tip1Body = '${remaining.remainingKcal} kcal left. Keep it light for the rest of today.';
    } else {
      final over = remaining.remainingKcal.abs();
      final walkMins = (over / 4.5).round();
      tip1Title = 'A little over';
      tip1Body = '$over kcal over. A $walkMins-minute evening walk will balance it out.';
    }

    // Tip 2: Protein rule
    String tip2Title;
    String tip2Body;
    if (totals.eatenKcal == 0) {
      tip2Title = 'Protein goal';
      tip2Body = 'Target is ${remaining.remainingProtein.round()} g today. Eggs, chicken, or yogurt will power your day.';
    } else if (remaining.remainingProtein > 30.0) {
      tip2Title = 'Protein is low';
      tip2Body = '${remaining.remainingProtein.round()} g to go. Eggs or yogurt would help.';
    } else {
      tip2Title = 'Protein on track';
      tip2Body = 'Great protein intake today! Your muscles have what they need to recover.';
    }

    return Scaffold(
      backgroundColor: MallowColors.darkForestGreen,
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
                  // "Ask Mallow" Pill Button
                  MallowPillButton(
                    label: 'Ask Mallow',
                    height: 38,
                    backgroundColor: MallowColors.cardCream,
                    textColor: MallowColors.charcoal,
                    onTap: () => context.push('/chat'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Here when\nyou need us.',
                style: MallowTypography.headlineLarge(color: Colors.white),
              ),
              const SizedBox(height: 16),

              // Two Characters Illustration (Mallow + Companion)
              Center(
                child: SizedBox(
                  height: 140,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // Tall blue-grey companion behind on right
                      const Positioned(
                        right: 40,
                        bottom: 0,
                        child: MallowCompanion(width: 95, height: 130),
                      ),
                      // Pink Mallow character in front on left
                      const Positioned(
                        left: 40,
                        bottom: 0,
                        child: MallowCharacter(
                          width: 110,
                          height: 95,
                          mood: MallowMood.happy,
                          animateBob: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Card 1: Fresh Streak Card for New User
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: MallowColors.creamBg,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isTodayDone ? 'Day ${streak.streakDays} on target 🔥' : 'Day 1 of your journey',
                          style: MallowTypography.headlineSmall(color: MallowColors.charcoal),
                        ),
                        if (isTodayDone)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: MallowColors.oliveGreenLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Active',
                              style: MallowTypography.bodySmall(
                                color: MallowColors.oliveGreen,
                                weight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isTodayDone
                          ? '${totals.eatenKcal} kcal logged today. Great start to your streak!'
                          : 'Start your streak today. Log a meal or tap Nice! below.',
                      style: MallowTypography.bodySmall(color: MallowColors.textSubtle),
                    ),
                    const SizedBox(height: 16),

                    // Days row: M T W T F S S with active day highlighting
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (index) {
                        final dayNum = index + 1;
                        final letter = daysOfWeek[index];
                        final isToday = dayNum == currentWeekday;
                        final isPast = dayNum < currentWeekday;

                        return _buildDayMarker(
                          letter,
                          isHit: (isToday && isTodayDone),
                          isToday: (isToday && !isTodayDone),
                          isUntracked: isPast,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Card 2: Calorie Tip
              _buildTipCard(title: tip1Title, body: tip1Body),
              const SizedBox(height: 14),

              // Card 3: Protein Tip
              _buildTipCard(title: tip2Title, body: tip2Body),
              const SizedBox(height: 24),

              // "Nice!" Hot Pink Button
              MallowPillButton(
                label: 'Nice!',
                width: double.infinity,
                height: 52,
                onTap: () {
                  ref.read(streakProvider.notifier).saveToday();
                  MallowToast.show(context, 'Streak saved! Day ${streak.streakDays} logged 🔥');
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayMarker(
    String dayLetter, {
    bool isHit = false,
    bool isToday = false,
    bool isUntracked = false,
  }) {
    Widget indicator;

    if (isHit) {
      indicator = Container(
        width: 34,
        height: 34,
        decoration: const BoxDecoration(
          color: MallowColors.oliveGreen,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(Icons.check, size: 20, color: Colors.white),
        ),
      );
    } else if (isToday) {
      // Active Today marker: Dashed pink border with center dot
      indicator = Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: MallowColors.hotPink,
            width: 2.2,
          ),
        ),
        child: Center(
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: MallowColors.hotPink,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    } else {
      // Unlogged / upcoming day: clean subtle circle
      indicator = Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isUntracked ? const Color(0xFFCCC5B8) : const Color(0xFFDDD6CA),
            width: 1.5,
          ),
        ),
      );
    }

    return Column(
      children: [
        indicator,
        const SizedBox(height: 6),
        Text(
          dayLetter,
          style: MallowTypography.bodySmall(
            color: isToday ? MallowColors.hotPink : MallowColors.charcoal,
            weight: isToday ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTipCard({required String title, required String body}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MallowColors.creamBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: MallowTypography.headlineSmall(color: MallowColors.charcoal),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: MallowTypography.bodyMedium(
              color: MallowColors.textSubtle,
              weight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
