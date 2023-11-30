import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_insta/classes/app_colors.dart';
import 'package:flutter_insta/classes/post.dart';
import 'package:flutter_insta/constants/constants.dart';
import 'package:flutter_insta/dio/likes/post_like.dart';
import 'package:flutter_insta/dio/likes/remove_like.dart';
import 'package:flutter_insta/widgets/comments/comments_bottom_sheet_content.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class PostItem extends StatefulWidget {
  const PostItem({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> with TickerProviderStateMixin {
  late AnimationController _heartAnimationController;

  final PageController _pageController = PageController();
  double _currentPage = 0;

  bool _showHeartIcon = false;
  Offset _heartIconPosition = const Offset(0, 0);
  bool _isLiked = false;
  int _totalLikes = 0;

  @override
  void initState() {
    super.initState();

    setState(() {
      _isLiked = widget.post.postAlreadyLiked;
      _totalLikes = widget.post.likesTotal;
    });

    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? _currentPage;
      });
    });
    _heartAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 300,
      ),
    );
    _heartAnimationController.repeat(
      reverse: true,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _heartAnimationController.dispose();

    super.dispose();
  }

  void _onHeartPress(String? postId) async {
    if (!_isLiked) {
      try {
        postLike(postId, null);
      } on DioException catch (_) {}
    } else {
      try {
        removeLike(postId, null, null);
      } catch (_) {}
    }
    setState(() {
      _totalLikes = _isLiked ? _totalLikes - 1 : _totalLikes + 1;
      _isLiked = !_isLiked;
    });
  }

  void _onPicturesDoubleTap(String? postId, Offset heartPosition) async {
    HapticFeedback.heavyImpact();

    try {
      postLike(postId, null);
    } on DioException catch (_) {}

    setState(() {
      _totalLikes = _isLiked ? _totalLikes : _totalLikes + 1;
      _isLiked = true;
      _heartIconPosition = heartPosition;
      _showHeartIcon = true;
    });
    Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _showHeartIcon = false;
      });
    });
  }

  void _openComments() {
    showModalBottomSheet(
      useRootNavigator: true,
      isScrollControlled: true,
      context: context,
      backgroundColor: appColors.primary.withOpacity(1),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: CommentsBottomSheetContent(
          postId: widget.post.postId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 1.3,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(
                    widget.post.user.profilePicture ?? defaultProfileImage,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push(
                      '/user/${widget.post.user.userId}?username=${widget.post.user.username}'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      widget.post.user.fullName,
                      style: GoogleFonts.poppins(
                        color: appColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.horizontal,
              itemCount: widget.post.post.post.length,
              itemBuilder: (context, index) => GestureDetector(
                onDoubleTapDown: (details) => _onPicturesDoubleTap(
                  widget.post.postId,
                  details.localPosition,
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          alignment: Alignment.center,
                          image: NetworkImage(
                            widget.post.post.post[index],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: _heartIconPosition.dy,
                      left: _heartIconPosition.dx,
                      child: AnimatedOpacity(
                        duration: const Duration(
                          milliseconds: 200,
                        ),
                        opacity: _showHeartIcon ? 1 : 0,
                        child: ScaleTransition(
                          scale: Tween(begin: 0.2, end: 1.0).animate(
                            CurvedAnimation(
                              parent: _heartAnimationController,
                              curve: Curves.elasticOut,
                            ),
                          ),
                          child: const Icon(
                            CupertinoIcons.heart_fill,
                            size: 120,
                            color: CupertinoColors.systemRed,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 5,
            ),
            child: Stack(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CupertinoButton(
                      onPressed: () => _onHeartPress(
                        widget.post.postId,
                      ),
                      padding: const EdgeInsets.all(0),
                      child: Icon(
                        _isLiked
                            ? CupertinoIcons.heart_fill
                            : CupertinoIcons.heart,
                        size: 30,
                        color: _isLiked
                            ? CupertinoColors.systemRed
                            : appColors.secondary,
                      ),
                    ),
                    CupertinoButton(
                      onPressed: _openComments,
                      padding: const EdgeInsets.all(0),
                      child: Icon(
                        CupertinoIcons.chat_bubble,
                        size: 30,
                        color: appColors.secondary,
                      ),
                    ),
                    CupertinoButton(
                      onPressed: () {},
                      padding: const EdgeInsets.all(0),
                      child: Icon(
                        CupertinoIcons.paperplane,
                        size: 30,
                        color: appColors.secondary,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width / 2.1,
                  top: 15,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ...widget.post.post.post.map(
                        (post) {
                          final index = widget.post.post.post.indexOf(post);

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2,
                            ),
                            child: Container(
                              height: 8,
                              width: 8,
                              decoration: BoxDecoration(
                                border: widget.post.post.post.length == 1
                                    ? null
                                    : Border.all(
                                        width: 0.5,
                                        color: appColors.secondary
                                            .withOpacity(0.5),
                                      ),
                                borderRadius: BorderRadius.circular(100),
                                color: _currentPage.round() == index
                                    ? widget.post.post.post.length == 1
                                        ? appColors.primary
                                        : CupertinoColors.activeBlue
                                    : Colors.transparent,
                              ),
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: CupertinoButton(
                    padding: const EdgeInsets.all(0),
                    child: Icon(
                      CupertinoIcons.star,
                      size: 30,
                      color: appColors.secondary,
                    ),
                    onPressed: () {},
                  ),
                )
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.push('/likes?post=${widget.post.postId}'),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                child: Text(
                  '$_totalLikes likes',
                  style: GoogleFonts.poppins(
                    color: appColors.secondary,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () => context.push(
                      '/user/${widget.post.user.userId}?username=${widget.post.user.fullName}',
                    ),
                    child: Text(
                      '${widget.post.user.fullName} ',
                      style: GoogleFonts.poppins(
                        color: appColors.secondary,
                      ),
                    ),
                  ),
                  if (widget.post.post.caption != null)
                    Text(
                      '${widget.post.post.caption}',
                      style: GoogleFonts.poppins(
                        color: appColors.secondary,
                      ),
                    )
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 15,
                top: 15,
              ),
              child: GestureDetector(
                onTap: _openComments,
                child: Text(
                  widget.post.commentsTotal == 0
                      ? 'View all comments'
                      : 'View all ${widget.post.commentsTotal} comments',
                  style: GoogleFonts.poppins(
                    color: appColors.secondary.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: Text(
                widget.post.postDate,
                style: GoogleFonts.poppins(
                  color: appColors.secondary.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
