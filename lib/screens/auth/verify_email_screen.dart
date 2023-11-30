import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_insta/classes/app_colors.dart';
import 'package:flutter_insta/classes/user.dart';
import 'package:flutter_insta/constants/tokens.dart';
import 'package:flutter_insta/dio/auth/resend_verification_code.dart';
import 'package:flutter_insta/dio/auth/verify_user_email.dart';
import 'package:flutter_insta/main.dart';
import 'package:flutter_insta/providers/auth_provider.dart';
import 'package:flutter_insta/screens/auth/reset_password_screen.dart';
import 'package:flutter_insta/screens/tabs/tabs_screen.dart';
import 'package:flutter_insta/widgets/utils/custom_button.dart';
import 'package:flutter_insta/widgets/utils/custom_underlined_text_button.dart';
import 'package:flutter_insta/widgets/utils/verification_input_form_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_validator/form_validator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({
    super.key,
    required this.email,
    this.login = 'false',
  });

  final String email;
  final String? login;

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final _formKey = GlobalKey<FormState>();

  final FocusNode _text1 = FocusNode();
  final FocusNode _text2 = FocusNode();
  final FocusNode _text3 = FocusNode();
  final FocusNode _text4 = FocusNode();

  bool _isLoadingVerifyUserEmail = false;

  String? _text1Value;
  String? _text2Value;
  String? _text3Value;
  String? _text4Value;

  String verificationCode = '';

  Timer? _timer;

  int _resendCounter = 30;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCounter == 0) return timer.cancel();
      setState(() {
        _resendCounter--;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();

    _text1.dispose();
    _text2.dispose();
    _text3.dispose();
    _text4.dispose();

    super.dispose();
  }

  void _verifyEmailAddress() async {
    final isVerifyEmailAddressFormValid = _formKey.currentState!.validate();

    _formKey.currentState?.save();

    if (isVerifyEmailAddressFormValid) {
      try {
        setState(() {
          _isLoadingVerifyUserEmail = true;
        });

        ScaffoldMessenger.of(context).clearMaterialBanners();
        final data = await verifyUserEmail(
          widget.email,
          '$_text1Value$_text2Value$_text3Value$_text4Value',
          widget.login,
        );

        if (context.mounted && widget.login != 'true') {
          final verificationCode =
              '$_text1Value$_text2Value$_text3Value$_text4Value';
          context.go(
            '/auth/reset-password?email=${widget.email}&code=$verificationCode',
          );
        } else {
          await storage.write(key: accessToken, value: data['access_token']);
          await storage.write(key: refreshToken, value: data['refresh_token']);
          await storage.write(key: expiresAt, value: data['expires_at']);
          ref.read(authProvider.notifier).setAuthData(
                AuthUser(
                  userId: data['user']['userId'],
                  email: data['user']['email'],
                  countryCode: data['user']['countryCode'],
                  fullName: data['user']['fullName'],
                  phoneNumber: data['user']['phoneNumber'],
                  username: data['user']['username'],
                  profilePicture: data['user']['profilePicture'],
                  followers: data['user']['followers'],
                  following: data['user']['following'],
                  accessToken: data['access_token'],
                  expiresAt: data['expires_at'],
                  refreshToken: data['refresh_token'],
                ),
              );

          if (context.mounted) {
            context.go('/posts');
          }
        }
        setState(() {
          _isLoadingVerifyUserEmail = false;
        });
      } on DioException catch (error) {
        setState(() {
          _isLoadingVerifyUserEmail = false;
        });
        ScaffoldMessenger.of(context).clearMaterialBanners();
        ScaffoldMessenger.of(context).showMaterialBanner(
          MaterialBanner(
            content: Text(
              error.response?.data['message'],
              style: GoogleFonts.poppins(
                color: appColors.secondary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    ScaffoldMessenger.of(context).clearMaterialBanners(),
                child: Text(
                  'Hide',
                  style: GoogleFonts.poppins(
                    color: appColors.secondary,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  void _resendVerificationCode() async {
    if (_resendCounter == 0) {
      setState(() {
        _resendCounter = 30;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_resendCounter == 0) return timer.cancel();
        setState(() {
          _resendCounter--;
        });
      });
      try {
        await resendVerificationCode(widget.email);
      } catch (error) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.login);
    return Scaffold(
      backgroundColor: appColors.primary,
      appBar: AppBar(
        backgroundColor: appColors.primary,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(
          FocusNode(),
        ),
        child: Center(
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
                    'Verify Email',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Enter your verification code to reset your password',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Row(
                    children: <Widget>[
                      const SizedBox(
                        width: 30,
                      ),
                      VerificationInputFormField(
                        textFocusNode: _text1,
                        onSaved: (text1) {
                          _text1Value = text1;
                        },
                        nextFocusNode: _text2,
                        validation: ValidationBuilder().required().add((value) {
                          if (value!.length != 1) {
                            return '';
                          }

                          return null;
                        }).build(),
                      ),
                      const SizedBox(
                        width: 30,
                      ),
                      VerificationInputFormField(
                        textFocusNode: _text2,
                        onSaved: (text2) {
                          _text2Value = text2;
                        },
                        nextFocusNode: _text3,
                        previousFocusNode: _text1,
                        validation: ValidationBuilder().required().add((value) {
                          if (value!.length != 1) {
                            return '';
                          }

                          return null;
                        }).build(),
                      ),
                      const SizedBox(
                        width: 30,
                      ),
                      VerificationInputFormField(
                        textFocusNode: _text3,
                        onSaved: (text3) {
                          _text3Value = text3;
                        },
                        nextFocusNode: _text4,
                        previousFocusNode: _text2,
                        validation: ValidationBuilder().required().add((value) {
                          if (value!.length != 1) {
                            return '';
                          }

                          return null;
                        }).build(),
                      ),
                      const SizedBox(
                        width: 30,
                      ),
                      VerificationInputFormField(
                        textFocusNode: _text4,
                        onSaved: (text4) {
                          _text4Value = text4;
                        },
                        previousFocusNode: _text3,
                        validation: ValidationBuilder().required().add((value) {
                          if (value!.length != 1) {
                            return '';
                          }

                          return null;
                        }).build(),
                      ),
                      const SizedBox(
                        width: 30,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  CustomUnderlinedTextButton(
                    title: _resendCounter != 0
                        ? 'Resend in $_resendCounter'
                        : 'Resend',
                    textDecoration: TextDecoration.none,
                    disabled: _resendCounter != 0,
                    onTap: _resendVerificationCode,
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  CustomButton(
                    onPress: _verifyEmailAddress,
                    title: 'Verify',
                    isLoading: _isLoadingVerifyUserEmail,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
