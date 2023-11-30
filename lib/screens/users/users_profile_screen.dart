import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_insta/classes/app_colors.dart';
import 'package:flutter_insta/classes/post.dart';
import 'package:flutter_insta/classes/user.dart';
import 'package:flutter_insta/constants/tokens.dart';
import 'package:flutter_insta/dio/users/follow_user.dart';
import 'package:flutter_insta/dio/users/get_user_posts.dart';
import 'package:flutter_insta/dio/users/get_user_profile_data.dart';
import 'package:flutter_insta/dio/users/unfollow_user.dart';
import 'package:flutter_insta/main.dart';
import 'package:flutter_insta/providers/auth_provider.dart';
import 'package:flutter_insta/widgets/posts/post_list_item.dart';
import 'package:flutter_insta/widgets/profile/edit_profile_picture_modal_content.dart';
import 'package:flutter_insta/widgets/profile/edit_user_profile_modal_content.dart';
import 'package:flutter_insta/widgets/profile/profile_image_and_followers.dart';
import 'package:flutter_insta/widgets/profile/profile_main_button_and_share.dart';
import 'package:flutter_insta/widgets/profile/save_profile_picture_dialog_content.dart';
import 'package:flutter_insta/widgets/profile/username_and_fullname.dart';
import 'package:flutter_insta/widgets/utils/custom_button.dart';
import 'package:flutter_insta/widgets/utils/lists/error_indicator.dart';
import 'package:flutter_insta/widgets/utils/lists/list_progress_indicator.dart';
import 'package:flutter_insta/widgets/utils/lists/no_items_found_indicator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class UsersProfileScreen extends ConsumerStatefulWidget {
  const UsersProfileScreen({
    super.key,
    required this.username,
    required this.userId,
  });

  final String username;
  final String userId;

  @override
  ConsumerState<UsersProfileScreen> createState() => _UsersProfileScreenState();
}

class _UsersProfileScreenState extends ConsumerState<UsersProfileScreen> {
  final ScrollController _scrollController = ScrollController();

  final PagingController<int, Post> _pagingController =
      PagingController<int, Post>(
    firstPageKey: 0,
  );

  User? _user;
  final ImagePicker picker = ImagePicker();
  File? _selectedProfileImage;
  double _titleOpacity = 0;

  @override
  void initState() {
    super.initState();

    _getUserProfileData();

    _scrollController.addListener(() {
      if (_scrollController.offset > 114) {
        return setState(() {
          _titleOpacity = 1;
        });
      }

      return setState(() {
        _titleOpacity = 0;
      });
    });
    _pagingController.addPageRequestListener((pageKey) {
      _getUserPosts(pageKey);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pagingController.dispose();

    super.dispose();
  }

  Future<void> _getUserPosts(int page) async {
    try {
      final response = await getUserPosts(
        widget.userId,
        page,
      );

      List<Post> updatedPosts = [];

      response['posts']['docs'].forEach(
        (post) => updatedPosts.add(
          Post(
            postAlreadyLiked: post['postAlreadyLiked'],
            postId: post['postId'],
            post: PostData(
              post: post['post']['post'],
              caption: post['post']['caption'],
            ),
            commentsTotal: post['commentsTotal'],
            likesTotal: post['likesTotal'],
            user: User(
              userId: post['user']['userId'],
              email: post['user']['email'],
              countryCode: post['user']['countryCode'],
              fullName: post['user']['fullName'],
              phoneNumber: post['user']['phoneNumber'],
              username: post['user']['username'],
              followers: post['user']['followers'],
              following: post['user']['following'],
            ),
            postDate: post['postDate'],
          ),
        ),
      );

      if (response['posts']['hasNextPage'] == false) {
        _pagingController.appendLastPage(updatedPosts);
      } else {
        final nextPageKey = page + 1;
        _pagingController.appendPage(updatedPosts, nextPageKey);
      }
    } catch (error) {
      if (context.mounted) _pagingController.error = error;
    }
  }

  void _getUserProfileData() async {
    try {
      final response = await getUserProfileData(widget.userId);

      setState(() {
        _user = User(
          userId: response['user']['userId'],
          email: response['user']['email'],
          countryCode: response['user']['countryCode'],
          fullName: response['user']['fullName'],
          phoneNumber: response['user']['phoneNumber'],
          username: response['user']['username'],
          profilePicture: response['user']['profilePicture'],
          followers: response['user']['followers'],
          following: response['user']['following'],
        );
      });
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please check your internet connection',
          ),
        ),
      );
    }
  }

  void _followOrUnfollowUser(String userId) async {
    try {
      if (_user!.followers.contains(ref.read(authProvider)!.userId)) {
        setState(() {
          _user = User(
            userId: _user!.userId,
            email: _user!.email,
            countryCode: _user!.countryCode,
            fullName: _user!.fullName,
            phoneNumber: _user!.phoneNumber,
            username: _user!.username,
            followers: _user!.followers
                .where((follower) => follower != ref.read(authProvider)!.userId)
                .toList(),
            profilePicture: _user?.profilePicture,
            following: _user!.following,
          );
        });

        final response = await unfollowUser(userId);

        final access = await storage.read(key: accessToken);
        final refresh = await storage.read(key: refreshToken);
        final expiryTime = await storage.read(key: expiresAt);

        return ref.read(authProvider.notifier).setAuthData(
              AuthUser(
                userId: response['user']['userId'],
                countryCode: response['user']['countryCode'],
                email: response['user']['email'],
                fullName: response['user']['fullName'],
                phoneNumber: response['user']['phoneNumber'],
                profilePicture: response['user']['profilePicture'],
                username: response['user']['username'],
                followers: response['user']['followers'],
                following: response['user']['following'],
                accessToken: access!,
                expiresAt: expiryTime!,
                refreshToken: refresh!,
              ),
            );
      }

      setState(() {
        _user = User(
          userId: _user!.userId,
          email: _user!.email,
          countryCode: _user!.countryCode,
          fullName: _user!.fullName,
          phoneNumber: _user!.phoneNumber,
          username: _user!.username,
          followers: [
            ..._user!.followers,
            ref.read(authProvider)!.userId,
          ],
          profilePicture: _user?.profilePicture,
          following: _user!.following,
        );
      });
      final response = await followUser(userId);

      final access = await storage.read(key: accessToken);
      final refresh = await storage.read(key: refreshToken);
      final expiryTime = await storage.read(key: expiresAt);

      return ref.read(authProvider.notifier).setAuthData(
            AuthUser(
              userId: response['user']['userId'],
              countryCode: response['user']['countryCode'],
              email: response['user']['email'],
              fullName: response['user']['fullName'],
              phoneNumber: response['user']['phoneNumber'],
              profilePicture: response['user']['profilePicture'],
              username: response['user']['username'],
              followers: response['user']['followers'],
              following: response['user']['following'],
              accessToken: access!,
              expiresAt: expiryTime!,
              refreshToken: refresh!,
            ),
          );
    } on DioException catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please check your internet connection',
            ),
          ),
        );
      }
    }
  }

  void _pickImage(ImageSource source) async {
    Navigator.of(context, rootNavigator: true).pop();
    try {
      final XFile? image = await picker.pickImage(
        source: source,
      );

      _selectedProfileImage = File(image!.path);

      _openSaveImageCenterDialog();
    } catch (error) {
      // error happening
    }
  }

  void _onEditProfilePictureTap() {
    showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      enableDrag: true,
      builder: (ctx) => EditProfilePictureContent(
        onTakeAPicturePress: () => _pickImage(
          ImageSource.camera,
        ),
        onUploadFromLibraryPress: () => _pickImage(
          ImageSource.gallery,
        ),
      ),
    );
  }

  void _openSaveImageCenterDialog() {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black38,
      barrierLabel: 'Label',
      barrierDismissible: true,
      pageBuilder: (_, __, ____) => SaveProfilePictureDialogContent(
        selectedProfileImage: _selectedProfileImage!,
        onRepickTap: () {
          _pickImage(ImageSource.gallery);
        },
        onRetakeTap: () {
          _pickImage(ImageSource.camera);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authData = ref.watch(authProvider);

    final isUserAlreadyFollowing = _user?.followers.contains(authData?.userId);
    final isUserLoggedInuser = authData?.userId == _user?.userId;

    return Scaffold(
      backgroundColor: appColors.primary,
      appBar: AppBar(
        backgroundColor: appColors.primary,
        centerTitle: true,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: AnimatedOpacity(
          opacity: _titleOpacity,
          duration: const Duration(
            milliseconds: 150,
          ),
          child: Text(
            widget.username,
            style: GoogleFonts.poppins(
              color: appColors.secondary,
              fontSize: 22,
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        controller: _scrollController,
        slivers: [
          CupertinoSliverRefreshControl(
            onRefresh: () => Future.sync(
              () => _pagingController.refresh(),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              childCount: 1,
              (context, index) => Column(
                children: <Widget>[
                  ProfileImageAndFollowers(
                    onEditProfilePictureTap: _onEditProfilePictureTap,
                    showProfilePictureEditButton:
                        authData?.userId == _user?.userId,
                    followers: isUserLoggedInuser
                        ? authData?.followers.length.toString()
                        : _user?.followers.length.toString(),
                    following: isUserLoggedInuser
                        ? authData?.following.length.toString()
                        : _user?.following.length.toString(),
                    onFollowersPress: () => context.push(
                      '/user/followers-and-following/${_user?.userId}?type=followers',
                    ),
                    onFollowingPress: () => context.push(
                      '/user/followers-and-following/${_user?.userId}?type=following',
                    ),
                    profilePicture: isUserLoggedInuser
                        ? authData?.profilePicture
                        : _user?.profilePicture,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  UsernameAndFullName(
                    fullName: isUserLoggedInuser
                        ? authData?.fullName
                        : _user?.fullName,
                    username: isUserLoggedInuser
                        ? authData?.username
                        : _user?.username,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ProfileMainButtonAndShare(
                    onPressMainButton: isUserLoggedInuser
                        ? () => showModalBottomSheet(
                              useRootNavigator: true,
                              isScrollControlled: true,
                              context: context,
                              builder: (ctx) => EditUserProfileModalContent(
                                onEditProfilePictureTap:
                                    _onEditProfilePictureTap,
                              ),
                            )
                        : () => _followOrUnfollowUser(_user!.userId),
                    mainButtonTitle: isUserLoggedInuser
                        ? 'Edit profile'
                        : isUserAlreadyFollowing != null &&
                                isUserAlreadyFollowing
                            ? 'Unfollow'
                            : 'Follow',
                    onShareButtonPress: () {},
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                    ),
                    child: CustomButton(
                      onPress: () {},
                      title: 'View favorites',
                      borderless: true,
                      height: 50,
                      childAlignment: MainAxisAlignment.start,
                    ),
                  )
                ],
              ),
            ),
          ),
          PagedSliverGrid<int, Post>(
            showNoMoreItemsIndicatorAsGridChild: false,
            showNewPageErrorIndicatorAsGridChild: false,
            showNewPageProgressIndicatorAsGridChild: false,
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate(
              noItemsFoundIndicatorBuilder: (context) =>
                  const NoItemsFoundIndicator(),
              firstPageErrorIndicatorBuilder: (context) =>
                  const ErrorIndicator(),
              firstPageProgressIndicatorBuilder: (context) =>
                  const ListProgressIndicator(),
              newPageErrorIndicatorBuilder: (context) => const ErrorIndicator(),
              newPageProgressIndicatorBuilder: (context) =>
                  const ListProgressIndicator(),
              itemBuilder: (context, item, index) => PostListItem(
                post: item,
                onPostPress: () => context.push(
                  '/post/${item.postId}?user=${item.user.fullName}',
                ),
              ),
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
              crossAxisCount: 3,
            ),
          ),
        ],
      ),
    );
  }
}
