import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_insta/classes/app_colors.dart';
import 'package:flutter_insta/classes/user.dart';
import 'package:flutter_insta/constants/tokens.dart';
import 'package:flutter_insta/dio/profile/remove_profile_picture.dart';
import 'package:flutter_insta/main.dart';
import 'package:flutter_insta/providers/auth_provider.dart';
import 'package:flutter_insta/widgets/utils/bottom_modal_sheet_handle.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfilePictureContent extends ConsumerStatefulWidget {
  const EditProfilePictureContent({
    super.key,
    required this.onTakeAPicturePress,
    required this.onUploadFromLibraryPress,
  });

  final void Function() onTakeAPicturePress;
  final void Function() onUploadFromLibraryPress;

  @override
  ConsumerState<EditProfilePictureContent> createState() =>
      _EditProfilePictureContentState();
}

class _EditProfilePictureContentState
    extends ConsumerState<EditProfilePictureContent> {
  bool _isLoadingRemoveProfilePicture = false;

  void _removeProfilePicture() async {
    try {
      setState(() {
        _isLoadingRemoveProfilePicture = true;
      });
      final response = await removeProfilePicture();

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
        _isLoadingRemoveProfilePicture = false;
      });
    } on DioException catch (e) {
      setState(() {
        _isLoadingRemoveProfilePicture = false;
      });
      print(e.response);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 15,
          ),
          const BottomModalSheetHandle(),
          const SizedBox(
            height: 15,
          ),
          TextButton(
            onPressed: widget.onTakeAPicturePress,
            child: Text(
              'Take a picture',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: appColors.secondary,
              ),
            ),
          ),
          TextButton(
            onPressed: widget.onUploadFromLibraryPress,
            child: Text(
              'Upload from library',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: appColors.secondary,
              ),
            ),
          ),
          TextButton(
            onPressed: _removeProfilePicture,
            child: _isLoadingRemoveProfilePicture
                ? const CupertinoActivityIndicator(
                    radius: 15,
                  )
                : Text(
                    'Remove profile picture',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: appColors.secondary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
