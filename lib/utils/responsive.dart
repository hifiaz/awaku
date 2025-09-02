import 'package:flutter/material.dart';

/// Responsive utility class for handling different screen sizes
class Responsive {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  /// Check if the current screen is mobile size
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Check if the current screen is tablet size
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  /// Check if the current screen is desktop size
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    } else {
      return const EdgeInsets.symmetric(horizontal: 64, vertical: 24);
    }
  }

  /// Get responsive margin based on screen size
  static EdgeInsets getResponsiveMargin(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  /// Get responsive font size multiplier
  static double getFontSizeMultiplier(BuildContext context) {
    if (isMobile(context)) {
      return 1.0;
    } else if (isTablet(context)) {
      return 1.1;
    } else {
      return 1.2;
    }
  }

  /// Get responsive grid columns count
  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) {
      return 2;
    } else if (isTablet(context)) {
      return 3;
    } else {
      return 4;
    }
  }

  /// Get responsive card width
  static double getCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (isMobile(context)) {
      return screenWidth - 32; // Full width with padding
    } else if (isTablet(context)) {
      return (screenWidth - 96) / 2; // Two columns with spacing
    } else {
      return (screenWidth - 160) / 3; // Three columns with spacing
    }
  }

  /// Get responsive spacing
  static double getResponsiveSpacing(BuildContext context, {double base = 16}) {
    final multiplier = getFontSizeMultiplier(context);
    return base * multiplier;
  }

  /// Get responsive icon size
  static double getResponsiveIconSize(BuildContext context, {double base = 24}) {
    final multiplier = getFontSizeMultiplier(context);
    return base * multiplier;
  }

  /// Get responsive border radius
  static double getResponsiveBorderRadius(BuildContext context, {double base = 16}) {
    if (isMobile(context)) {
      return base;
    } else if (isTablet(context)) {
      return base * 1.2;
    } else {
      return base * 1.4;
    }
  }

  /// Get maximum content width for better readability on large screens
  static double getMaxContentWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (isDesktop(context)) {
      return screenWidth * 0.8; // 80% of screen width on desktop
    }
    return screenWidth; // Full width on mobile and tablet
  }

  /// Responsive widget builder
  static Widget responsive({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }
}

/// Extension on BuildContext for easier access to responsive utilities
extension ResponsiveContext on BuildContext {
  bool get isMobile => Responsive.isMobile(this);
  bool get isTablet => Responsive.isTablet(this);
  bool get isDesktop => Responsive.isDesktop(this);
  
  EdgeInsets get responsivePadding => Responsive.getResponsivePadding(this);
  EdgeInsets get responsiveMargin => Responsive.getResponsiveMargin(this);
  
  double get fontSizeMultiplier => Responsive.getFontSizeMultiplier(this);
  int get gridColumns => Responsive.getGridColumns(this);
  double get cardWidth => Responsive.getCardWidth(this);
  double get maxContentWidth => Responsive.getMaxContentWidth(this);
  
  double responsiveSpacing([double base = 16]) => Responsive.getResponsiveSpacing(this, base: base);
  double responsiveIconSize([double base = 24]) => Responsive.getResponsiveIconSize(this, base: base);
  double responsiveBorderRadius([double base = 16]) => Responsive.getResponsiveBorderRadius(this, base: base);
}