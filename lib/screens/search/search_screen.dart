import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_insta/classes/app_colors.dart';
import 'package:flutter_insta/classes/user.dart';
import 'package:flutter_insta/dio/search/search_users.dart';
import 'package:flutter_insta/widgets/inputs/search_text_field.dart';
import 'package:flutter_insta/widgets/users/user_list_tile_item.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  Timer? _debounceSearch;

  List<User> _usersSearched = [];
  bool _isLoadingSearchUsers = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _debounceSearch?.cancel();

    super.dispose();
  }

  Future<dynamic> _searchUsers(String searchQuery) async {
    setState(() {
      _isLoadingSearchUsers = true;
    });
    if (_debounceSearch?.isActive ?? false) _debounceSearch?.cancel();

    _debounceSearch = Timer(const Duration(milliseconds: 500), () async {
      try {
        final response = await searchUsers(searchQuery);

        List<User> usersReturned = [];

        response['users'].forEach((user) {
          usersReturned.add(
            User(
              userId: user['userId'],
              email: user['email'],
              countryCode: user['countryCode'],
              fullName: user['fullName'],
              phoneNumber: user['phoneNumber'],
              username: user['username'],
              profilePicture: user['profilePicture'],
              followers: user['followers'],
              following: user['following'],
            ),
          );
        });

        setState(() {
          _usersSearched = usersReturned;
          _isLoadingSearchUsers = false;
        });
      } on DioException catch (_) {
        setState(() {
          _isLoadingSearchUsers = false;
        });
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: appColors.secondary,
            content: SnackBar(
              content: Text(
                'Please check your internet connection',
                style: GoogleFonts.poppins(
                  color: appColors.primary,
                ),
              ),
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(
        FocusNode(),
      ),
      child: Scaffold(
        backgroundColor: appColors.primary,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: SearchTextField(
                  onChanged: (text) {
                    _searchQuery = text;
                    _searchUsers(text);
                  },
                ),
              ),
              Expanded(
                child: !_isLoadingSearchUsers &&
                        _searchQuery != '' &&
                        _usersSearched.isEmpty
                    ? Center(
                        child: Text(
                          'No results found for "$_searchQuery"',
                          style: GoogleFonts.poppins(
                            color: appColors.secondary,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : _isLoadingSearchUsers
                        ? Center(
                            child: defaultTargetPlatform == TargetPlatform.iOS
                                ? const CupertinoActivityIndicator(
                                    radius: 10,
                                  )
                                : const SizedBox(
                                    height: 40,
                                    width: 40,
                                    child: CircularProgressIndicator(),
                                  ),
                          )
                        : ListView.builder(
                            itemCount: _usersSearched.length,
                            itemBuilder: (ctx, index) => UserListTileItem(
                              onTap: () => ctx.push(
                                '/user/${_usersSearched[index].userId}?username=${_usersSearched[index].username}',
                              ),
                              user: _usersSearched[index],
                            ),
                          ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
