import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CodyColors {
  // Brand Gradients Extracted from Logo
  static const primaryPurple = Color(0xFF6E3CBC); // Slightly lighter purple for better readability
  static const primaryPink = Color(0xFFD84CAD); // Slightly more vibrant pink
  static const backgroundLight = Color(0xFFFDFDFF);
  static const backgroundDark = Color(0xFF0F0F12);
}

class CodyTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: CodyColors.backgroundLight,
      colorScheme: ColorScheme.light(
        primary: CodyColors.primaryPurple,
        primaryContainer: CodyColors.primaryPurple.withValues(alpha: 0.1),
        onPrimary: Colors.white,
        secondary: CodyColors.primaryPink,
        secondaryContainer: CodyColors.primaryPink.withValues(alpha: 0.1),
        onSecondary: Colors.white,
        tertiary: CodyColors.primaryPink,
        onTertiary: Colors.white,
        surface: Colors.white,
        onSurface: const Color(0xFF19191D), 
        onSurfaceVariant: const Color(0xFF5D5D66), // Darker for better contrast
        outline: const Color(0xFF747480), // Much darker for secondary text
        outlineVariant: const Color(0xFFD1D1D8),
        surfaceContainerLow: const Color(0xFFF3F3F7),
        surfaceContainer: const Color(0xFFEDEEF2),
        surfaceContainerHigh: const Color(0xFFE7E8EC),
        surfaceContainerHighest: const Color(0xFFE1E2E7),
      ),
      textTheme: _buildTextTheme(Brightness.light),
      appBarTheme: AppBarTheme(
        backgroundColor: CodyColors.backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          color: CodyColors.primaryPurple,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
        iconTheme: const IconThemeData(color: CodyColors.primaryPurple),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE1E1E6)),
        ),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: CodyColors.backgroundDark,
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFFCBACFF), // Pastel purple for dark mode
        primaryContainer: CodyColors.primaryPurple,
        onPrimary: const Color(0xFF3B008E),
        secondary: const Color(0xFFFFADEB),
        secondaryContainer: CodyColors.primaryPink,
        onSecondary: const Color(0xFF5A0051),
        tertiary: const Color(0xFFFFADEB),
        onTertiary: const Color(0xFF5A0051),
        surface: const Color(0xFF1A1A1E),
        onSurface: const Color(0xFFE4E1E6),
        onSurfaceVariant: const Color(0xFFB1ABB9), // Slightly brighter
        outline: const Color(0xFF938F99),
        outlineVariant: const Color(0xFF48454E),
        surfaceContainerLow: const Color(0xFF1E1E22),
        surfaceContainer: const Color(0xFF242429),
        surfaceContainerHigh: const Color(0xFF2A2A2F),
        surfaceContainerHighest: const Color(0xFF313136),
      ),
      textTheme: _buildTextTheme(Brightness.dark),
      appBarTheme: AppBarTheme(
        backgroundColor: CodyColors.backgroundDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          color: const Color(0xFFCBACFF),
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
        iconTheme: const IconThemeData(color: Color(0xFFCBACFF)),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1A1A1E),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF2A2A2F)),
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(Brightness brightness) {
    final onSurface = brightness == Brightness.dark ? const Color(0xFFE4E1E6) : const Color(0xFF19191D);
    final onSurfaceVariant = brightness == Brightness.dark ? const Color(0xFFC9C5D0) : const Color(0xFF474752);

    return TextTheme(
      displayLarge: GoogleFonts.spaceGrotesk(color: onSurface, fontWeight: FontWeight.w900),
      displayMedium: GoogleFonts.spaceGrotesk(color: onSurface, fontWeight: FontWeight.w900),
      displaySmall: GoogleFonts.spaceGrotesk(color: onSurface, fontWeight: FontWeight.w700),
      headlineLarge: GoogleFonts.spaceGrotesk(color: onSurface, fontWeight: FontWeight.w700),
      headlineMedium: GoogleFonts.spaceGrotesk(color: onSurface, fontWeight: FontWeight.w700),
      headlineSmall: GoogleFonts.spaceGrotesk(color: onSurface, fontWeight: FontWeight.w700),
      bodyLarge: GoogleFonts.inter(color: onSurface),
      bodyMedium: GoogleFonts.inter(color: onSurface),
      bodySmall: GoogleFonts.inter(color: onSurfaceVariant, fontSize: 12),
      labelLarge: GoogleFonts.inter(color: onSurface, fontWeight: FontWeight.w600),
      labelMedium: GoogleFonts.inter(color: onSurfaceVariant, fontWeight: FontWeight.w500),
      labelSmall: GoogleFonts.inter(color: onSurfaceVariant, fontSize: 11, letterSpacing: 0.5),
    );
  }
}
