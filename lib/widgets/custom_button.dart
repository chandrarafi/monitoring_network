import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveHeight = height ?? ResponsiveHelper.getButtonHeight(context);
    final fontSize = ResponsiveHelper.getResponsiveFontSize(
      context,
      mobile: 14,
      tablet: 16,
      desktop: 16,
    );
    final iconSize = ResponsiveHelper.getIconSize(
      context,
      mobile: 18,
      tablet: 20,
      desktop: 22,
    );
    final borderRadius = ResponsiveHelper.getBorderRadius(
      context,
      mobile: 8,
      tablet: 10,
      desktop: 12,
    );
    final spacing = ResponsiveHelper.getSpacing(
      context,
      mobile: 6,
      tablet: 8,
      desktop: 8,
    );

    return SizedBox(
      width: width ?? double.infinity,
      height: responsiveHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.blue,
          foregroundColor: textColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: ResponsiveHelper.getCardElevation(context),
          shadowColor: Colors.black26,
          padding: ResponsiveHelper.getResponsivePadding(
            context,
            mobileHorizontal: 12,
            mobileVertical: 12,
            tabletHorizontal: 16,
            tabletVertical: 16,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: iconSize,
                height: iconSize,
                child: CircularProgressIndicator(
                  strokeWidth: context.isVerySmallScreen ? 1.5 : 2,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: iconSize),
                    SizedBox(width: spacing),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}