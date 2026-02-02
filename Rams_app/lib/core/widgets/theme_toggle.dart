import 'package:flutter/material.dart';
import '../theme/theme_controller.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the ThemeController via inherited widget or directly (we'll use a simple lookup)
    final controller = ThemeControllerProvider.of(context);
    final isDark = controller.isDark;

    return IconButton(
      icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode, size: 22),
      onPressed: () => controller.toggle(),
      tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
    );
  }
}

/// A small InheritedNotifier provider for easy access to the singleton controller.
class ThemeControllerProvider extends InheritedNotifier<ThemeController> {
  const ThemeControllerProvider({
    required ThemeController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static ThemeController of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<ThemeControllerProvider>();
    assert(provider != null, 'No ThemeControllerProvider found in context');
    return provider!.notifier!;
  }
}
