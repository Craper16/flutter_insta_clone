import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_insta/classes/app_colors.dart';
import 'package:flutter_insta/classes/user.dart';
import 'package:flutter_insta/constants/tokens.dart';
import 'package:flutter_insta/dio/users/follow_user.dart';
import 'package:flutter_insta/dio/users/unfollow_user.dart';
import 'package:flutter_insta/main.dart';
import 'package:flutter_insta/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class UserListTileItem extends ConsumerStatefulWidget {
  const UserListTileItem({
    super.key,
    this.onTap,
    required this.user,
  });

  final void Function()? onTap;
  final User user;

  @override
  ConsumerState<UserListTileItem> createState() => _UserListTileItemState();
}

class _UserListTileItemState extends ConsumerState<UserListTileItem> {
  late User _user;

  @override
  void initState() {
    super.initState();

    _user = widget.user;
  }

  void _followOrUnfollowUser(String userId) async {
    try {
      if (_user.followers.contains(ref.read(authProvider)!.userId)) {
        setState(() {
          _user = User(
            userId: _user.userId,
            email: _user.email,
            countryCode: _user.countryCode,
            fullName: _user.fullName,
            phoneNumber: _user.phoneNumber,
            username: _user.username,
            followers: _user.followers
                .where((follower) => follower != ref.read(authProvider)!.userId)
                .toList(),
            profilePicture: _user.profilePicture,
            following: _user.following,
          );
        });

        final response = await unfollowUser(userId);

        final access = await storage.read(key: accessToken);
        final refresh = await storage.read(key: refreshToken);
        final expiryTime = await storage.read(key: expiresAt);

        return ref.read(authProvider.notifier).setAuthData(
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
      }

      setState(() {
        _user = User(
          userId: _user.userId,
          email: _user.email,
          countryCode: _user.countryCode,
          fullName: _user.fullName,
          phoneNumber: _user.phoneNumber,
          username: _user.username,
          followers: [
            ..._user.followers,
            ref.read(authProvider)!.userId,
          ],
          profilePicture: _user.profilePicture,
          following: _user.following,
        );
      });
      final response = await followUser(userId);

      final access = await storage.read(key: accessToken);
      final refresh = await storage.read(key: refreshToken);
      final expiryTime = await storage.read(key: expiresAt);

      return ref.read(authProvider.notifier).setAuthData(
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
    } on DioException catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please check your internet connection',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authData = ref.watch(authProvider);

    bool userAlreadyFollowed = authData!.following.contains(
      widget.user.userId,
    );

    return CupertinoListTile(
      padding: const EdgeInsets.all(12),
      leadingSize: 50,
      onTap: widget.onTap,
      trailing: GestureDetector(
        onTap: () => _followOrUnfollowUser(_user.userId),
        child: _user.userId == authData.userId
            ? Text(
                'You',
                style: GoogleFonts.poppins(
                  color: appColors.secondary,
                  fontSize: 14,
                ),
              )
            : Container(
                alignment: Alignment.center,
                width: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: userAlreadyFollowed
                      ? appColors.secondary.withOpacity(
                          0.1,
                        )
                      : appColors.accent,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 3,
                    horizontal: 25,
                  ),
                  child: Text(
                    userAlreadyFollowed ? 'Unfollow' : 'Follow',
                    style: GoogleFonts.poppins(
                      color: appColors.secondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
      ),
      leading: CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(
          widget.user.profilePicture ??
              'https://upload.wikimedia.org/wikipedia/commons/a/ac/Default_pfp.jpg',
        ),
      ),
      title: Text(
        widget.user.username,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: appColors.secondary,
        ),
      ),
      leadingToTitle: 15,
      subtitle: Text(
        widget.user.fullName,
        style: GoogleFonts.poppins(
          color: appColors.secondary,
          fontSize: 12,
        ),
      ),
    );
  }
}
