import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

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
      foregroundColor: textColor ?? Colors.white,
      elevation: elevation,
    );

    return icon != null
        ? ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(text),
            style: buttonStyle,
          )
        : ElevatedButton(
            onPressed: onPressed,
            style: buttonStyle,
            child: Text(text),
          );
  }

  Widget _buildOutlinedButton(BuildContext context) {
    return icon != null
        ? OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(text),
          )
        : OutlinedButton(onPressed: onPressed, child: Text(text));
  }

  Widget _buildActionButton(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color:
              backgroundColor ??
              (Theme.of(context).brightness == Brightness.dark
                  ? AppColors.primaryDark
                  : AppColors.primary),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: textColor ?? Colors.white, size: 28),
                const SizedBox(height: 8),
              ],
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor ?? Colors.white,
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
