import 'package:flutter/material.dart';

/// Device type based on screen shortest side (rotation-independent).
///
/// Using `shortestSide` ensures a phone in landscape is still detected
/// as [mobile], and a tablet in portrait is still detected as [tablet].
enum DeviceType { mobile, tablet }

/// Combined device type + orientation for granular layout control.
enum LayoutMode {
  mobilePortrait,
  mobileLandscape,
  tabletPortrait,
  tabletLandscape,
}

/// Centralized responsive utility for the Pax Payment app.
///
/// Provides device type detection, orientation helpers, and responsive
/// value pickers — all from a single place.
///
/// Usage:
/// ```dart
/// final r = Responsive.of(context);
///
/// // Simple device check
/// if (r.isMobile) { ... }
///
/// // Pick value by device type
/// final padding = r.value(mobile: 8.0, tablet: 16.0);
///
/// // Pick value by all 4 layout combinations
/// final flex = r.layout(
///   mobilePortrait: 60,
///   mobileLandscape: 45,
///   tabletPortrait: 55,
///   tabletLandscape: 30,
/// );
/// ```
class Responsive {
  final Size screenSize;
  final Orientation orientation;
  final EdgeInsets viewPadding;

  const Responsive._({
    required this.screenSize,
    required this.orientation,
    required this.viewPadding,
  });

  /// Create a [Responsive] instance from [BuildContext].
  ///
  /// Reads [MediaQuery] once and caches the values, so you can pass
  /// this instance to helper methods without repeated lookups.
  factory Responsive.of(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Responsive._(
      screenSize: mq.size,
      orientation: mq.orientation,
      viewPadding: mq.viewPadding,
    );
  }

  // ---------------------------------------------------------------------------
  // Screen dimensions
  // ---------------------------------------------------------------------------

  double get width => screenSize.width;
  double get height => screenSize.height;
  double get shortestSide => screenSize.shortestSide;
  double get longestSide => screenSize.longestSide;

  // ---------------------------------------------------------------------------
  // Device type — rotation-independent via shortestSide
  // ---------------------------------------------------------------------------

  /// Standard Material breakpoint: shortestSide >= 600 → tablet.
  static const double tabletBreakpoint = 600.0;

  DeviceType get deviceType =>
      shortestSide >= tabletBreakpoint ? DeviceType.tablet : DeviceType.mobile;

  bool get isMobile => deviceType == DeviceType.mobile;
  bool get isTablet => deviceType == DeviceType.tablet;

  // ---------------------------------------------------------------------------
  // Orientation
  // ---------------------------------------------------------------------------

  bool get isLandscape => orientation == Orientation.landscape;
  bool get isPortrait => orientation == Orientation.portrait;

  // ---------------------------------------------------------------------------
  // Layout mode (device + orientation)
  // ---------------------------------------------------------------------------

  LayoutMode get layoutMode {
    if (isMobile) {
      return isLandscape
          ? LayoutMode.mobileLandscape
          : LayoutMode.mobilePortrait;
    }
    return isLandscape ? LayoutMode.tabletLandscape : LayoutMode.tabletPortrait;
  }

  // ---------------------------------------------------------------------------
  // Compact detection
  // ---------------------------------------------------------------------------

  /// True when available height is very limited (e.g., phone in landscape).
  bool get isCompactHeight => height < 400;

  // ---------------------------------------------------------------------------
  // Responsive value helpers
  // ---------------------------------------------------------------------------

  /// Pick a value based on device type (mobile vs tablet).
  T value<T>({required T mobile, required T tablet}) =>
      isMobile ? mobile : tablet;

  /// Pick a value based on all 4 layout combinations.
  T layout<T>({
    required T mobilePortrait,
    required T mobileLandscape,
    required T tabletPortrait,
    required T tabletLandscape,
  }) =>
      switch (layoutMode) {
        LayoutMode.mobilePortrait => mobilePortrait,
        LayoutMode.mobileLandscape => mobileLandscape,
        LayoutMode.tabletPortrait => tabletPortrait,
        LayoutMode.tabletLandscape => tabletLandscape,
      };

  /// Pick a value based on orientation only.
  T orient<T>({required T portrait, required T landscape}) =>
      isLandscape ? landscape : portrait;

  // ---------------------------------------------------------------------------
  // Sizing helpers
  // ---------------------------------------------------------------------------

  /// Width as a fraction of screen width, optionally clamped.
  double widthPercent(double fraction, {double? min, double? max}) {
    double result = width * fraction;
    if (min != null && result < min) result = min;
    if (max != null && result > max) result = max;
    return result;
  }

  /// Height as a fraction of screen height, optionally clamped.
  double heightPercent(double fraction, {double? min, double? max}) {
    double result = height * fraction;
    if (min != null && result < min) result = min;
    if (max != null && result > max) result = max;
    return result;
  }
}
