import 'package:flutter/material.dart';
import 'package:flutter_insta/classes/app_colors.dart';
import 'package:flutter_insta/constants/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileImageAndFollowers extends StatelessWidget {
  const ProfileImageAndFollowers({
    super.key,
    this.profilePicture,
    this.showProfilePictureEditButton = false,
    this.onEditProfilePictureTap,
    this.followers,
    this.following,
    this.onFollowersPress,
    this.onFollowingPress,
  });

  final String? profilePicture;
  final bool showProfilePictureEditButton;
  final void Function()? onEditProfilePictureTap;
  final void Function()? onFollowingPress;
  final void Function()? onFollowersPress;
  final String? followers;
  final String? following;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: <Widget>[
          Stack(
            children: <Widget>[
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(
                  profilePicture ?? defaultProfileImage,
                ),
              ),
              if (showProfilePictureEditButton)
                Positioned(
                  top: 50,
                  left: 50,
                  child: InkWell(
                    onTap: onEditProfilePictureTap,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: appColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: appColors.secondary,
                        ),
                      ),
                      child: Icon(
                        Icons.edit,
                        size: 15,
                        color: appColors.secondary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(
            width: 15,
          ),
          const SizedBox(
            height: 10,
          ),
          const Spacer(),
          GestureDetector(
            onTap: onFollowingPress,
            child: Column(
              children: <Widget>[
                Text(
                  following ?? '0',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Following',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          GestureDetector(
            onTap: onFollowersPress,
            child: Column(
              children: <Widget>[
                Text(
                  followers ?? '0',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Followers',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
