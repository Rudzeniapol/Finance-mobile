import 'package:flutter/material.dart';
import 'package:my_app/helpers/colors.dart';

class AppThemes {
  // ── Typography (colour-agnostic — colour applied per theme via .apply) ─────

  static const TextTheme _baseTextTheme = TextTheme(
    displayLarge:  TextStyle(fontFamily: 'PoppinsBold',    fontSize: 34, letterSpacing: -0.5),
    displayMedium: TextStyle(fontFamily: 'PoppinsBold',    fontSize: 28),
    displaySmall:  TextStyle(fontFamily: 'PoppinsBold',    fontSize: 24),
    headlineLarge: TextStyle(fontFamily: 'PoppinsMedium',  fontSize: 22),
    headlineMedium:TextStyle(fontFamily: 'PoppinsMedium',  fontSize: 20),
    headlineSmall: TextStyle(fontFamily: 'PoppinsMedium',  fontSize: 18),
    titleLarge:    TextStyle(fontFamily: 'PoppinsMedium',  fontSize: 16),
    titleMedium:   TextStyle(fontFamily: 'PoppinsMedium',  fontSize: 14),
    titleSmall:    TextStyle(fontFamily: 'PoppinsRegular', fontSize: 13),
    bodyLarge:     TextStyle(fontFamily: 'PoppinsRegular', fontSize: 14),
    bodyMedium:    TextStyle(fontFamily: 'PoppinsRegular', fontSize: 13),
    bodySmall:     TextStyle(fontFamily: 'PoppinsLight',   fontSize: 11),
    labelLarge:    TextStyle(fontFamily: 'PoppinsMedium',  fontSize: 13),
    labelMedium:   TextStyle(fontFamily: 'PoppinsRegular', fontSize: 12),
    labelSmall:    TextStyle(fontFamily: 'PoppinsLight',   fontSize: 10),
  );

  // ── Shared component themes ──────────────────────────────────────────────────

  static ElevatedButtonThemeData get _buttonTheme => ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kGold,
      foregroundColor: Colors.black,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(fontFamily: 'PoppinsMedium', fontSize: 16),
    ),
  );

  static CardThemeData get _cardTheme => CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    margin: EdgeInsets.zero,
  );

  // ── Dark theme ───────────────────────────────────────────────────────────────

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: kDarkBg,
    colorScheme: const ColorScheme.dark(
      primary:                  kPrimary,
      secondary:                kSuccess,
      tertiary:                 kGold,
      surface:                  kDarkCard,
      surfaceContainerHighest:  kDarkCard2,
      onPrimary:                Colors.white,
      onSurface:                Colors.white,
      onSurfaceVariant:         kDarkMuted,
      outline:                  Color(0xFF2A2D45),
      error:                    kDanger,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor:          kDarkBg,
      elevation:                0,
      scrolledUnderElevation:   0,
      iconTheme:                IconThemeData(color: Colors.white),
      titleTextStyle:           TextStyle(
        fontFamily: 'PoppinsMedium', fontSize: 18, color: Colors.white,
      ),
    ),
    cardTheme: _cardTheme.copyWith(color: kDarkCard),
    elevatedButtonTheme: _buttonTheme,
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? kPrimary : kDarkMuted),
      trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? kPrimary.withValues(alpha: 0.4)
              : kDarkCard2),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled:     true,
      fillColor:  kDarkCard2,
      counterStyle: const TextStyle(color: kDarkMuted, fontSize: 10),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPrimary, width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kDanger, width: 1)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kDanger, width: 1.5)),
      labelStyle: const TextStyle(color: kDarkMuted, fontFamily: 'PoppinsLight'),
      hintStyle:  const TextStyle(color: Color(0xFF4A5070), fontFamily: 'PoppinsLight'),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFF20223A), thickness: 1),
    listTileTheme: const ListTileThemeData(iconColor: kDarkMuted),
    textTheme: _baseTextTheme.apply(
      bodyColor:    Colors.white,
      displayColor: Colors.white,
    ),
  );

  // ── Light theme ──────────────────────────────────────────────────────────────

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: kLightBg,
    colorScheme: const ColorScheme.light(
      primary:                  kPrimary,
      secondary:                kSuccess,
      tertiary:                 kGold,
      surface:                  kLightCard,
      surfaceContainerHighest:  kLightCard2,
      onPrimary:                Colors.white,
      onSurface:                Color(0xFF1A202C),
      onSurfaceVariant:         kLightMuted,
      outline:                  Color(0xFFE2E8F0),
      error:                    kDanger,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor:          kLightBg,
      elevation:                0,
      scrolledUnderElevation:   0,
      iconTheme:                IconThemeData(color: Color(0xFF1A202C)),
      titleTextStyle:           TextStyle(
        fontFamily: 'PoppinsMedium', fontSize: 18, color: Color(0xFF1A202C),
      ),
    ),
    cardTheme: _cardTheme.copyWith(
      color:       kLightCard,
      shadowColor: kPrimary.withValues(alpha: 0.08),
      elevation:   0,
    ),
    elevatedButtonTheme: _buttonTheme,
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? kPrimary : Colors.white),
      trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? kPrimary.withValues(alpha: 0.4)
              : const Color(0xFFE2E8F0)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled:     true,
      fillColor:  kLightCard2,
      counterStyle: const TextStyle(color: kLightMuted, fontSize: 10),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPrimary, width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kDanger, width: 1)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kDanger, width: 1.5)),
      labelStyle: const TextStyle(color: kLightMuted, fontFamily: 'PoppinsLight'),
      hintStyle:  const TextStyle(color: Color(0xFFA0AEC0), fontFamily: 'PoppinsLight'),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFFE2E8F0), thickness: 1),
    listTileTheme: const ListTileThemeData(iconColor: kLightMuted),
    textTheme: _baseTextTheme.apply(
      bodyColor:    const Color(0xFF1A202C),
      displayColor: const Color(0xFF1A202C),
    ),
  );
}
