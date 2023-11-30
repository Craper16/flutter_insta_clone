import 'package:flutter/cupertino.dart';
import 'package:flutter_insta/classes/app_colors.dart';
import 'package:flutter_insta/classes/post.dart';

class PostListItem extends StatefulWidget {
  const PostListItem({
    super.key,
    required this.post,
    this.onPostPress,
  });

  final Post post;
  final void Function()? onPostPress;

  @override
  State<PostListItem> createState() => _PostListItemState();
}

class _PostListItemState extends State<PostListItem> {
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.all(0),
      onPressed: widget.onPostPress,
      child: Container(
        decoration: BoxDecoration(
          border: Border.symmetric(
            horizontal: BorderSide(
              width: 2,
              color: appColors.primary,
            ),
            vertical: BorderSide(
              width: 2,
              color: appColors.primary,
            ),
          ),
          image: DecorationImage(
            fit: BoxFit.cover,
            image: NetworkImage(
              widget.post.post.post[0],
            ),
          ),
        ),
      ),
    );
  }
}
