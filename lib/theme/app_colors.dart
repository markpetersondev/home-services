import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0D1117);
  static const Color card = Color(0xFF161B22);
  static const Color primary = Color(0xFF1A3A6B);
  static const Color border = Color(0xFF30363D);

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF8B949E);

  // Solid backgrounds that keep white text readable
  static const Color success = Color(0xFF238636);
  static const Color error = Color(0xFFB00020);

  // Status label colours
  static const Color statusInProgress = Color(0xFF58A6FF);
  static const Color statusPending = Color(0xFFE3B341);
  static const Color statusCompleted = Color(0xFF3FB950);
  static const Color statusAccepted = Color(0xFF2EA99B);
  static const Color statusCancelled = Color(0xFFF85149);

  // Status background tints
  static const Color statusInProgressBg = Color(0xFF0C2340);
  static const Color statusPendingBg = Color(0xFF2D1F00);
  static const Color statusCompletedBg = Color(0xFF0D2E18);
  static const Color statusAcceptedBg = Color(0xFF0A2825);
  static const Color statusCancelledBg = Color(0xFF3A1214);
}
