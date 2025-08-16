import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/responsive_helper.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/error_message_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted && success) {
      // Only show success message, error will be handled by ErrorMessageWidget
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.loginSuccess),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.getResponsivePadding(
      context,
      mobileHorizontal: context.isVerySmallScreen ? 16 : 24,
      mobileVertical: 16,
      tabletHorizontal: 32,
      tabletVertical: 24,
    );
    
    final topSpacing = ResponsiveHelper.getResponsiveValue(
      context,
      mobile: context.isVerySmallScreen ? 20 : 40,
      tablet: 60,
      desktop: 80,
    );

    final logoSize = ResponsiveHelper.getResponsiveValue(
      context,
      mobile: context.isVerySmallScreen ? 80 : 100,
      tablet: 120,
      desktop: 140,
    );

    final iconSize = ResponsiveHelper.getIconSize(
      context,
      mobile: context.isVerySmallScreen ? 40 : 50,
      tablet: 60,
      desktop: 70,
    );

    final titleFontSize = ResponsiveHelper.getResponsiveFontSize(
      context,
      mobile: context.isVerySmallScreen ? 24 : 28,
      tablet: 32,
      desktop: 36,
    );

    final subtitleFontSize = ResponsiveHelper.getResponsiveFontSize(
      context,
      mobile: 14,
      tablet: 16,
      desktop: 18,
    );

    final linkFontSize = ResponsiveHelper.getResponsiveFontSize(
      context,
      mobile: 14,
      tablet: 15,
      desktop: 16,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ResponsiveHelper.getMaxWidth(context),
            ),
            child: SingleChildScrollView(
              padding: padding,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: topSpacing),
                    
                    // Logo or Icon
                    Center(
                      child: Container(
                        height: logoSize,
                        width: logoSize,
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(logoSize / 2),
                        ),
                        child: Icon(
                          Icons.router,
                          size: iconSize,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: ResponsiveHelper.getSpacing(
                      context,
                      mobile: 24,
                      tablet: 32,
                      desktop: 40,
                    )),
                    
                    // Title
                    Text(
                      AppStrings.loginTitle,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: ResponsiveHelper.getSpacing(context, mobile: 6, tablet: 8)),
                    
                    Text(
                      'Masuk untuk mengelola jaringan MikroTik',
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: ResponsiveHelper.getSpacing(
                      context,
                      mobile: 24,
                      tablet: 32,
                      desktop: 40,
                    )),
                    
                    // Email Field
                    CustomTextField(
                      label: AppStrings.email,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: _validateEmail,
                    ),
                    
                    SizedBox(height: ResponsiveHelper.getSpacing(
                      context,
                      mobile: 16,
                      tablet: 20,
                      desktop: 24,
                    )),
                    
                    // Password Field
                    CustomTextField(
                      label: AppStrings.password,
                      controller: _passwordController,
                      isPassword: true,
                      prefixIcon: Icons.lock_outline,
                      validator: _validatePassword,
                    ),
                    
                    SizedBox(height: ResponsiveHelper.getSpacing(
                      context,
                      mobile: 20,
                      tablet: 24,
                      desktop: 28,
                    )),
                    
                    // Error Message
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        if (authProvider.errorMessage != null && authProvider.errorMessage!.isNotEmpty) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: ResponsiveHelper.getSpacing(context, mobile: 16),
                            ),
                            child: ErrorMessageWidget(
                              message: authProvider.errorMessage!,
                              onDismiss: () {
                                authProvider.clearError();
                              },
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    
                    // Login Button
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return CustomButton(
                          text: AppStrings.login,
                          onPressed: _handleLogin,
                          isLoading: authProvider.isLoading,
                          icon: Icons.login,
                        );
                      },
                    ),
                    
                    SizedBox(height: ResponsiveHelper.getSpacing(
                      context,
                      mobile: 20,
                      tablet: 24,
                      desktop: 28,
                    )),
                    
                    // Register Link
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          AppStrings.dontHaveAccount,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: linkFontSize,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.go('/auth/register');
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            AppStrings.register,
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                              fontSize: linkFontSize,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}