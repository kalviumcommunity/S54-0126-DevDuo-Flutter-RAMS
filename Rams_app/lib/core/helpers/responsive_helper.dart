import 'package:flutter/widgets.dart';
import '../constants/breakpoints.dart';

/// Helper utilities for responsive layouts.
///
/// Provides consistent `isMobile`, `isTablet`, and `isDesktop` checks
/// based on the shared `Breakpoints` constants.
class ResponsiveHelper {
  final double width;

  /// Create a helper using the [BuildContext]. Uses MediaQuery to read
  /// the current screen width.
  ResponsiveHelper(BuildContext context)
    : width = MediaQuery.of(context).size.width;

  /// Create a helper from an explicit width (useful inside LayoutBuilder).
  ResponsiveHelper.fromWidth(this.width);

  /// True when the viewport is less than the tablet breakpoint.
  bool get isMobile => width < Breakpoints.tablet;

  /// True when the viewport is between tablet (inclusive) and desktop (exclusive).
  bool get isTablet =>
      width >= Breakpoints.tablet && width < Breakpoints.desktop;

  /// True when the viewport is equal to or wider than the desktop breakpoint.
  bool get isDesktop => width >= Breakpoints.desktop;
}
