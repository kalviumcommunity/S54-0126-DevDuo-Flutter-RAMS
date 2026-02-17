import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class LoadingIndicator extends StatelessWidget {
  final double padding;
  final double size;
  final Color? color;

  const LoadingIndicator({
    super.key,
    this.padding = 24.0,
    this.size = 36.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.primaryLight
        : AppColors.primary;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color ?? themeColor),
            strokeWidth: 3.0,
          ),
        ),
      ),
    );
  }
}

// Add primaryLight to AppColors if it's missing, or use primaryDark
// Let me check AppColors again.
