import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';

enum ButtonType { elevated, outlined, action }

class CustomButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool fullWidth;
  final Color? backgroundColor;
  final Color? textColor;
  final double? elevation;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.type = ButtonType.elevated,
    this.fullWidth = false,
    this.backgroundColor,
    this.textColor,
    this.elevation,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final Widget button = switch (type) {
      ButtonType.elevated => _buildElevatedButton(context),
      ButtonType.outlined => _buildOutlinedButton(context),
      ButtonType.action => _buildActionButton(context),
    };

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }

  Widget _buildElevatedButton(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor:
          backgroundColor ??
          (Theme.of(context).brightness == Brightness.dark
              ? AppColors.primaryDark
              : AppColors.primary),
      foregroundColor: textColor ?? AppColors.white,
      elevation: elevation,
    );

    final Widget child = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
            ),
          )
        : icon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon),
              const SizedBox(width: AppSpacing.sm),
              Text(text),
            ],
          )
        : Text(text);

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle,
      child: child,
    );
  }

  Widget _buildOutlinedButton(BuildContext context) {
    final buttonStyle = OutlinedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor:
          textColor ??
          (Theme.of(context).brightness == Brightness.dark
              ? AppColors.white
              : AppColors.primary),
      side: BorderSide(
        color:
            textColor ??
            (Theme.of(context).brightness == Brightness.dark
                ? AppColors.white
                : AppColors.primary),
      ),
    );

    final Widget child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                textColor ??
                    (Theme.of(context).brightness == Brightness.dark
                        ? AppColors.white
                        : AppColors.primary),
              ),
            ),
          )
        : icon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon),
              const SizedBox(width: AppSpacing.sm),
              Text(text),
            ],
          )
        : Text(text);

    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle,
      child: child,
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onPressed,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        decoration: BoxDecoration(
          color: isLoading
              ? Colors.grey.withValues(alpha: 0.3)
              : backgroundColor ??
                    (Theme.of(context).brightness == Brightness.dark
                        ? AppColors.primaryDark
                        : AppColors.primary),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      textColor ?? AppColors.white,
                    ),
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: textColor ?? AppColors.white, size: 28),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    Text(
                      text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor ?? AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
