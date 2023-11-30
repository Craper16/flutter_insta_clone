import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_insta/classes/app_colors.dart';
import 'package:flutter_insta/classes/comment.dart';
import 'package:flutter_insta/constants/constants.dart';
import 'package:flutter_insta/dio/likes/post_like.dart';
import 'package:flutter_insta/dio/likes/remove_like.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';

class CommentItem extends StatefulWidget {
  const CommentItem({
    super.key,
    required this.comment,
    required this.onAvatarPress,
    required this.onSlideDeletePress,
    required this.onSlideReplyPress,
    required this.canDeleteComment,
    required this.onLikesPress,
  });

  final Comment comment;
  final void Function() onAvatarPress;
  final void Function(BuildContext context) onSlideDeletePress;
  final void Function(BuildContext context) onSlideReplyPress;
  final bool canDeleteComment;
  final void Function() onLikesPress;

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  int _totalLikes = 0;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      _isLiked = widget.comment.commentAlreadyLiked;
      _totalLikes = widget.comment.likesTotal;
    });
  }

  void _onHeartPress() {
    if (!_isLiked) {
      try {
        postLike(null, widget.comment.commentId);
      } on DioException catch (_) {}
    } else {
      try {
        removeLike(null, widget.comment.commentId, null);
      } on DioException catch (_) {}
    }
    setState(() {
      _totalLikes = _isLiked ? _totalLikes - 1 : _totalLikes + 1;
      _isLiked = !_isLiked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          if (widget.canDeleteComment)
            SlidableAction(
              autoClose: true,
              icon: CupertinoIcons.delete,
              onPressed: widget.onSlideDeletePress,
              backgroundColor: CupertinoColors.darkBackgroundGray,
              foregroundColor: appColors.secondary,
            ),
          SlidableAction(
            autoClose: true,
            icon: CupertinoIcons.arrow_turn_up_left,
            onPressed: widget.onSlideReplyPress,
            backgroundColor: CupertinoColors.darkBackgroundGray,
            foregroundColor: appColors.secondary,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 10,
        ),
        child: Row(
          children: <Widget>[
            GestureDetector(
              onTap: widget.onAvatarPress,
              child: CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  widget.comment.user.profilePicture ?? defaultProfileImage,
                ),
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      widget.comment.user.username,
                      style: GoogleFonts.poppins(
                        color: appColors.secondary,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      widget.comment.commentedAt,
                      style: GoogleFonts.poppins(
                        color: appColors.secondary.withOpacity(
                          0.5,
                        ),
                      ),
                    )
                  ],
                ),
                Text(
                  widget.comment.comment,
                  style: GoogleFonts.poppins(
                    color: appColors.secondary.withOpacity(
                      0.8,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: widget.onLikesPress,
                      child: Text(
                        '$_totalLikes likes',
                        style: GoogleFonts.poppins(
                          color: appColors.secondary.withOpacity(
                            0.5,
                          ),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Text(
                      'Reply',
                      style: GoogleFonts.poppins(
                        color: appColors.secondary.withOpacity(
                          0.5,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: _onHeartPress,
              child: Icon(
                _isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                color: _isLiked
                    ? CupertinoColors.systemRed
                    : appColors.secondary.withOpacity(
                        0.5,
                      ),
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
