import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

class ErrorMessageWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onDismiss;

  const ErrorMessageWidget({
    super.key,
    this.message,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.isEmpty) {
      return const SizedBox.shrink();
    }

    final fontSize = ResponsiveHelper.getResponsiveFontSize(
      context,
      mobile: context.isVerySmallScreen ? 12 : 14,
      tablet: 14,
      desktop: 16,
    );
    final iconSize = ResponsiveHelper.getIconSize(
      context,
      mobile: context.isVerySmallScreen ? 18 : 20,
      tablet: 20,
      desktop: 22,
    );
    final closeIconSize = ResponsiveHelper.getIconSize(
      context,
      mobile: context.isVerySmallScreen ? 16 : 18,
      tablet: 18,
      desktop: 20,
    );
    final padding = ResponsiveHelper.getSafePadding(
      context,
      mobileMin: 8,
      mobileMax: 12,
      tablet: 16,
      desktop: 16,
    );
    final borderRadius = ResponsiveHelper.getBorderRadius(
      context,
      mobile: 6,
      tablet: 8,
      desktop: 10,
    );
    final spacing = ResponsiveHelper.getSpacing(
      context,
      mobile: context.isVerySmallScreen ? 8 : 12,
      tablet: 12,
      desktop: 16,
    );

    return Container(
      margin: EdgeInsets.only(bottom: spacing),
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red[300]!),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[700],
            size: iconSize,
          ),
          SizedBox(width: spacing),
          Expanded(
            child: Text(
              message!,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
              maxLines: context.isVerySmallScreen ? 3 : null,
              overflow: context.isVerySmallScreen ? TextOverflow.ellipsis : null,
            ),
          ),
          if (onDismiss != null) ...[
            SizedBox(width: spacing * 0.5),
            GestureDetector(
              onTap: onDismiss,
              child: Padding(
                padding: EdgeInsets.all(context.isVerySmallScreen ? 2 : 4),
                child: Icon(
                  Icons.close,
                  color: Colors.red[700],
                  size: closeIconSize,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}