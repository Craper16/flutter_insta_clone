import 'package:flutter/material.dart';
import 'package:flutter_insta/classes/app_colors.dart';
import 'package:flutter_insta/dio/auth/reset_password.dart';
import 'package:flutter_insta/screens/auth/signin_screen.dart';
import 'package:flutter_insta/widgets/utils/custom_button.dart';
import 'package:flutter_insta/widgets/inputs/custom_text_form_field.dart';
import 'package:flutter_insta/widgets/utils/custom_underlined_text_button.dart';
import 'package:form_validator/form_validator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.verificationCode,
    required this.email,
  });

  final String verificationCode;
  final String email;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();

  bool _isResetPasswordLoading = false;

  void _resetPassword() async {
    final isValid = _formKey.currentState!.validate();
    _formKey.currentState!.save();

    if (isValid) {
      try {
        setState(() {
          _isResetPasswordLoading = true;
        });

        await resetPassword(
          widget.email,
          _newPasswordController.text,
          int.parse(widget.verificationCode),
        );

        if (context.mounted) {
          context.go('/auth/signin');
        }
        setState(() {
          _isResetPasswordLoading = false;
        });
      } catch (e) {
        setState(() {
          _isResetPasswordLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColors.primary,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 25,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Reset Password',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  'Reset your password to regain access to your account',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                CustomTextFormField(
                  controller: _newPasswordController,
                  hintText: 'New password',
                  validations: ValidationBuilder()
                      .regExp(
                        RegExp(r'[A-Z]'),
                        'Must contain at least 1 uppercase letter',
                      )
                      .regExp(
                        RegExp(r'[a-z]'),
                        'Must contain at least 1 lowercase letter',
                      )
                      .regExp(
                        RegExp(r'[0-9]'),
                        'Must contain at least 1 digit',
                      )
                      .regExp(
                        RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
                        'Must contain at least 1 special character',
                      )
                      .required()
                      .add((value) {
                    if (value != _confirmNewPasswordController.text) {
                      return 'Passwords must match';
                    }
                    return null;
                  }).build(),
                  textInputType: TextInputType.emailAddress,
                  isSecureTextEntry: true,
                ),
                const SizedBox(
                  height: 15,
                ),
                CustomTextFormField(
                  controller: _confirmNewPasswordController,
                  hintText: 'Confirm new password',
                  validations: ValidationBuilder().required().add((value) {
                    if (value != _newPasswordController.text) {
                      return 'Passwords must match';
                    }
                    return null;
                  }).build(),
                  isSecureTextEntry: true,
                  textInputType: TextInputType.visiblePassword,
                ),
                const SizedBox(
                  height: 25,
                ),
                CustomUnderlinedTextButton(
                  alignment: AlignmentDirectional.centerEnd,
                  title: 'Back to login',
                  onTap: () => context.go('/auth/signin'),
                ),
                const SizedBox(
                  height: 40,
                ),
                CustomButton(
                  onPress: _resetPassword,
                  title: 'Reset',
                  isLoading: _isResetPasswordLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
