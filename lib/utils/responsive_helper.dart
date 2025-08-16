import 'package:flutter/material.dart';

class ResponsiveHelper {
  static const double _mobileBreakpoint = 600;
  static const double _tabletBreakpoint = 1024;

  // Screen size checks
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < _mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= _mobileBreakpoint && width < _tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= _tabletBreakpoint;
  }

  // Get responsive values
  static double getResponsiveValue(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }

  // Responsive padding
  static EdgeInsets getResponsivePadding(
    BuildContext context, {
    double mobileHorizontal = 16,
    double mobileVertical = 16,
    double? tabletHorizontal,
    double? tabletVertical,
    double? desktopHorizontal,
    double? desktopVertical,
  }) {
    final horizontal = getResponsiveValue(
      context,
      mobile: mobileHorizontal,
      tablet: tabletHorizontal,
      desktop: desktopHorizontal,
    );
    final vertical = getResponsiveValue(
      context,
      mobile: mobileVertical,
      tablet: tabletVertical,
      desktop: desktopVertical,
    );
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  }

  // Responsive margin
  static EdgeInsets getResponsiveMargin(
    BuildContext context, {
    double mobileHorizontal = 8,
    double mobileVertical = 8,
    double? tabletHorizontal,
    double? tabletVertical,
    double? desktopHorizontal,
    double? desktopVertical,
  }) {
    final horizontal = getResponsiveValue(
      context,
      mobile: mobileHorizontal,
      tablet: tabletHorizontal,
      desktop: desktopHorizontal,
    );
    final vertical = getResponsiveValue(
      context,
      mobile: mobileVertical,
      tablet: tabletVertical,
      desktop: desktopVertical,
    );
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  }

  // Responsive font size
  static double getResponsiveFontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return getResponsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  // Grid cross axis count
  static int getGridCrossAxisCount(
    BuildContext context, {
    int mobile = 2,
    int tablet = 3,
    int desktop = 4,
  }) {
    if (isDesktop(context)) {
      return desktop;
    } else if (isTablet(context)) {
      return tablet;
    } else {
      return mobile;
    }
  }

  // Button height
  static double getButtonHeight(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 48,
      tablet: 52,
      desktop: 56,
    );
  }

  // Card elevation
  static double getCardElevation(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 2,
      tablet: 4,
      desktop: 6,
    );
  }

  // Icon size
  static double getIconSize(
    BuildContext context, {
    double mobile = 24,
    double? tablet,
    double? desktop,
  }) {
    return getResponsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  // App bar height
  static double getAppBarHeight(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: kToolbarHeight,
      tablet: kToolbarHeight + 8,
      desktop: kToolbarHeight + 16,
    );
  }

  // Get responsive spacing
  static double getSpacing(
    BuildContext context, {
    double mobile = 8,
    double? tablet,
    double? desktop,
  }) {
    return getResponsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  // Get container width
  static double getContainerWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (isDesktop(context)) {
      return screenWidth * 0.9;
    } else if (isTablet(context)) {
      return screenWidth * 0.95;
    } else {
      return screenWidth;
    }
  }

  // Get container max width
  static double getMaxWidth(BuildContext context) {
    if (isDesktop(context)) {
      return 1200;
    } else if (isTablet(context)) {
      return 800;
    } else {
      return double.infinity;
    }
  }

  // Text scale factor
  static double getTextScaleFactor(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) {
      // Very small screens (iPhone 5S, SE)
      return 0.8;
    } else if (width <= 375) {
      // Small screens (iPhone 6, 7, 8)
      return 0.85;
    } else if (width <= 414) {
      // Medium screens (iPhone 6+, 7+, 8+)
      return 0.9;
    } else {
      return 1.0;
    }
  }

  // Check if screen is very small
  static bool isVerySmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width <= 360;
  }

  // Check if screen is small
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width <= 414;
  }

  // Get responsive grid child aspect ratio
  static double getGridChildAspectRatio(
    BuildContext context, {
    double verySmall = 3.5,
    double small = 1.1,
    double normal = 1.2,
  }) {
    if (isVerySmallScreen(context)) {
      return verySmall;
    } else if (isSmallScreen(context)) {
      return small;
    } else {
      return normal;
    }
  }

  // Get safe padding that prevents overflow
  static EdgeInsets getSafePadding(
    BuildContext context, {
    double mobileMin = 8,
    double mobileMax = 16,
    double tablet = 20,
    double desktop = 24,
  }) {
    if (isVerySmallScreen(context)) {
      return EdgeInsets.all(mobileMin);
    } else if (isMobile(context)) {
      return EdgeInsets.all(mobileMax);
    } else if (isTablet(context)) {
      return EdgeInsets.all(tablet);
    } else {
      return EdgeInsets.all(desktop);
    }
  }

  // Responsive border radius
  static double getBorderRadius(
    BuildContext context, {
    double mobile = 8,
    double? tablet,
    double? desktop,
  }) {
    return getResponsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
}

// Extension for easier usage
extension ResponsiveExtension on BuildContext {
  bool get isMobile => ResponsiveHelper.isMobile(this);
  bool get isTablet => ResponsiveHelper.isTablet(this);
  bool get isDesktop => ResponsiveHelper.isDesktop(this);
  bool get isVerySmallScreen => ResponsiveHelper.isVerySmallScreen(this);
  bool get isSmallScreen => ResponsiveHelper.isSmallScreen(this);
  
  double get textScaleFactor => ResponsiveHelper.getTextScaleFactor(this);
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
}