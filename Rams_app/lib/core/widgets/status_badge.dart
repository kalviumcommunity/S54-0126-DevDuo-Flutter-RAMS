import 'package:flutter/material.dart';

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
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    this.borderRadius = 20,
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
      BadgeStatus.success => (Colors.green, Colors.green.shade50),
      BadgeStatus.warning => (Colors.orange, Colors.orange.shade50),
      BadgeStatus.error => (Colors.red, Colors.red.shade50),
      BadgeStatus.info => (Colors.blue, Colors.blue.shade50),
      BadgeStatus.neutral => (Colors.grey, Colors.grey.shade50),
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
