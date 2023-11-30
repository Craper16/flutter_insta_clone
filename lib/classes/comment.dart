import 'package:flutter_insta/classes/post.dart';
import 'package:flutter_insta/classes/user.dart';

class Comment {
  final String commentId;
  final String comment;
  final bool isEditted;
  final User user;
  final Post post;
  final String commentedAt;
  final int likesTotal;
  final bool commentAlreadyLiked;

  const Comment({
    required this.commentId,
    required this.comment,
    required this.commentedAt,
    required this.likesTotal,
    required this.isEditted,
    required this.post,
    required this.user,
    required this.commentAlreadyLiked,
  });
}
