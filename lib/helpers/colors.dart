import 'package:flutter/material.dart';

/// Global navigation index (used by HomeScreen bottom nav)
int bottomIndex = 0;

// ── Brand palette ─────────────────────────────────────────────────────────────
/// Royal indigo – primary brand colour
const Color kPrimary  = Color(0xFF4C6EF5);
/// Violet – gradient end, secondary surfaces
const Color kPrimary2 = Color(0xFF845EF7);
/// Teal – success, income, positive amounts
const Color kSuccess  = Color(0xFF20C997);
/// Amber – call-to-action buttons, add-card button
const Color kGold     = Color(0xFFFCC419);
/// Red – errors, expenses, danger
const Color kDanger   = Color(0xFFFF6B6B);
/// Cyan – informational, exchange rate, charts
const Color kCyan     = Color(0xFF4DABF7);

// ── Dark theme neutrals ────────────────────────────────────────────────────────
const Color kDarkBg    = Color(0xFF0F1117);
const Color kDarkCard  = Color(0xFF181A2A);
const Color kDarkCard2 = Color(0xFF20223A);
const Color kDarkMuted = Color(0xFFA0A8C0);

// ── Light theme neutrals ──────────────────────────────────────────────────────
const Color kLightBg      = Color(0xFFF0F4FF);
const Color kLightCard    = Color(0xFFFFFFFF);
const Color kLightCard2   = Color(0xFFEEF2FF);
const Color kLightMuted   = Color(0xFF718096);

// ── Gradient helpers ─────────────────────────────────────────────────────────
const LinearGradient kGradientPrimary = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [kPrimary, kPrimary2],
);

const LinearGradient kGradientSuccess = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF11998E), Color(0xFF20C997)],
);

// ── Backward-compat aliases ───────────────────────────────────────────────────
const kprimarycolor   = kPrimary;
const ksecondarycolor = kDarkCard;
