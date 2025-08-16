import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String? hintText;
  final bool isPassword;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final int maxLines;

  const CustomTextField({
    super.key,
    required this.label,
    this.hintText,
    this.isPassword = false,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.maxLines = 1,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    final labelFontSize = ResponsiveHelper.getResponsiveFontSize(
      context,
      mobile: 14,
      tablet: 16,
      desktop: 16,
    );
    final hintFontSize = ResponsiveHelper.getResponsiveFontSize(
      context,
      mobile: 14,
      tablet: 15,
      desktop: 16,
    );
    final iconSize = ResponsiveHelper.getIconSize(
      context,
      mobile: 20,
      tablet: 22,
      desktop: 24,
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
    final contentPadding = ResponsiveHelper.getResponsivePadding(
      context,
      mobileHorizontal: 12,
      mobileVertical: 12,
      tabletHorizontal: 16,
      tabletVertical: 16,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: labelFontSize,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: spacing),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword ? _isObscured : false,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          minLines: widget.maxLines > 1 ? 3 : 1,
          style: TextStyle(fontSize: hintFontSize),
          decoration: InputDecoration(
            hintText: widget.hintText ?? widget.label,
            hintStyle: TextStyle(
              fontSize: hintFontSize,
              color: Colors.grey[600],
            ),
            prefixIcon: widget.prefixIcon != null 
                ? Icon(
                    widget.prefixIcon, 
                    color: Colors.blue,
                    size: iconSize,
                  ) 
                : null,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _isObscured ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                      size: iconSize,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: contentPadding,
            isDense: context.isVerySmallScreen,
          ),
        ),
      ],
    );
  }
}