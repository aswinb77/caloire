import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'mallow_theme.dart';

enum MallowMood { happy, hungry, sleepy, chill }

class MallowCharacter extends StatefulWidget {
  final double width;
  final double height;
  final MallowMood mood;
  final bool animateBob;

  const MallowCharacter({
    super.key,
    this.width = 160,
    this.height = 140,
    this.mood = MallowMood.happy,
    this.animateBob = true,
  });

  @override
  State<MallowCharacter> createState() => _MallowCharacterState();
}

class _MallowCharacterState extends State<MallowCharacter> with SingleTickerProviderStateMixin {
  late AnimationController _bobController;
  late Animation<double> _bobAnimation;

  @override
  void initState() {
    super.initState();
    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _bobAnimation = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(
        parent: _bobController,
        curve: Curves.easeInOut,
      ),
    );
    if (widget.animateBob) {
      _bobController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _bobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bobAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, widget.animateBob ? _bobAnimation.value : 0),
          child: child,
        );
      },
      child: CustomPaint(
        size: Size(widget.width, widget.height),
        painter: _MallowPainter(mood: widget.mood),
      ),
    );
  }
}

class _MallowPainter extends CustomPainter {
  final MallowMood mood;

  _MallowPainter({required this.mood});

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()
      ..color = MallowColors.hotPink
      ..style = PaintingStyle.fill;

    // Pink squircle body
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(size.width * 0.28),
    );
    canvas.drawRRect(rect, bodyPaint);

    final eyeSpacing = size.width * 0.32;
    final eyeRadius = size.width * 0.085;
    final pupilRadius = eyeRadius * 0.55;
    final eyeY = size.height * 0.40;

    final leftEyeCenter = Offset(size.width / 2 - eyeSpacing / 2, eyeY);
    final rightEyeCenter = Offset(size.width / 2 + eyeSpacing / 2, eyeY);

    if (mood == MallowMood.sleepy) {
      // Sleepy: closed eye arcs
      final sleepPaint = Paint()
        ..color = MallowColors.charcoal
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: leftEyeCenter, radius: eyeRadius),
        math.pi * 0.1,
        math.pi * 0.8,
        false,
        sleepPaint,
      );
      canvas.drawArc(
        Rect.fromCircle(center: rightEyeCenter, radius: eyeRadius),
        math.pi * 0.1,
        math.pi * 0.8,
        false,
        sleepPaint,
      );

      // z z indicators
      final textPainter = TextPainter(
        text: const TextSpan(
          text: 'z z',
          style: TextStyle(
            color: MallowColors.charcoal,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(size.width * 0.80, size.height * 0.10));
    } else {
      // Normal / Happy / Hungry / Chill eyes
      final whitePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      final pupilPaint = Paint()
        ..color = MallowColors.charcoal
        ..style = PaintingStyle.fill;

      canvas.drawCircle(leftEyeCenter, eyeRadius, whitePaint);
      canvas.drawCircle(rightEyeCenter, eyeRadius, whitePaint);

      // Pupil offset depending on mood
      Offset pupilOffset = Offset.zero;
      if (mood == MallowMood.happy) {
        pupilOffset = const Offset(1, -1);
      } else if (mood == MallowMood.hungry) {
        pupilOffset = const Offset(0, 2);
      }

      canvas.drawCircle(leftEyeCenter + pupilOffset, pupilRadius, pupilPaint);
      canvas.drawCircle(rightEyeCenter + pupilOffset, pupilRadius, pupilPaint);
    }

    // Mouth
    final mouthPaint = Paint()
      ..color = MallowColors.charcoal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final mouthY = size.height * 0.68;

    switch (mood) {
      case MallowMood.happy:
        // Smile curve
        final path = Path();
        path.moveTo(size.width * 0.42, mouthY);
        path.quadraticBezierTo(
          size.width * 0.50,
          mouthY + 10,
          size.width * 0.58,
          mouthY,
        );
        canvas.drawPath(path, mouthPaint);
        break;

      case MallowMood.hungry:
        // Open oval mouth
        final mouthFill = Paint()
          ..color = MallowColors.charcoal
          ..style = PaintingStyle.fill;
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(size.width * 0.50, mouthY + 2),
            width: 14,
            height: 18,
          ),
          mouthFill,
        );
        break;

      case MallowMood.chill:
      case MallowMood.sleepy:
        // Flat chill line
        canvas.drawLine(
          Offset(size.width * 0.44, mouthY),
          Offset(size.width * 0.56, mouthY),
          mouthPaint,
        );
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _MallowPainter oldDelegate) {
    return oldDelegate.mood != mood;
  }
}

/// The taller companion character (blue-grey dome) on the Coach screen
class MallowCompanion extends StatelessWidget {
  final double width;
  final double height;

  const MallowCompanion({
    super.key,
    this.width = 110,
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _CompanionPainter(),
    );
  }
}

class _CompanionPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()
      ..color = MallowColors.slateBlue
      ..style = PaintingStyle.fill;

    // Tall dome shape
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.45);
    path.quadraticBezierTo(size.width * 0.5, -10, size.width, size.height * 0.45);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, bodyPaint);

    // Eyes looking upward
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final pupilPaint = Paint()
      ..color = MallowColors.charcoal
      ..style = PaintingStyle.fill;

    final eyeY = size.height * 0.38;
    final eyeRadius = size.width * 0.10;
    final pupilRadius = eyeRadius * 0.55;

    final leftEye = Offset(size.width * 0.35, eyeY);
    final rightEye = Offset(size.width * 0.65, eyeY);

    canvas.drawCircle(leftEye, eyeRadius, whitePaint);
    canvas.drawCircle(rightEye, eyeRadius, whitePaint);

    // Pupils looking up
    canvas.drawCircle(leftEye + const Offset(0, -3), pupilRadius, pupilPaint);
    canvas.drawCircle(rightEye + const Offset(0, -3), pupilRadius, pupilPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
