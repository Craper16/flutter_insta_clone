import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_insta/classes/app_colors.dart';
import 'package:flutter_insta/classes/post.dart';
import 'package:flutter_insta/classes/user.dart';
import 'package:flutter_insta/constants/tokens.dart';
import 'package:flutter_insta/dio/profile/get_signed_in_user_data.dart';
import 'package:flutter_insta/dio/users/get_user_posts.dart';
import 'package:flutter_insta/main.dart';
import 'package:flutter_insta/providers/auth_provider.dart';
import 'package:flutter_insta/widgets/posts/post_list_item.dart';
import 'package:flutter_insta/widgets/profile/edit_profile_picture_modal_content.dart';
import 'package:flutter_insta/widgets/profile/edit_user_profile_modal_content.dart';
import 'package:flutter_insta/widgets/profile/profile_image_and_followers.dart';
import 'package:flutter_insta/widgets/profile/profile_main_button_and_share.dart';
import 'package:flutter_insta/widgets/profile/save_profile_picture_dialog_content.dart';
import 'package:flutter_insta/widgets/profile/username_and_fullname.dart';
import 'package:flutter_insta/widgets/utils/lists/error_indicator.dart';
import 'package:flutter_insta/widgets/utils/lists/list_progress_indicator.dart';
import 'package:flutter_insta/widgets/utils/lists/no_items_found_indicator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  final PagingController<int, Post> _pagingController =
      PagingController(firstPageKey: 1);
  final ImagePicker picker = ImagePicker();
  File? _selectedProfileImage;

  @override
  void initState() {
    super.initState();

    _getSignedInUserData();
    _pagingController.addPageRequestListener((pageKey) {
      _getUserPosts(pageKey);
    });
  }

  @override
  void dispose() {
    super.dispose();

    _pagingController.dispose();
  }

  void _getSignedInUserData() async {
    try {
      final response = await getSignedInUserData();

      final access = await storage.read(key: accessToken);
      final refresh = await storage.read(key: refreshToken);
      final expiryTime = await storage.read(key: expiresAt);

      ref.read(authProvider.notifier).setAuthData(
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
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Connection unstable ${e.response?.data['message']}',
            style: GoogleFonts.poppins(),
          ),
        ),
      );
    }
  }

  Future<void> _getUserPosts(int page) async {
    try {
      final response = await getUserPosts(
        ref.read(authProvider)!.userId,
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
      _pagingController.error = error;
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

  void _onSettingsPress() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      useRootNavigator: true,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.5,
        child: ListTile(
          onTap: () async {
            await storage.deleteAll();
            ref.read(authProvider.notifier).resetAuthData();
            if (context.mounted) {
              context.go('/auth/signin');
            }
          },
          leading: Icon(
            Icons.logout_outlined,
            color: appColors.secondary,
          ),
          title: Text(
            'Logout',
            style: GoogleFonts.poppins(
              color: appColors.secondary,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authData = ref.watch(authProvider);

    final List<String> tabs = ['Public', 'Private'];

    return DefaultTabController(
      length: 2, // This is the number of tabs.
      child: Scaffold(
        backgroundColor: appColors.primary,
        appBar: AppBar(
          backgroundColor: appColors.primary,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 22,
            color: appColors.secondary,
          ),
          title: const Text(
            'Profile',
          ),
          actions: <Widget>[
            CupertinoButton(
              onPressed: _onSettingsPress,
              child: Icon(
                Icons.settings_outlined,
                color: appColors.secondary,
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          color: appColors.secondary,
          child: NestedScrollView(
            scrollBehavior: const ScrollBehavior(),
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      ProfileImageAndFollowers(
                        followers: authData?.followers.length.toString(),
                        following: authData?.following.length.toString(),
                        onEditProfilePictureTap: _onEditProfilePictureTap,
                        onFollowersPress: () => context.push(
                          '/user/followers-and-following/${authData!.userId}?type=followers',
                        ),
                        onFollowingPress: () => context.push(
                          '/user/followers-and-following/${authData!.userId}?type=following',
                        ),
                        profilePicture: authData?.profilePicture,
                        showProfilePictureEditButton: true,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      UsernameAndFullName(
                        fullName: authData?.fullName,
                        username: authData?.username,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ProfileMainButtonAndShare(
                        onPressMainButton: () => showModalBottomSheet(
                          useRootNavigator: true,
                          isScrollControlled: true,
                          context: context,
                          builder: (ctx) => EditUserProfileModalContent(
                            onEditProfilePictureTap: _onEditProfilePictureTap,
                          ),
                        ),
                        mainButtonTitle: 'Edit profile',
                        onShareButtonPress: () {},
                      ),
                    ],
                  ),
                ),
                SliverOverlapAbsorber(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                    context,
                  ),
                  sliver: SliverAppBar(
                    backgroundColor: appColors.primary,
                    scrolledUnderElevation: 0,
                    elevation: 0,
                    centerTitle: true,
                    pinned: true,
                    toolbarHeight: 0,
                    forceElevated: innerBoxIsScrolled,
                    bottom: TabBar(
                      dividerColor: appColors.primary,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorColor: appColors.secondary,
                      splashFactory: NoSplash.splashFactory,
                      tabs: [
                        Tab(
                          icon: Icon(
                            CupertinoIcons.square_grid_3x2,
                            color: appColors.secondary,
                          ),
                        ),
                        Tab(
                          icon: Icon(
                            CupertinoIcons.person_crop_square,
                            color: appColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: tabs.map(
                (String name) {
                  return SafeArea(
                    top: false,
                    bottom: false,
                    child: Builder(
                      builder: (BuildContext context) {
                        return CustomScrollView(
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          slivers: <Widget>[
                            CupertinoSliverRefreshControl(
                              onRefresh: () => Future.sync(
                                () => _pagingController.refresh(),
                              ),
                            ),
                            SliverOverlapInjector(
                              handle: NestedScrollView
                                  .sliverOverlapAbsorberHandleFor(context),
                            ),
                            PagedSliverGrid(
                              showNoMoreItemsIndicatorAsGridChild: false,
                              showNewPageErrorIndicatorAsGridChild: false,
                              showNewPageProgressIndicatorAsGridChild: false,
                              pagingController: _pagingController,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisSpacing: 0,
                                mainAxisSpacing: 0,
                                crossAxisCount: 3,
                              ),
                              builderDelegate: PagedChildBuilderDelegate<Post>(
                                noItemsFoundIndicatorBuilder: (context) =>
                                    const NoItemsFoundIndicator(),
                                firstPageErrorIndicatorBuilder: (context) =>
                                    const ErrorIndicator(),
                                firstPageProgressIndicatorBuilder: (context) =>
                                    const ListProgressIndicator(),
                                newPageErrorIndicatorBuilder: (context) =>
                                    const ErrorIndicator(),
                                newPageProgressIndicatorBuilder: (context) =>
                                    const ListProgressIndicator(),
                                itemBuilder: (context, item, index) =>
                                    PostListItem(
                                  post: item,
                                  onPostPress: () => context.push(
                                    '/post/${item.postId}?user=${item.user.fullName}',
                                  ),
                                ),
                              ),
                            )
                          ],
                        );
                      },
                    ),
                  );
                },
              ).toList(),
            ),
          ),
          onRefresh: () => Future.sync(() {
            _getSignedInUserData();
            _pagingController.refresh();
          }),
        ),
      ),
    );
  }
}
