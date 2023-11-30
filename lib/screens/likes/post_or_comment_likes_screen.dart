import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_insta/classes/app_colors.dart';
import 'package:flutter_insta/classes/like.dart';
import 'package:flutter_insta/classes/user.dart';
import 'package:flutter_insta/dio/likes/get_post_or_comment_likes.dart';
import 'package:flutter_insta/widgets/users/user_list_tile_item.dart';
import 'package:flutter_insta/widgets/utils/lists/error_indicator.dart';
import 'package:flutter_insta/widgets/utils/lists/list_progress_indicator.dart';
import 'package:flutter_insta/widgets/utils/lists/no_items_found_indicator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PostOrCommentsScreen extends ConsumerStatefulWidget {
  const PostOrCommentsScreen({
    super.key,
    this.commentId,
    this.postId,
  });

  final String? postId;
  final String? commentId;

  @override
  ConsumerState<PostOrCommentsScreen> createState() =>
      _PostOrCommentsScreenState();
}

class _PostOrCommentsScreenState extends ConsumerState<PostOrCommentsScreen> {
  final PagingController<int, Like> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    super.initState();

    _pagingController.addPageRequestListener((pageKey) {
      _getPostOrCommentLikes(pageKey);
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();

    super.dispose();
  }

  Future<void> _getPostOrCommentLikes(
    int page,
  ) async {
    try {
      final response = await getPostOrCommentLikes(
        widget.postId,
        page,
        widget.commentId,
      );

      List<Like> updatedPosts = [];

      response['likes']['docs'].forEach(
        (like) {
          return updatedPosts.add(
            Like(
              likeDate: like['likeDate'],
              likeId: like['likeId'],
              user: User(
                userId: like['user']['userId'],
                email: like['user']['email'],
                countryCode: like['user']['countryCode'],
                fullName: like['user']['fullName'],
                phoneNumber: like['user']['phoneNumber'],
                username: like['user']['username'],
                followers: like['user']['followers'],
                following: like['user']['following'],
                profilePicture: like['user']['profilePicture'],
              ),
            ),
          );
        },
      );

      if (response['likes']['hasNextPage'] == false) {
        _pagingController.appendLastPage(updatedPosts);
      } else {
        final nextPageKey = page + 1;
        _pagingController.appendPage(updatedPosts, nextPageKey);
      }
    } on DioException catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Likes',
          style: GoogleFonts.poppins(
            color: appColors.secondary,
          ),
        ),
        backgroundColor: appColors.primary,
      ),
      backgroundColor: appColors.primary,
      body: CustomScrollView(
        slivers: [
          CupertinoSliverRefreshControl(
            onRefresh: () => Future.sync(
              () => _pagingController.refresh(),
            ),
          ),
          PagedSliverList(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<Like>(
              noItemsFoundIndicatorBuilder: (context) =>
                  const NoItemsFoundIndicator(),
              firstPageErrorIndicatorBuilder: (context) =>
                  const ErrorIndicator(),
              firstPageProgressIndicatorBuilder: (context) =>
                  const ListProgressIndicator(),
              newPageErrorIndicatorBuilder: (context) => const ErrorIndicator(),
              newPageProgressIndicatorBuilder: (context) =>
                  const ListProgressIndicator(),
              itemBuilder: (context, item, index) => UserListTileItem(
                onTap: () => context.push(
                    '/user/${item.user.userId}?username=${item.user.username}'),
                user: item.user,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
