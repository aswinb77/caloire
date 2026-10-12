import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/mallow_theme.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/today/today_screen.dart';
import '../features/food/food_screen.dart';
import '../features/workout/workout_screen.dart';
import '../features/body/body_screen.dart';
import '../features/coach/coach_screen.dart';
import '../features/pet/pet_screen.dart';
import '../features/chat/chat_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/system/system_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

Widget _fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(opacity: animation, child: child);
}

GoRouter createMallowRouter({String initialLocation = '/onboarding'}) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: initialLocation,
  routes: [
    // Check-in alias
    GoRoute(
      path: '/checkin',
      redirect: (context, state) => '/coach',
    ),
    // Onboarding Route
    GoRoute(
      path: '/onboarding',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const OnboardingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
            child: child,
          );
        },
      ),
    ),

    // Modal Pushed Food Route (Slide up from bottom like a bottom sheet)
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/food',
      pageBuilder: (context, state) {
        final mealParam = state.uri.queryParameters['meal'];
        return CustomTransitionPage(
          key: state.pageKey,
          child: FoodScreen(initialMeal: mealParam),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            );
          },
        );
      },
    ),

    // Pushed Chat Route (Slide in from right)
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/chat',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const ChatScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
      ),
    ),

    // Pushed Settings Route
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/settings',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SettingsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
      ),
    ),

    // Direct System Routes: 404, Offline, Error, Recovery
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/404',
      pageBuilder: (context, state) => const CustomTransitionPage(
        child: SystemScreen(initialTab: 0),
        transitionsBuilder: _fadeTransition,
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/offline',
      pageBuilder: (context, state) => const CustomTransitionPage(
        child: SystemScreen(initialTab: 1),
        transitionsBuilder: _fadeTransition,
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/error',
      pageBuilder: (context, state) => const CustomTransitionPage(
        child: SystemScreen(initialTab: 2),
        transitionsBuilder: _fadeTransition,
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/recovery',
      pageBuilder: (context, state) => const CustomTransitionPage(
        child: SystemScreen(initialTab: 3),
        transitionsBuilder: _fadeTransition,
      ),
    ),

    // System States Route
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/system',
      pageBuilder: (context, state) {
        final tabStr = state.uri.queryParameters['tab'];
        final tab = int.tryParse(tabStr ?? '0') ?? 0;
        return CustomTransitionPage(
          key: state.pageKey,
          child: SystemScreen(initialTab: tab),
          transitionsBuilder: _fadeTransition,
        );
      },
    ),

    // Main App Shell Route (5 tabs: Today, Workout, Coach, Body, Pet)
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MallowScaffoldShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/today',
          pageBuilder: (context, state) => const NoTransitionPage(child: TodayScreen()),
        ),
        GoRoute(
          path: '/workout',
          pageBuilder: (context, state) => const NoTransitionPage(child: WorkoutScreen()),
        ),
        GoRoute(
          path: '/coach',
          pageBuilder: (context, state) => const NoTransitionPage(child: CoachScreen()),
        ),
        GoRoute(
          path: '/body',
          pageBuilder: (context, state) => const NoTransitionPage(child: BodyScreen()),
        ),
        GoRoute(
          path: '/pet',
          pageBuilder: (context, state) => const NoTransitionPage(child: PetScreen()),
        ),
      ],
    ),
  ],
  );
}

class MallowScaffoldShell extends StatelessWidget {
  final Widget child;

  const MallowScaffoldShell({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/today')) return 0;
    if (location.startsWith('/workout')) return 1;
    if (location.startsWith('/coach')) return 2;
    if (location.startsWith('/body')) return 3;
    if (location.startsWith('/pet')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/today');
        break;
      case 1:
        context.go('/workout');
        break;
      case 2:
        context.go('/coach');
        break;
      case 3:
        context.go('/body');
        break;
      case 4:
        context.go('/pet');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);
    final isCoach = selectedIndex == 2;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isCoach ? MallowColors.darkForestGreen : MallowColors.creamBg,
          border: Border(
            top: BorderSide(
              color: isCoach ? Colors.white12 : const Color(0xFFE8DFCE),
              width: 1.0,
            ),
          ),
        ),
        padding: EdgeInsets.fromLTRB(16, 8, 16, 8 + MediaQuery.of(context).padding.bottom),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context, 0, Icons.donut_large_rounded, 'Today', selectedIndex == 0, isCoach),
            _buildNavItem(context, 1, Icons.fitness_center_rounded, 'Workout', selectedIndex == 1, isCoach),
            _buildNavItem(context, 2, Icons.emoji_events_rounded, 'Coach', selectedIndex == 2, isCoach),
            _buildNavItem(context, 3, Icons.monitor_weight_outlined, 'Body', selectedIndex == 3, isCoach),
            _buildPetNavItem(context, 4, selectedIndex == 4, isCoach),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label, bool isSelected, bool isCoach) {
    final activeColor = MallowColors.hotPink;
    final inactiveColor = isCoach ? Colors.white60 : MallowColors.textSubtle;

    return GestureDetector(
      onTap: () => _onItemTapped(index, context),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: isSelected ? activeColor : inactiveColor),
          const SizedBox(height: 3),
          Text(
            label,
            style: MallowTypography.bodySmall(
              color: isSelected ? (isCoach ? Colors.white : MallowColors.charcoal) : inactiveColor,
              weight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: isSelected ? activeColor : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetNavItem(BuildContext context, int index, bool isSelected, bool isCoach) {
    return GestureDetector(
      onTap: () => _onItemTapped(index, context),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 24,
            decoration: BoxDecoration(
              color: MallowColors.hotPink,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDot(),
                const SizedBox(width: 4),
                _buildDot(),
              ],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Pet',
            style: MallowTypography.bodySmall(
              color: isSelected ? (isCoach ? Colors.white : MallowColors.charcoal) : (isCoach ? Colors.white60 : MallowColors.textSubtle),
              weight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: isSelected ? MallowColors.hotPink : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      width: 4,
      height: 4,
      decoration: const BoxDecoration(
        color: MallowColors.charcoal,
        shape: BoxShape.circle,
      ),
    );
  }
}
