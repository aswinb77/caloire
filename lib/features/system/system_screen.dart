import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/mallow_theme.dart';
import '../../core/theme/mallow_toast.dart';

class SystemScreen extends StatefulWidget {
  final int initialTab;

  const SystemScreen({super.key, this.initialTab = 0});

  @override
  State<SystemScreen> createState() => _SystemScreenState();
}

class _SystemScreenState extends State<SystemScreen> {
  late int _selectedTab;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MallowColors.creamBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            children: [
              // Top 4 Pill Buttons matching Screenshot 4: [404] [Offline] [Error] [Recovery]
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTabPill(0, '404'),
                  _buildTabPill(1, 'Offline'),
                  _buildTabPill(2, 'Error'),
                  _buildTabPill(3, 'Recovery'),
                ],
              ),
              const Spacer(flex: 2),

              // Animated Pink Dome Character in center matching Screenshot 4
              _buildPinkDomeCharacter(),
              const SizedBox(height: 36),

              // Headline & Description for the active tab
              _buildStateContent(),
              const Spacer(flex: 3),

              // Action Buttons matching Screenshot 4
              _buildActionButtons(context),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabPill(int index, String label) {
    final isSelected = _selectedTab == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? MallowColors.charcoal : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: MallowColors.charcoal,
            width: 1.8,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: MallowTypography.buttonText(
              color: isSelected ? Colors.white : MallowColors.charcoal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinkDomeCharacter() {
    return SizedBox(
      width: 170,
      height: 110,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Pink half dome
          Container(
            width: 170,
            height: 110,
            decoration: const BoxDecoration(
              color: MallowColors.hotPink,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(100),
                topRight: Radius.circular(100),
              ),
            ),
          ),
          // Two big eyes looking up-right
          Positioned(
            bottom: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildEye(),
                const SizedBox(width: 12),
                _buildEye(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEye() {
    return Container(
      width: 26,
      height: 26,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Align(
        alignment: const Alignment(0.4, -0.3),
        child: Container(
          width: 13,
          height: 13,
          decoration: const BoxDecoration(
            color: MallowColors.charcoal,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildStateContent() {
    String headline;
    String description;

    switch (_selectedTab) {
      case 1: // Offline
        headline = "You're offline.\nLogging still works.";
        description = 'Mallow is offline-first. Your meals, workouts, and body metrics are stored safely right on your device.';
        break;
      case 2: // Error
        headline = 'Something tripped.';
        description = 'An unexpected error occurred while processing that request. Your stored data is completely safe.';
        break;
      case 3: // Recovery
        headline = "Let's fix this.\nRestore your backup?";
        description = 'You can restore your latest database snapshot or recalibrate your daily goals to start fresh.';
        break;
      case 0: // 404
      default:
        headline = 'Wrong turn.';
        description = "That screen doesn't exist. Let's head back to Today.";
        break;
    }

    return Column(
      children: [
        Text(
          headline,
          textAlign: TextAlign.center,
          style: MallowTypography.headlineLarge(fontSize: 34),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: MallowTypography.bodyLarge(
              color: MallowColors.charcoal,
              weight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    String primaryLabel;
    String secondaryLabel;
    VoidCallback onPrimary;
    VoidCallback onSecondary;

    switch (_selectedTab) {
      case 1: // Offline
        primaryLabel = 'Keep logging';
        secondaryLabel = 'Retry connection';
        onPrimary = () => context.go('/today');
        onSecondary = () => MallowToast.show(context, 'Checking connection...');
        break;
      case 2: // Error
        primaryLabel = 'Try again';
        secondaryLabel = 'Copy details';
        onPrimary = () => context.go('/today');
        onSecondary = () => MallowToast.show(context, 'Diagnostic report copied to clipboard');
        break;
      case 3: // Recovery
        primaryLabel = 'Restore backup';
        secondaryLabel = 'Start fresh';
        onPrimary = () {
          MallowToast.show(context, 'Backup restored successfully');
          context.go('/today');
        };
        onSecondary = () => context.go('/onboarding');
        break;
      case 0: // 404
      default:
        primaryLabel = 'Back to Today';
        secondaryLabel = 'Report a problem';
        onPrimary = () => context.go('/today');
        onSecondary = () => MallowToast.show(context, 'Report logged. Thank you!');
        break;
    }

    return Column(
      children: [
        // Primary Black Pill Button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: onPrimary,
            style: ElevatedButton.styleFrom(
              backgroundColor: MallowColors.charcoal,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: Text(
              primaryLabel,
              style: MallowTypography.buttonText(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Secondary Outlined Pill Button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton(
            onPressed: onSecondary,
            style: OutlinedButton.styleFrom(
              foregroundColor: MallowColors.charcoal,
              side: const BorderSide(color: MallowColors.charcoal, width: 2.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: Text(
              secondaryLabel,
              style: MallowTypography.buttonText(color: MallowColors.charcoal),
            ),
          ),
        ),
      ],
    );
  }
}
