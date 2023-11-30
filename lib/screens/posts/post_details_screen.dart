import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_insta/classes/app_colors.dart';
import 'package:flutter_insta/classes/post.dart';
import 'package:flutter_insta/classes/user.dart';
import 'package:flutter_insta/dio/posts/get_post.dart';
import 'package:flutter_insta/widgets/posts/post_item.dart';
import 'package:flutter_insta/widgets/utils/lists/error_indicator.dart';
import 'package:flutter_insta/widgets/utils/lists/list_progress_indicator.dart';
import 'package:google_fonts/google_fonts.dart';

class PostDetailsScreen extends StatefulWidget {
  const PostDetailsScreen({
    super.key,
    required this.postId,
    required this.userFullName,
  });

  final String? postId;
  final String? userFullName;

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen>
    with TickerProviderStateMixin {
  late Future<dynamic> _getPostDetailsFuture;

  @override
  void initState() {
    super.initState();

    _getPostDetailsFuture = _getPostDetails();
  }

  Future<dynamic> _getPostDetails() async {
    final response = await getPost(widget.postId);

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColors.primary,
      appBar: AppBar(
        backgroundColor: appColors.primary,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Column(
          children: <Widget>[
            Text(
              widget.userFullName ?? '',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: appColors.secondary.withOpacity(0.5),
              ),
            ),
            Text(
              'POST',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: appColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder(
        future: _getPostDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: ListProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: ErrorIndicator(),
            );
          }

          return CustomScrollView(
            slivers: [
              CupertinoSliverRefreshControl(
                onRefresh: () {
                  setState(() {
                    _getPostDetailsFuture = _getPostDetails();
                  });
                  return _getPostDetails();
                },
              ),
              SliverToBoxAdapter(
                child: PostItem(
                  post: Post(
                    postId: snapshot.data['post']['postId'],
                    post: PostData(
                      post: snapshot.data['post']['post']['post'],
                      caption: snapshot.data['post']['post']['caption'],
                    ),
                    user: User(
                      userId: snapshot.data['post']['user']['userId'],
                      email: snapshot.data['post']['user']['email'],
                      countryCode: snapshot.data['post']['user']['countryCode'],
                      fullName: snapshot.data['post']['user']['fullName'],
                      phoneNumber: snapshot.data['post']['user']['phoneNumber'],
                      username: snapshot.data['post']['user']['username'],
                      followers: snapshot.data['post']['user']['followers'],
                      following: snapshot.data['post']['user']['following'],
                      profilePicture: snapshot.data['post']['user']
                          ['profilePicture'],
                    ),
                    postDate: snapshot.data['post']['postDate'],
                    commentsTotal: snapshot.data['post']['commentsTotal'],
                    likesTotal: snapshot.data['post']['likesTotal'],
                    postAlreadyLiked: snapshot.data['post']['postAlreadyLiked'],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
