import 'package:flutter/material.dart';

class AppColors {
  static const bg         = Color(0xFF0f0f13);
  static const surface    = Color(0xFF1a1a24);
  static const surface2   = Color(0xFF22222f);
  static const surface3   = Color(0xFF2a2a3a);
  static const border     = Color(0xFF333348);
  static const textPrimary   = Color(0xFFe8e8f0);
  static const textMuted     = Color(0xFF888899);
  static const accent        = Color(0xFF7c6af7);
  static const accentLight   = Color(0xFFa78bfa);
  static const gold          = Color(0xFFf0a832);

  static const study  = Color(0xFF818cf8);
  static const health = Color(0xFF4ade80);
  static const work   = Color(0xFFfb923c);
  static const habit  = Color(0xFFe879f9);
  static const red = Color(0xFFf87171);
}

class AppText {
  static const title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static const body = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
  );
  static const muted = TextStyle(
    fontSize: 13,
    color: AppColors.textMuted,
  );
  static const label = TextStyle(
    fontSize: 11,
    letterSpacing: 0.5,
    color: AppColors.textMuted,
  );
}