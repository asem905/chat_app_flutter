// ignore_for_file: deprecated_member_use

import 'package:chat_app/core/helpers/extensions.dart';
import 'package:chat_app/core/routing/routes.dart';
import 'package:chat_app/features/login/logic/cubit/login_cubit.dart';
import 'package:chat_app/features/login/logic/cubit/login_state.dart';
import 'package:chat_app/features/login/view/widgets/password_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/text_styles.dart';
import '../../../../core/widgets/app_custom_button.dart';
import '../../../../core/widgets/app_text_form_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<LoginCubit>().login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: BlocConsumer<LoginCubit, LoginState>(
            listener: (context, state) {
              if (state is LoginSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 12.w),
                        const Text('Login successful!'),
                      ],
                    ),
                    backgroundColor: AppColors.secondary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.all(16),
                  ),
                );
                context.pushNamed(Routes.homeScreen);
              } else if (state is LoginError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(child: Text(state.message)),
                      ],
                    ),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: EdgeInsets.only(
                      left: 16.w,
                      right: 16.w,
                      top: 16.h,
                      bottom: 16.h,
                    ),
                  ),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is LoginLoading;

              return SingleChildScrollView(
                padding: EdgeInsets.all(24.w),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20.h),
                          Center(
                            child: Hero(
                              tag: 'app_logo',
                              child: Container(
                                width: 90.w,
                                height: 90.h,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.primary,
                                      AppColors.primaryDark,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(24.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.chat_bubble_outline,
                                  size: 45,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 40.h),

                          // Welcome Text with animation
                          Text('Welcome Back!', style: AppTextStyles.heading1),

                          SizedBox(height: 8.h),

                          Text(
                            'Sign in to continue to your account',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 15.sp,
                            ),
                          ),

                          SizedBox(height: 40.h),

                          // Email Field
                          CustomTextFormField(
                            controller: _emailController,
                            hintText: 'Enter your email',
                            labelText: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: AppColors.textSecondary,
                            ),
                            validator: _validateEmail,
                            enabled: !isLoading,
                          ),

                          SizedBox(height: 20.h),

                          // Password Field
                          PasswordTextField(
                            controller: _passwordController,
                            enabled: !isLoading,
                            validator: _validatePassword,
                          ),

                          SizedBox(height: 16.h),

                          // Remember Me & Forgot Password
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 24.w,
                                    height: 24.h,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      onChanged: isLoading
                                          ? null
                                          : (value) {
                                              setState(
                                                () => _rememberMe = value!,
                                              );
                                            },
                                      activeColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          6.r,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Remember me',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        // Navigate to forgot password
                                      },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                  ),
                                ),
                                child: Text(
                                  'Forgot Password?',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 32.h),

                          // Login Button with enhanced styling
                          CustomButton(
                            text: 'Login',
                            onPressed: isLoading ? null : _handleLogin,
                            isLoading: isLoading,
                            suffixIcon: !isLoading
                                ? const Icon(Icons.arrow_forward, size: 20)
                                : null,
                          ),

                          SizedBox(height: 32.h),

                          // Divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: AppColors.border,
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                child: Text(
                                  'OR',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: AppColors.border,
                                  thickness: 1.w,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 32.h),

                          // Social Login Buttons
                          CustomButton(
                            text: 'Continue with Google',
                            type: ButtonType.outlined,
                            height: 56.h,
                            onPressed: isLoading
                                ? null
                                : () {
                                    // Handle Google login
                                  },
                            prefixIcon: Container(
                              padding: EdgeInsets.only(
                                bottom: 2.h,
                                right: 2.w,
                                left: 2.w,
                                top: 2.h,
                              ),
                              child: Image.asset(
                                'assets/images/google_icon.png', // Add Google icon to assets
                                width: 24.w,
                                height: 24.h,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.g_mobiledata,
                                    size: 28.sp,
                                    color: AppColors.primary,
                                  );
                                },
                              ),
                            ),
                          ),

                          SizedBox(height: 40.h),

                          // Sign Up Link
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: AppTextStyles.bodyMedium,
                                ),
                                TextButton(
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          context.pushNamed(
                                            Routes.signUpScreen,
                                          );
                                        },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size(50.w, 30.h),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Sign Up',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
