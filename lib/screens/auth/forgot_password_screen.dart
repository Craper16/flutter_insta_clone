import 'package:flutter/material.dart';
import 'package:flutter_insta/classes/app_colors.dart';
import 'package:flutter_insta/dio/auth/resend_verification_code.dart';
import 'package:flutter_insta/screens/auth/verify_email_screen.dart';
import 'package:flutter_insta/widgets/utils/custom_button.dart';
import 'package:flutter_insta/widgets/inputs/custom_text_form_field.dart';
import 'package:form_validator/form_validator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _email;

  @override
  void dispose() {
    _formKey.currentState?.dispose();

    super.dispose();
  }

  void _sendVerificationCode() async {
    final isFormValid = _formKey.currentState!.validate();
    _formKey.currentState!.save();

    if (isFormValid) {
      try {
        await resendVerificationCode(_email!);

        if (context.mounted) {
          context.push('/auth/verify-email?email=$_email');
        }
      } catch (error) {
        context.push('/auth/verify-email?email=$_email');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(
        FocusNode(),
      ),
      child: Scaffold(
        backgroundColor: appColors.primary,
        appBar: AppBar(
          backgroundColor: appColors.primary,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 25,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Forgot Password',
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
                    'Enter your email to receive your verification code',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  CustomTextFormField(
                    onSaved: (newEmail) => _email = newEmail,
                    validations: ValidationBuilder().required().email().build(),
                    hintText: 'Email',
                    textInputType: TextInputType.emailAddress,
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  CustomButton(
                    onPress: _sendVerificationCode,
                    title: 'Send',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
