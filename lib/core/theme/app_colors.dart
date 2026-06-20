import 'package:flutter/material.dart';

abstract final class AppColors {
  // --- Primary (deep indigo) ---
  static const primary = Color(0xFF17137F);
  static const primaryContainer = Color(0xFF303094);
  static const onPrimary = Color(0xFFFFFFFF);
  static const onPrimaryContainer = Color(0xFF9FA1FF);
  static const inversePrimary = Color(0xFFC1C1FF);

  // --- Secondary (gold) ---
  static const secondary = Color(0xFF755A1A);
  static const secondaryContainer = Color(0xFFFED88B);
  static const onSecondary = Color(0xFFFFFFFF);
  static const onSecondaryContainer = Color(0xFF785D1D);
  static const gold = Color(0xFFE3BF75);
  static const goldDark = Color(0xFFC9A65E);

  // --- Surface / background ---
  static const background = Color(0xFFFCF8FF);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceDim = Color(0xFFDCD9E2);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF6F2FB);
  static const surfaceContainer = Color(0xFFF0ECF6);
  static const surfaceContainerHigh = Color(0xFFEAE7F0);
  static const surfaceContainerHighest = Color(0xFFE4E1EA);

  // --- Text ---
  static const onSurface = Color(0xFF1B1B21);
  static const onSurfaceVariant = Color(0xFF464652);
  static const inverseSurface = Color(0xFF303037);
  static const inverseOnSurface = Color(0xFFF3EFF8);

  // --- Outline ---
  static const outline = Color(0xFF777683);
  static const outlineVariant = Color(0xFFC7C5D4);

  // --- Error ---
  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  // --- Content-type strip colors ---
  static const typeNote = Color(0xFF303094);
  static const typeFile = Color(0xFF5C5CAE);
  static const typeLink = Color(0xFF7B7BC4);
  static const typeVoice = Color(0xFFE3BF75);

  // --- Lock screen ---
  static const lockBackground = Color(0xFF2B27A0);
}
