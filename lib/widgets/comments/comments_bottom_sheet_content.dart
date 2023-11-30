import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_insta/classes/app_colors.dart';
import 'package:flutter_insta/classes/comment.dart';
import 'package:flutter_insta/classes/post.dart';
import 'package:flutter_insta/classes/user.dart';
import 'package:flutter_insta/constants/constants.dart';
import 'package:flutter_insta/dio/comments/delete_post_comment.dart';
import 'package:flutter_insta/dio/comments/get_post_comments.dart';
import 'package:flutter_insta/dio/comments/post_comment.dart';
import 'package:flutter_insta/providers/auth_provider.dart';
import 'package:flutter_insta/widgets/comments/comment_item.dart';
import 'package:flutter_insta/widgets/utils/bottom_modal_sheet_handle.dart';
import 'package:flutter_insta/widgets/utils/lists/error_indicator.dart';
import 'package:flutter_insta/widgets/utils/lists/list_progress_indicator.dart';
import 'package:flutter_insta/widgets/utils/lists/no_items_found_indicator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class CommentsBottomSheetContent extends ConsumerStatefulWidget {
  const CommentsBottomSheetContent({
    super.key,
    required this.postId,
  });

  final String? postId;

  @override
  ConsumerState<CommentsBottomSheetContent> createState() =>
      _CommentsBottomSheetContentState();
}

class _CommentsBottomSheetContentState
    extends ConsumerState<CommentsBottomSheetContent> {
  final PagingController<int, Comment> _pagingController =
      PagingController<int, Comment>(
    firstPageKey: 1,
  );
  final TextEditingController _commentTextController = TextEditingController();
  String _comment = '';

  @override
  void initState() {
    super.initState();

    _pagingController.addPageRequestListener(
      (pageKey) {
        _getPostComments(pageKey);
      },
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _commentTextController.dispose();

    super.dispose();
  }

  Future<void> _getPostComments(int page) async {
    try {
      final response = await getPostComments(widget.postId, page);

      List<Comment> updatedComments = [];

      response['comments']['docs'].forEach(
        (comment) => updatedComments.add(
          Comment(
            commentAlreadyLiked: comment['commentAlreadyLiked'],
            comment: comment['comment'],
            commentId: comment['commentId'],
            commentedAt: comment['commentedAt'],
            likesTotal: comment['likesTotal'],
            isEditted: comment['isEditted'],
            post: Post(
              postAlreadyLiked: comment['post']['postAlreadyLiked'],
              postId: comment['post']['postId'],
              post: PostData(
                post: comment['post']['post']['post'],
                caption: comment['post']['post']['comment'],
              ),
              commentsTotal: comment['post']['commentsTotal'],
              likesTotal: comment['post']['likesTotal'],
              user: User(
                userId: comment['post']['user']['userId'],
                email: comment['post']['user']['email'],
                countryCode: comment['post']['user']['countryCode'],
                fullName: comment['post']['user']['fullName'],
                phoneNumber: comment['post']['user']['phoneNumber'],
                username: comment['post']['user']['username'],
                followers: comment['post']['user']['followers'],
                following: comment['post']['user']['following'],
                profilePicture: comment['post']['user']['profilePicture'],
              ),
              postDate: comment['post']['postDate'],
            ),
            user: User(
              userId: comment['user']['userId'],
              email: comment['user']['email'],
              countryCode: comment['user']['countryCode'],
              fullName: comment['user']['fullName'],
              phoneNumber: comment['user']['phoneNumber'],
              username: comment['user']['username'],
              followers: comment['user']['followers'],
              following: comment['user']['following'],
              profilePicture: comment['user']['profilePicture'],
            ),
          ),
        ),
      );

      if (response['comments']['hasNextPage'] == false) {
        _pagingController.appendLastPage(updatedComments);
      } else {
        final nextPageKey = page + 1;
        _pagingController.appendPage(updatedComments, nextPageKey);
      }
    } on DioException catch (error) {
      if (context.mounted) _pagingController.error = error;
    }
  }

  Future<void> _postComment() async {
    if (_commentTextController.text == '') return;

    try {
      final String uploadedComment = _commentTextController.text;
      setState(() {
        _comment = '';
      });

      _commentTextController.clear();
      await postComment(
        widget.postId,
        uploadedComment,
      );

      _pagingController.refresh();
    } on DioException catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final authData = ref.read(authProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(
        FocusNode(),
      ),
      child: FractionallySizedBox(
        heightFactor: 0.75,
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 0.5,
                    color: appColors.secondary.withOpacity(
                      0.5,
                    ),
                  ),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  const BottomModalSheetHandle(),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: Text(
                      'Comments',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: appColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                child: PagedListView<int, Comment>(
                  pagingController: _pagingController,
                  builderDelegate: PagedChildBuilderDelegate(
                    noItemsFoundIndicatorBuilder: (context) =>
                        const NoItemsFoundIndicator(
                      isComments: true,
                    ),
                    firstPageErrorIndicatorBuilder: (context) =>
                        const ErrorIndicator(),
                    firstPageProgressIndicatorBuilder: (context) =>
                        const ListProgressIndicator(),
                    newPageErrorIndicatorBuilder: (context) =>
                        const ErrorIndicator(),
                    newPageProgressIndicatorBuilder: (context) =>
                        const ListProgressIndicator(),
                    itemBuilder: (context, item, index) => CommentItem(
                      canDeleteComment: item.user.userId == authData?.userId,
                      onSlideDeletePress: (context) async {
                        try {
                          await deletePostComment(item.commentId);

                          _pagingController.refresh();
                        } on DioException catch (_) {}
                      },
                      onSlideReplyPress: (context) {},
                      onAvatarPress: () {
                        context.push(
                          '/user/${item.user.userId}?username=${item.user.username}',
                        );
                        Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pop();
                      },
                      comment: item,
                      onLikesPress: () {
                        context.push('/likes?comment=${item.commentId}');
                        Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pop();
                      },
                    ),
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: appColors.secondary.withOpacity(
                      0.5,
                    ),
                    width: 0.5,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 15,
                  right: 15,
                  bottom: 30,
                  top: 15,
                ),
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                        authData?.profilePicture ?? defaultProfileImage,
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: TextField(
                        onChanged: (value) => setState(() {
                          _comment = value;
                        }),
                        controller: _commentTextController,
                        scrollPadding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        cursorColor: appColors.secondary.withOpacity(
                          0.5,
                        ),
                        style: GoogleFonts.poppins(
                          color: appColors.secondary,
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 15,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              40,
                            ),
                            borderSide: BorderSide(
                              color: appColors.secondary.withOpacity(
                                0.5,
                              ),
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              40,
                            ),
                            borderSide: BorderSide(
                              color: appColors.secondary.withOpacity(
                                0.5,
                              ),
                            ),
                          ),
                          hintText: 'Add a comment',
                          hintStyle: GoogleFonts.poppins(
                            color: appColors.secondary.withOpacity(
                              0.4,
                            ),
                            fontSize: 14,
                          ),
                          suffix: AnimatedOpacity(
                            opacity: _commentTextController.text == '' ? 0 : 1,
                            duration: const Duration(
                              milliseconds: 200,
                            ),
                            child: GestureDetector(
                              onTap: _postComment,
                              child: Text(
                                'Post',
                                style: GoogleFonts.poppins(
                                  color: CupertinoColors.activeBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
