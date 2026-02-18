import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String? value;
  final Widget? valueWidget;
  final IconData? icon;
  final Color? iconColor;
  final double? fontSize;
  final bool isCompact;

  const StatCard({
    super.key,
    required this.title,
    this.value,
    this.valueWidget,
    this.icon,
    this.iconColor,
    this.fontSize = 28,
    this.isCompact = false,
  }) : assert(
         value != null || valueWidget != null,
         'Either value or valueWidget must be provided',
       );

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: isCompact
            ? BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: Theme.of(context).dividerColor),
              )
            : null,
        child: isCompact
            ? Row(
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon!,
                      color: iconColor ?? AppColors.primary,
                      size: 28,
                    ),
                    const SizedBox(width: AppSpacing.md),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.grey,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        valueWidget ??
                            Text(
                              value ?? '',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color,
                              ),
                            ),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 6),
                  valueWidget ??
                      Text(
                        value ?? '',
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.primaryDark
                              : AppColors.primary,
                        ),
                      ),
                ],
              ),
      ),
    );
  }
}
