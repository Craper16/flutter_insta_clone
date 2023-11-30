import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_insta/classes/app_colors.dart';
import 'package:flutter_insta/widgets/posts/add_post_bottom_modal_content.dart';
import 'package:flutter_insta/widgets/utils/custom_navigation_bar.dart';
import 'package:go_router/go_router.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  _goBranch(int index) {
    if (index == 2) {
      return showCupertinoModalPopup(
        context: context,
        builder: (ctx) => const AddPostBottomModalContent(),
      );
    }

    return widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        destinations: [
          NavigationDestination(
            selectedIcon: Icon(
              Icons.home,
              size: 30,
              color: appColors.secondary,
            ),
            icon: Icon(
              Icons.home_outlined,
              size: 30,
              color: appColors.secondary,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              CupertinoIcons.search_circle_fill,
              size: 30,
              color: appColors.secondary,
            ),
            icon: Icon(
              CupertinoIcons.search,
              size: 30,
              color: appColors.secondary,
            ),
            label: 'Search',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              CupertinoIcons.add_circled,
              size: 30,
              color: appColors.secondary,
            ),
            icon: Icon(
              CupertinoIcons.add_circled,
              size: 30,
              color: appColors.secondary,
            ),
            label: 'Search',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              CupertinoIcons.film_fill,
              size: 30,
              color: appColors.secondary,
            ),
            icon: Icon(
              CupertinoIcons.film,
              size: 30,
              color: appColors.secondary,
            ),
            label: 'Reels',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              CupertinoIcons.person_crop_circle_fill,
              size: 30,
              color: appColors.secondary,
            ),
            icon: Icon(
              CupertinoIcons.person_crop_circle,
              size: 30,
              color: appColors.secondary,
            ),
            label: 'Profile',
          ),
        ],
        onDestinationSelected: _goBranch,
      ),
      body: widget.navigationShell,
    );
  }
}
