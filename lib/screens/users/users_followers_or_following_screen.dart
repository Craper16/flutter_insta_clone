import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_insta/classes/app_colors.dart';
import 'package:flutter_insta/classes/user.dart';
import 'package:flutter_insta/dio/users/get_user_followers.dart';
import 'package:flutter_insta/dio/users/get_user_following.dart';
import 'package:flutter_insta/widgets/users/user_list_tile_item.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class UsersFollowersOrFollowingScreen extends StatefulWidget {
  const UsersFollowersOrFollowingScreen({
    super.key,
    required this.userId,
    required this.type,
  });

  final String? userId;
  final String? type;

  @override
  State<UsersFollowersOrFollowingScreen> createState() =>
      _UsersFollowersOrFollowingScreenState();
}

class _UsersFollowersOrFollowingScreenState
    extends State<UsersFollowersOrFollowingScreen> {
  late Future<void> _userFollowersFuture;
  List<User> _users = [];

  @override
  void initState() {
    super.initState();

    _userFollowersFuture = _getUserData();
  }

  Future<dynamic> _getUserData() async {
    try {
      if (widget.type == 'followers') {
        final response = await getUserFollowers(widget.userId!);

        List<User> updatedUsers = [];
        response['followers'].forEach((user) {
          updatedUsers.add(
            User(
              userId: user['userId'],
              email: user['email'],
              countryCode: user['countryCode'],
              fullName: user['fullName'],
              phoneNumber: user['phoneNumber'],
              username: user['username'],
              followers: user['followers'],
              following: user['following'],
              profilePicture: user['profilePicture'],
            ),
          );
        });

        setState(() {
          _users = updatedUsers;
        });

        return response['followers'];
      } else if (widget.type == 'following') {
        final response = await getUserFollowing(widget.userId!);

        List<User> updatedUsers = [];
        response['following'].forEach((user) {
          updatedUsers.add(
            User(
              userId: user['userId'],
              email: user['email'],
              countryCode: user['countryCode'],
              fullName: user['fullName'],
              phoneNumber: user['phoneNumber'],
              username: user['username'],
              followers: user['followers'],
              following: user['following'],
              profilePicture: user['profilePicture'],
            ),
          );
        });

        setState(() {
          _users = updatedUsers;
        });

        return response['following'];
      }
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${e.response?.data?.data.message}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColors.primary,
      appBar: AppBar(
        backgroundColor: appColors.primary,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 22,
          color: appColors.secondary,
        ),
        title: Text(
          widget.type == 'followers' ? 'Followers' : 'Following',
        ),
      ),
      body: FutureBuilder(
        future: _userFollowersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: defaultTargetPlatform == TargetPlatform.iOS
                  ? CupertinoActivityIndicator(
                      color: appColors.secondary,
                    )
                  : SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: appColors.secondary,
                      ),
                    ),
            );
          }

          if (snapshot.hasData && _users.isEmpty) {
            return Center(
              child: Text(
                widget.type == 'following'
                    ? 'You don\' follow any users yet'
                    : 'No users found',
                style: GoogleFonts.poppins(
                  color: appColors.secondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            );
          }

          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) => UserListTileItem(
                user: _users[index],
                onTap: () => context.push(
                  '/user/${_users[index].userId}?username=${_users[index].username}',
                ),
              ),
            );
          }

          return Center(
            child: Text(
              'Please check your network connection',
              style: GoogleFonts.poppins(
                color: appColors.secondary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          );
        },
      ),
    );
  }
}
