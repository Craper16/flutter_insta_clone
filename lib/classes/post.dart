import 'package:flutter_insta/classes/user.dart';

class PostData {
  final List<dynamic> post;
  final String? caption;

  const PostData({
    this.caption,
    required this.post,
  });
}

class Post {
  final String postId;
  final PostData post;
  final User user;
  final String postDate;
  final int commentsTotal;
  final int likesTotal;
  final bool postAlreadyLiked;

  const Post({
    required this.postId,
    required this.post,
    required this.user,
    required this.postDate,
    required this.commentsTotal,
    required this.likesTotal,
    required this.postAlreadyLiked,
  });
}
