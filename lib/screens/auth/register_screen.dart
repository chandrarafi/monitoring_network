import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/responsive_helper.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/error_message_widget.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    if (value.length < 2) {
      return 'Nama minimal 2 karakter';
    }
    return null;
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

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted && success) {
      // Only show success message, error will be handled by ErrorMessageWidget
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.registerSuccess),
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
      mobile: context.isVerySmallScreen ? 12 : 20,
      tablet: 24,
      desktop: 32,
    );

    final logoSize = ResponsiveHelper.getResponsiveValue(
      context,
      mobile: context.isVerySmallScreen ? 60 : 80,
      tablet: 100,
      desktop: 120,
    );

    final iconSize = ResponsiveHelper.getIconSize(
      context,
      mobile: context.isVerySmallScreen ? 30 : 40,
      tablet: 50,
      desktop: 60,
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back, 
            color: Colors.black87,
            size: ResponsiveHelper.getIconSize(context, mobile: 22, tablet: 24),
          ),
          onPressed: () => context.go('/auth/login'),
        ),
      ),
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
                          Icons.person_add,
                          size: iconSize,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: ResponsiveHelper.getSpacing(
                      context,
                      mobile: 20,
                      tablet: 28,
                      desktop: 32,
                    )),
                    
                    // Title
                    Text(
                      AppStrings.registerTitle,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: ResponsiveHelper.getSpacing(context, mobile: 6, tablet: 8)),
                    
                    Text(
                      'Buat akun baru untuk mengakses sistem',
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: ResponsiveHelper.getSpacing(
                      context,
                      mobile: 20,
                      tablet: 28,
                      desktop: 32,
                    )),
                    
                    // Name Field
                    CustomTextField(
                      label: AppStrings.name,
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      prefixIcon: Icons.person_outline,
                      validator: _validateName,
                    ),
                    
                    SizedBox(height: ResponsiveHelper.getSpacing(
                      context,
                      mobile: 16,
                      tablet: 20,
                      desktop: 24,
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
                    
                    // Register Button
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return CustomButton(
                          text: AppStrings.register,
                          onPressed: _handleRegister,
                          isLoading: authProvider.isLoading,
                          icon: Icons.person_add,
                        );
                      },
                    ),
                    
                    SizedBox(height: ResponsiveHelper.getSpacing(
                      context,
                      mobile: 20,
                      tablet: 24,
                      desktop: 28,
                    )),
                    
                    // Login Link
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          AppStrings.alreadyHaveAccount,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: linkFontSize,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.go('/auth/login');
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            AppStrings.login,
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