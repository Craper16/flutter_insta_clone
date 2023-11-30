import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_insta/classes/app_colors.dart';
import 'package:flutter_insta/classes/country_code.dart';
import 'package:flutter_insta/classes/user.dart';
import 'package:flutter_insta/constants/constants.dart';
import 'package:flutter_insta/constants/country_codes.dart';
import 'package:flutter_insta/constants/tokens.dart';
import 'package:flutter_insta/dio/profile/edit_profile.dart';
import 'package:flutter_insta/main.dart';
import 'package:flutter_insta/providers/auth_provider.dart';
import 'package:flutter_insta/widgets/inputs/form_input.dart';
import 'package:flutter_insta/widgets/utils/country_picking_bottom_sheet_content.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class EditUserProfileModalContent extends ConsumerStatefulWidget {
  const EditUserProfileModalContent({
    super.key,
    required this.onEditProfilePictureTap,
  });

  final void Function() onEditProfilePictureTap;

  @override
  ConsumerState<EditUserProfileModalContent> createState() =>
      _EditUserProfileModalContentState();
}

class _EditUserProfileModalContentState
    extends ConsumerState<EditUserProfileModalContent> {
  final _formKey = GlobalKey<FormState>();

  CountryCode? _selectedCountryCode;
  TextEditingController? _fullNameController;
  TextEditingController? _usernameController;
  TextEditingController? _phoneNumber;

  String? _error;

  bool _isLoadingEditProfile = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedCountryCode = countryCodes.firstWhere(
        (countryCode) =>
            countryCode.code == ref.read(authProvider)!.countryCode,
      );
      _fullNameController =
          TextEditingController(text: ref.read(authProvider)?.fullName);
      _usernameController =
          TextEditingController(text: ref.read(authProvider)?.username);
      _phoneNumber = TextEditingController(
        text: ref.read(authProvider)?.phoneNumber.toString(),
      );
    });
  }

  void _editProfile() async {
    final isFormValid = _formKey.currentState!.validate();

    if (isFormValid) {
      try {
        setState(() {
          _isLoadingEditProfile = true;
          _error = null;
        });
        final response = await editProfile(
          _selectedCountryCode!.code,
          _fullNameController!.text,
          _phoneNumber!.text,
          _usernameController!.text,
        );

        final access = await storage.read(key: accessToken);
        final refresh = await storage.read(key: refreshToken);
        final expiryTime = await storage.read(key: expiresAt);

        ref.read(authProvider.notifier).setAuthData(
              AuthUser(
                userId: response['user']['userId'],
                countryCode: response['user']['countryCode'],
                email: response['user']['email'],
                fullName: response['user']['fullName'],
                phoneNumber: response['user']['phoneNumber'],
                profilePicture: response['user']['profilePicture'],
                username: response['user']['username'],
                followers: response['user']['followers'],
                following: response['user']['following'],
                accessToken: access!,
                expiresAt: expiryTime!,
                refreshToken: refresh!,
              ),
            );

        if (context.mounted) {
          Navigator.of(context).pop();
        }
        setState(() {
          _isLoadingEditProfile = false;
          _error = null;
        });
      } on DioException catch (e) {
        setState(() {
          _isLoadingEditProfile = false;
          _error = e.response?.data['data']['message'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authData = ref.watch(authProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(
        FocusNode(),
      ),
      child: FractionallySizedBox(
        heightFactor: 0.93,
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 0.2,
                    color: appColors.secondary,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          color: appColors.secondary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      'Edit Profile',
                      style: GoogleFonts.poppins(
                        color: appColors.secondary,
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                      onPressed: _editProfile,
                      child: _isLoadingEditProfile
                          ? const CupertinoActivityIndicator(
                              radius: 10,
                            )
                          : Text(
                              'Done',
                              style: GoogleFonts.poppins(
                                color: CupertinoColors.activeBlue,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      const SizedBox(
                        height: 15,
                      ),
                      CircleAvatar(
                        radius: 70,
                        backgroundImage: NetworkImage(
                          authData?.profilePicture ?? defaultProfileImage,
                        ),
                      ),
                      TextButton(
                        onPressed: widget.onEditProfilePictureTap,
                        child: Text(
                          'Edit profile picture',
                          style: GoogleFonts.poppins(
                            color: CupertinoColors.activeBlue,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: appColors.secondary,
                              width: 0.2,
                            ),
                            bottom: BorderSide(
                              color: appColors.secondary,
                              width: 0.2,
                            ),
                          ),
                        ),
                        child: Column(
                          children: <Widget>[
                            FormInput(
                              controller: _fullNameController,
                              label: 'Full name',
                            ),
                            FormInput(
                              controller: _usernameController,
                              label: 'Username',
                            ),
                            FormInput(
                              label: _selectedCountryCode?.code ?? '+961',
                              controller: _phoneNumber,
                              textInputType: TextInputType.number,
                              onLabelPress: () => showModalBottomSheet(
                                context: context,
                                builder: (ctx) =>
                                    CountryPickingBottomSheetContent(
                                  onTapCountry: (code) {
                                    setState(() {
                                      _selectedCountryCode = code;
                                    });
                                    Navigator.of(context).pop();
                                  },
                                  pickedCountry:
                                      _selectedCountryCode ?? countryCodes[0],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 50,
                              child: Center(
                                child: AnimatedOpacity(
                                  opacity: _error != null ? 1 : 0,
                                  duration: const Duration(
                                    milliseconds: 100,
                                  ),
                                  child: Text(
                                    _error ?? '',
                                    style: GoogleFonts.poppins(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onError
                                          .withRed(255),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
