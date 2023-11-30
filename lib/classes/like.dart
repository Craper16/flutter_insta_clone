import 'package:flutter_insta/classes/comment.dart';
import 'package:flutter_insta/classes/post.dart';
import 'package:flutter_insta/classes/user.dart';

class Like {
  final String likeId;
  final Post? post;
  final Comment? comment;
  final User user;
  final String likeDate;

  const Like({
    this.comment,
    required this.likeDate,
    required this.likeId,
    this.post,
    required this.user,
  });
}
