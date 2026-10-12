import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MallowColors {
  // Backgrounds
  static const Color creamBg = Color(0xFFFAF6EE);
  static const Color cardCream = Color(0xFFECE5D8);
  static const Color cardCreamLight = Color(0xFFF2ECE1);
  static const Color cardDarkCream = Color(0xFFE2DAD0);
  
  // Signature Accents
  static const Color hotPink = Color(0xFFFF3E8A);
  static const Color hotPinkLight = Color(0xFFFFE0ED);
  static const Color hotPinkDisabled = Color(0xFFF5B6CE);
  
  // Secondary Colors
  static const Color oliveGreen = Color(0xFF5E7C38);
  static const Color oliveGreenLight = Color(0xFFDEE8D3);
  static const Color slateBlue = Color(0xFF7A9EB8);
  static const Color slateBlueLight = Color(0xFFD6E4EE);
  static const Color darkForestGreen = Color(0xFF1B3E2B);
  
  // Neutrals
  static const Color charcoal = Color(0xFF1A1A1A);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textSubtle = Color(0xFF706E6B);
  static const Color borderSubtle = Color(0xFFDDD5C7);
  static const Color white = Colors.white;
}

class MallowTypography {
  static TextStyle headlineLarge({Color color = MallowColors.textDark, double fontSize = 34}) {
    return GoogleFonts.bricolageGrotesque(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.8,
      color: color,
      height: 1.1,
    );
  }

  static TextStyle headlineMedium({Color color = MallowColors.textDark, double fontSize = 26}) {
    return GoogleFonts.bricolageGrotesque(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.6,
      color: color,
      height: 1.2,
    );
  }

  static TextStyle headlineSmall({Color color = MallowColors.textDark, double fontSize = 20}) {
    return GoogleFonts.bricolageGrotesque(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
      color: color,
    );
  }

  static TextStyle bigNumber({Color color = MallowColors.textDark, double fontSize = 52}) {
    return GoogleFonts.bricolageGrotesque(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      letterSpacing: -1.5,
      color: color,
      height: 1.0,
    );
  }

  static TextStyle bodyLarge({Color color = MallowColors.textDark, FontWeight weight = FontWeight.w500}) {
    return GoogleFonts.dmSans(
      fontSize: 16,
      fontWeight: weight,
      color: color,
    );
  }

  static TextStyle bodyMedium({Color color = MallowColors.textDark, FontWeight weight = FontWeight.w400}) {
    return GoogleFonts.dmSans(
      fontSize: 14,
      fontWeight: weight,
      color: color,
    );
  }

  static TextStyle bodySmall({Color color = MallowColors.textSubtle, FontWeight weight = FontWeight.w500}) {
    return GoogleFonts.dmSans(
      fontSize: 12,
      fontWeight: weight,
      color: color,
    );
  }

  static TextStyle buttonText({Color color = MallowColors.textDark}) {
    return GoogleFonts.dmSans(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: color,
    );
  }
}
