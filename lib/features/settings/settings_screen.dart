import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/mallow_theme.dart';
import '../../core/theme/mallow_widgets.dart';
import '../../core/theme/mallow_toast.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _unitsIndex = 0; // 0: Metric, 1: Imperial
  String _selectedLanguage = 'English';

  bool _remindBreakfast = true;
  bool _remindLunch = true;
  bool _remindDinner = false; // off in screenshot!
  bool _remindWeighIn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MallowColors.creamBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const MallowAvatar(size: 38, animate: true),
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
                ],
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Settings',
                style: MallowTypography.headlineLarge(),
              ),
              const SizedBox(height: 24),

              // 1. Units Section
              Text(
                'Units',
                style: MallowTypography.headlineSmall(),
              ),
              const SizedBox(height: 12),
              Container(
                height: 48,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: MallowColors.cardCream,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    _buildUnitsSegment(0, 'Metric'),
                    _buildUnitsSegment(1, 'Imperial'),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // 2. Language Section
              Text(
                'Language',
                style: MallowTypography.headlineSmall(),
              ),
              const SizedBox(height: 12),
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: MallowColors.charcoal, width: 2),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedLanguage,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: MallowColors.charcoal),
                    style: MallowTypography.headlineSmall(color: MallowColors.charcoal),
                    items: const [
                      DropdownMenuItem(value: 'English', child: Text('English')),
                      DropdownMenuItem(value: 'Spanish', child: Text('Español')),
                      DropdownMenuItem(value: 'French', child: Text('Français')),
                      DropdownMenuItem(value: 'German', child: Text('Deutsch')),
                      DropdownMenuItem(value: 'Malayalam', child: Text('മലയാളം')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedLanguage = val);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // 3. Reminders Section
              Text(
                'Reminders',
                style: MallowTypography.headlineSmall(),
              ),
              const SizedBox(height: 12),
              _buildReminderRow(
                title: 'Breakfast, 8:30 am',
                value: _remindBreakfast,
                onChanged: (val) => setState(() => _remindBreakfast = val),
              ),
              const Divider(color: Color(0xFFE8DFCE), height: 24),
              _buildReminderRow(
                title: 'Lunch, 1:00 pm',
                value: _remindLunch,
                onChanged: (val) => setState(() => _remindLunch = val),
              ),
              const Divider(color: Color(0xFFE8DFCE), height: 24),
              _buildReminderRow(
                title: 'Dinner, 7:30 pm',
                value: _remindDinner,
                onChanged: (val) => setState(() => _remindDinner = val),
              ),
              const Divider(color: Color(0xFFE8DFCE), height: 24),
              _buildReminderRow(
                title: 'Monday weigh-in',
                value: _remindWeighIn,
                onChanged: (val) => setState(() => _remindWeighIn = val),
              ),
              const SizedBox(height: 32),

              // 4. Backup Section
              Text(
                'Backup',
                style: MallowTypography.headlineSmall(),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: MallowPillButton(
                      label: 'Export',
                      height: 50,
                      isPrimary: false,
                      backgroundColor: MallowColors.charcoal,
                      textColor: Colors.white,
                      onTap: () {
                        MallowToast.show(context, 'Exported 16 records to backup.json');
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: MallowPillButton(
                      label: 'Restore',
                      height: 50,
                      isPrimary: true,
                      backgroundColor: MallowColors.hotPink,
                      textColor: MallowColors.charcoal,
                      onTap: () {
                        MallowToast.show(context, 'Backup restored successfully!');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 5. System States Test Shortcut & About
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: MallowColors.cardCream,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'System Screens',
                          style: MallowTypography.bodySmall(
                            color: MallowColors.charcoal,
                            weight: FontWeight.w700,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/system'),
                          child: Text(
                            'Preview States →',
                            style: MallowTypography.bodySmall(
                              color: MallowColors.hotPink,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Preview 404, Offline, Error, and Recovery full-screen states.',
                      style: MallowTypography.bodySmall(color: MallowColors.textSubtle),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              MallowPillButton(
                label: 'Setup Profile & Goals (Onboarding)',
                isPrimary: false,
                width: double.infinity,
                height: 48,
                backgroundColor: MallowColors.cardCream,
                textColor: MallowColors.charcoal,
                onTap: () => context.push('/onboarding'),
              ),
              const SizedBox(height: 20),

              Center(
                child: Column(
                  children: [
                    Text(
                      'Mallow v1.0.0',
                      style: MallowTypography.bodySmall(color: MallowColors.textSubtle),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Not medical advice. Consult a healthcare provider.',
                      style: MallowTypography.bodySmall(
                        color: MallowColors.textSubtle.withValues(alpha: 0.7),
                      ),
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

  Widget _buildUnitsSegment(int index, String label) {
    final isSelected = _unitsIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _unitsIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: isSelected ? MallowColors.charcoal : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
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
      ),
    );
  }

  Widget _buildReminderRow({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: MallowTypography.headlineSmall(
            color: MallowColors.charcoal,
          ),
        ),
        MallowSwitch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
