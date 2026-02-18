import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';

enum BadgeStatus { success, warning, error, info, neutral }

class StatusBadge extends StatelessWidget {
  final String text;
  final BadgeStatus status;
  final Color? backgroundColor;
  final Color? textColor;
  final double fontSize;
  final EdgeInsets padding;
  final double borderRadius;

  const StatusBadge({
    super.key,
    required this.text,
    required this.status,
    this.backgroundColor,
    this.textColor,
    this.fontSize = 12,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.xs,
    ),
    this.borderRadius = AppRadius.pill,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getStatusColors(context);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.$1.withOpacity(0.12),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor ?? colors.$1,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (Color, Color) _getStatusColors(BuildContext context) {
    return switch (status) {
      BadgeStatus.success => (
        AppColors.green,
        AppColors.green.withOpacity(0.1),
      ),
      BadgeStatus.warning => (
        AppColors.orange,
        AppColors.orange.withOpacity(0.1),
      ),
      BadgeStatus.error => (AppColors.red, AppColors.red.withOpacity(0.1)),
      BadgeStatus.info => (AppColors.blue, AppColors.blue.withOpacity(0.1)),
      BadgeStatus.neutral => (AppColors.grey, AppColors.grey.withOpacity(0.1)),
    };
  }
}

// Convenience constructors for common use cases
class PassFailBadge extends StatusBadge {
  const PassFailBadge({
    super.key,
    required bool isPass,
    String? passText,
    String? failText,
  }) : super(
         text: isPass ? (passText ?? 'Pass') : (failText ?? 'Fail'),
         status: isPass ? BadgeStatus.success : BadgeStatus.error,
       );
}

class AttendanceBadge extends StatusBadge {
  const AttendanceBadge({
    super.key,
    required bool isPresent,
    String? presentText,
    String? absentText,
  }) : super(
         text: isPresent
             ? (presentText ?? 'Present')
             : (absentText ?? 'Absent'),
         status: isPresent ? BadgeStatus.success : BadgeStatus.error,
       );
}
