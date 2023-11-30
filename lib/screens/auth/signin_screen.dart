import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_insta/classes/app_colors.dart';
import 'package:flutter_insta/classes/user.dart';
import 'package:flutter_insta/constants/tokens.dart';
import 'package:flutter_insta/dio/auth/login_user.dart';
import 'package:flutter_insta/main.dart';
import 'package:flutter_insta/providers/auth_provider.dart';
import 'package:flutter_insta/widgets/utils/custom_button.dart';
import 'package:flutter_insta/widgets/inputs/custom_text_form_field.dart';
import 'package:flutter_insta/widgets/utils/custom_underlined_text_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_validator/form_validator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class SigninScreen extends ConsumerStatefulWidget {
  const SigninScreen({super.key});

  @override
  ConsumerState<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends ConsumerState<SigninScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _emailOrUsername;
  String? _password;

  bool _isLoginLoading = false;

  void _loginUser() async {
    final bool isFormValid = _formKey.currentState!.validate();
    _formKey.currentState!.save();

    if (isFormValid) {
      setState(() {
        _isLoginLoading = true;
      });
      try {
        final data = await logUserIn(
          _emailOrUsername!,
          _password!,
        );

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

        setState(() {
          _isLoginLoading = false;
        });
      } on DioException catch (error) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            action: SnackBarAction(
              label: 'Close',
              onPressed: () => ScaffoldMessenger.of(context).clearSnackBars(),
              textColor: appColors.primary,
            ),
            content: Row(
              children: <Widget>[
                Icon(
                  Icons.info,
                  color: appColors.primary,
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  '${error.response?.data['data']['message']}',
                  style: GoogleFonts.poppins(
                    color: appColors.primary,
                  ),
                )
              ],
            ),
          ),
        );
        setState(() {
          _isLoginLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _formKey.currentState?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(
        FocusNode(),
      ),
      child: Scaffold(
        backgroundColor: appColors.primary,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: AlignmentDirectional.center,
                    child: Text(
                      'Login',
                      style: GoogleFonts.poppins(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: appColors.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  CustomTextFormField(
                    hintText: 'Email or username',
                    onSaved: (newEmailOrUsername) =>
                        _emailOrUsername = newEmailOrUsername,
                    validations: ValidationBuilder().required().build(),
                    textInputType: TextInputType.emailAddress,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  CustomTextFormField(
                    hintText: 'Password',
                    onSaved: (newPassword) => _password = newPassword,
                    validations: ValidationBuilder().required().build(),
                    isSecureTextEntry: true,
                    textInputType: TextInputType.visiblePassword,
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  CustomUnderlinedTextButton(
                    alignment: AlignmentDirectional.centerEnd,
                    title: 'Forgot password?',
                    onTap: () => context.push(
                      '/auth/forgot-password',
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  CustomButton(
                    onPress: _loginUser,
                    title: 'Login',
                    isLoading: _isLoginLoading,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomUnderlinedTextButton(
                    title: 'Don\'t have an account?',
                    onTap: () => context.push('/auth/signup'),
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
