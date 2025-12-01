import 'package:flutter/material.dart';
import '../../../../core/widgets/app_text_form_field.dart';
import '../../../../core/theming/app_colors.dart';

class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? errorText;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool enabled;

  const PasswordTextField({
    Key? key,
    required this.controller,
    this.labelText,
    this.errorText,
    this.onChanged,
    this.validator,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return CustomTextFormField(
      controller: widget.controller,
      hintText: 'Enter your password',
      labelText: widget.labelText ?? 'Password',
      errorText: widget.errorText,
      obscureText: _isObscured,
      keyboardType: TextInputType.visiblePassword,
      onChanged: widget.onChanged,
      validator: widget.validator,
      enabled: widget.enabled,
      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
      suffixIcon: IconButton(
        icon: Icon(
          _isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: AppColors.textSecondary,
        ),
        onPressed: () {
          setState(() => _isObscured = !_isObscured);
        },
      ),
    );
  }
}
