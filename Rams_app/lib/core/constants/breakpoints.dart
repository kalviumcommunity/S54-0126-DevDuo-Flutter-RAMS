/// Responsive breakpoint constants for consistent layout behavior across the app.
///
/// These breakpoints define when the UI should switch between mobile, tablet,
/// and desktop layouts.
class Breakpoints {
  // Private constructor to prevent instantiation
  Breakpoints._();

  /// Tablet breakpoint (768px and above)
  ///
  /// Use this for layouts that should adapt for tablet-sized screens.
  /// Example: `size.width >= Breakpoints.tablet`
  static const double tablet = 768.0;

  /// Desktop breakpoint (900px and above)
  ///
  /// Use this for layouts that should adapt for desktop-sized screens.
  /// Example: `constraints.maxWidth >= Breakpoints.desktop`
  static const double desktop = 900.0;
}
