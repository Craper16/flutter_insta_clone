import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_insta/classes/app_colors.dart';
import 'package:flutter_insta/classes/country_code.dart';
import 'package:flutter_insta/constants/country_codes.dart';
import 'package:flutter_insta/dio/auth/signup_user.dart';
import 'package:flutter_insta/widgets/utils/country_picking_bottom_sheet_content.dart';
import 'package:flutter_insta/widgets/utils/custom_button.dart';
import 'package:flutter_insta/widgets/inputs/custom_text_form_field.dart';
import 'package:form_validator/form_validator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _signupScaffoldState = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  bool _headerTitlesSwapped = false;

  final ScrollController _mainScrollViewController = ScrollController();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  CountryCode _countryCode = countryCodes[0];

  bool _isSignupUserLoading = false;

  @override
  void initState() {
    super.initState();

    _mainScrollViewController.addListener(() {
      if (_mainScrollViewController.offset >= 106.5) {
        if (!_headerTitlesSwapped) {
          setState(() {
            _headerTitlesSwapped = true;
          });
        }
      } else {
        if (_headerTitlesSwapped) {
          setState(() {
            _headerTitlesSwapped = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _confirmPasswordController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _fullNameController.dispose();
    _phoneNumberController.dispose();

    _mainScrollViewController.dispose();

    super.dispose();
  }

  void _signUpUser() async {
    final isSignupFormValid = _formKey.currentState!.validate();

    _formKey.currentState!.save();

    if (isSignupFormValid) {
      setState(() {
        _isSignupUserLoading = true;
      });
      ScaffoldMessenger.of(context).clearMaterialBanners();

      try {
        await signupUser(
          _emailController.text,
          _passwordController.text,
          _usernameController.text,
          _fullNameController.text,
          _countryCode.code,
          _phoneNumberController.text,
        );

        if (context.mounted) {
          context.go(
            '/auth/verify-email?email=${_emailController.text}&login=true',
          );
        }
        setState(() {
          _isSignupUserLoading = false;
        });
      } on DioException catch (error) {
        setState(() {
          _isSignupUserLoading = false;
        });
        ScaffoldMessenger.of(context).clearMaterialBanners();
        ScaffoldMessenger.of(context).showMaterialBanner(
          MaterialBanner(
            onVisible: () => Timer(
              const Duration(
                seconds: 5,
              ),
              () => ScaffoldMessenger.of(context).clearMaterialBanners(),
            ),
            content: Text(
              error.response?.data['data']['message'],
              style: GoogleFonts.poppins(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () =>
                    ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
              ),
            ],
          ),
        );
      }
    }
  }

  void _openBottomCountryPickerSheet() {
    showModalBottomSheet(
      useRootNavigator: true,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      context: context,
      builder: (ctx) => CountryPickingBottomSheetContent(
        pickedCountry: _countryCode,
        onTapCountry: (countryCode) {
          setState(() {
            _countryCode = countryCode;
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        backgroundColor: appColors.primary,
        key: _signupScaffoldState,
        appBar: AppBar(
          backgroundColor: appColors.primary,
          title: AnimatedOpacity(
            opacity: _headerTitlesSwapped ? 1 : 0,
            duration: const Duration(
              milliseconds: 200,
            ),
            child: Text(
              'Sign up',
              style: GoogleFonts.poppins(
                color: appColors.secondary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                controller: _mainScrollViewController,
                child: Column(
                  children: <Widget>[
                    const SizedBox(
                      height: 50,
                    ),
                    AnimatedOpacity(
                      opacity: _headerTitlesSwapped ? 0 : 1,
                      duration: const Duration(milliseconds: 200),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          'Sign up',
                          style: GoogleFonts.poppins(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: appColors.secondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    CustomTextFormField(
                      label: 'Email',
                      hintText: 'Enter email',
                      validations: ValidationBuilder().email().build(),
                      textInputType: TextInputType.emailAddress,
                      controller: _emailController,
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    CustomTextFormField(
                      label: 'Username',
                      hintText: 'Enter username',
                      validations: ValidationBuilder().required().build(),
                      controller: _usernameController,
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    CustomTextFormField(
                      label: 'Password',
                      hintText: 'Enter password',
                      textInputType: TextInputType.visiblePassword,
                      isSecureTextEntry: true,
                      controller: _passwordController,
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
                        if (value != _confirmPasswordController.text) {
                          return 'Passwords must match';
                        }
                        return null;
                      }).build(),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    CustomTextFormField(
                      controller: _confirmPasswordController,
                      label: 'Confirm password',
                      hintText: 'Enter confirm password',
                      textInputType: TextInputType.visiblePassword,
                      isSecureTextEntry: true,
                      validations: ValidationBuilder().required().add((value) {
                        if (value != _passwordController.text) {
                          return 'Passwords must match';
                        }
                        return null;
                      }).build(),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    CustomTextFormField(
                      label: 'Full name',
                      hintText: 'Enter full name',
                      validations: ValidationBuilder().required().build(),
                      controller: _fullNameController,
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Row(
                      children: <Widget>[
                        InkWell(
                          onTap: _openBottomCountryPickerSheet,
                          child: Container(
                            height: 50,
                            width: 60,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: appColors.secondary,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(4),
                                )),
                            child: Text(
                              _countryCode.code,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: appColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: CustomTextFormField(
                            hintText: 'Phone number',
                            textInputType: TextInputType.number,
                            validations:
                                ValidationBuilder().phone().required().build(),
                            controller: _phoneNumberController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    CustomButton(
                      onPress: _signUpUser,
                      title: 'Sign up',
                      isLoading: _isSignupUserLoading,
                    ),
                    const SizedBox(
                      height: 150,
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
