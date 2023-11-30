import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_insta/classes/app_colors.dart';
import 'package:flutter_insta/classes/user.dart';
import 'package:flutter_insta/constants/tokens.dart';
import 'package:flutter_insta/dio/profile/edit_profile_picture.dart';
import 'package:flutter_insta/main.dart';
import 'package:flutter_insta/providers/auth_provider.dart';
import 'package:flutter_insta/widgets/utils/custom_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http_parser/http_parser.dart';

class SaveProfilePictureDialogContent extends ConsumerStatefulWidget {
  const SaveProfilePictureDialogContent({
    super.key,
    this.selectedProfileImage,
    required this.onRepickTap,
    required this.onRetakeTap,
  });

  final File? selectedProfileImage;
  final void Function() onRetakeTap;
  final void Function() onRepickTap;

  @override
  ConsumerState<SaveProfilePictureDialogContent> createState() =>
      _SaveProfilePictureDialogContentState();
}

class _SaveProfilePictureDialogContentState
    extends ConsumerState<SaveProfilePictureDialogContent> {
  bool _isLoadingEditProfilePicture = false;

  void _editProfilePictureRequest() async {
    try {
      FormData profilePictureData = FormData.fromMap(
        {
          'profilePicture': await MultipartFile.fromFile(
            widget.selectedProfileImage!.path,
            filename: widget.selectedProfileImage!.path.split('/').last,
            contentType: MediaType('image', 'jpeg'),
          )
        },
      );
      setState(() {
        _isLoadingEditProfilePicture = true;
      });
      final response = await editProfilePicture(profilePictureData);

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
        _isLoadingEditProfilePicture = false;
      });
    } on DioException catch (e) {
      setState(() {
        _isLoadingEditProfilePicture = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.response!.data['data']['message'],
            style: GoogleFonts.poppins(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            20,
          ),
          color: Colors.white,
        ),
        child: Material(
          borderRadius: BorderRadius.circular(25),
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: appColors.primary,
              borderRadius: BorderRadius.circular(
                20,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(
                  height: 15,
                ),
                Text(
                  'Save image',
                  style: GoogleFonts.poppins(
                    color: appColors.secondary,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                CircleAvatar(
                  radius: 150,
                  backgroundImage: FileImage(
                    widget.selectedProfileImage!,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 50,
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: widget.onRetakeTap,
                        child: Text(
                          'Retake',
                          style: GoogleFonts.poppins(
                            color: appColors.secondary,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: widget.onRepickTap,
                        child: Text(
                          'Repick',
                          style: GoogleFonts.poppins(
                            color: appColors.secondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 50,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                CustomButton(
                  onPress: _editProfilePictureRequest,
                  title: 'Save',
                  width: 200,
                  isLoading: _isLoadingEditProfilePicture,
                  backgroundColor: appColors.primary.withOpacity(0.8),
                  foregroundColor: appColors.secondary,
                ),
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
