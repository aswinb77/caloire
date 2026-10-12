import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'mallow_theme.dart';

/// The signature pink square avatar with expressive eyes
class MallowAvatar extends StatefulWidget {
  final double size;
  final bool animate;
  final VoidCallback? onTap;

  const MallowAvatar({
    super.key,
    this.size = 36,
    this.animate = true,
    this.onTap,
  });

  @override
  State<MallowAvatar> createState() => _MallowAvatarState();
}

class _MallowAvatarState extends State<MallowAvatar> with SingleTickerProviderStateMixin {
  late AnimationController _blinkController;
  Timer? _blinkTimer;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    if (widget.animate && !const bool.fromEnvironment('flutter.test')) {
      _scheduleNextBlink();
    }
  }

  void _scheduleNextBlink() {
    _blinkTimer?.cancel();
    _blinkTimer = Timer(Duration(milliseconds: 2500 + math.Random().nextInt(2000)), () async {
      if (mounted) {
        await _blinkController.forward();
        if (mounted) {
          await _blinkController.reverse();
          _scheduleNextBlink();
        }
      }
    });
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _blinkController,
        builder: (context, child) {
          final blinkScaleY = 1.0 - (_blinkController.value * 0.85);
          return Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: MallowColors.hotPink,
              borderRadius: BorderRadius.circular(widget.size * 0.32),
            ),
            child: Center(
              child: SizedBox(
                width: widget.size * 0.65,
                height: widget.size * 0.45,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildEye(blinkScaleY),
                    _buildEye(blinkScaleY),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEye(double scaleY) {
    final eyeSize = widget.size * 0.28;
    return Transform.scale(
      scaleY: scaleY,
      child: Container(
        width: eyeSize,
        height: eyeSize,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Container(
            width: eyeSize * 0.52,
            height: eyeSize * 0.52,
            decoration: const BoxDecoration(
              color: MallowColors.charcoal,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

/// The signature custom toggle switch seen in the reference screenshot
class MallowSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const MallowSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        decoration: BoxDecoration(
          color: value ? MallowColors.hotPink : const Color(0xFFE5DDD0),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: MallowColors.charcoal,
            width: 2.2,
          ),
        ),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: MallowColors.charcoal,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

/// Circular back or icon button
class MallowCircleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color backgroundColor;
  final double size;

  const MallowCircleButton({
    super.key,
    required this.child,
    required this.onTap,
    this.backgroundColor = MallowColors.cardCream,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Center(child: child),
      ),
    );
  }
}

/// Hot pink pill button
class MallowPillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isPrimary;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double? width;
  final Widget? icon;

  const MallowPillButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isPrimary = true,
    this.backgroundColor,
    this.textColor,
    this.height = 48,
    this.width,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bool disabled = onTap == null;
    final bg = disabled
        ? MallowColors.hotPinkDisabled
        : (backgroundColor ?? (isPrimary ? MallowColors.hotPink : MallowColors.charcoal));
    final txt = textColor ?? (isPrimary ? MallowColors.charcoal : Colors.white);

    return SizedBox(
      height: height,
      width: width,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(height / 2),
          child: Ink(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(height / 2),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: MallowTypography.buttonText(color: txt),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
