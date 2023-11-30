import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_insta/classes/app_colors.dart';
import 'package:flutter_insta/providers/auth_provider.dart';
import 'package:flutter_insta/widgets/posts/add_post_bottom_modal_content.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  void _onAddPostPress() {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => const AddPostBottomModalContent(),
    );
  }

  void _onNotificationsPress() async {
    final userId = ref.read(authProvider)?.userId;

    context.push('/notifications/$userId');
  }

  @override
  Widget build(BuildContext context) {
    final authData = ref.read(authProvider);
    return Scaffold(
      backgroundColor: appColors.primary,
      appBar: AppBar(
        backgroundColor: appColors.primary,
        titleTextStyle: GoogleFonts.lobsterTwo(
          fontSize: 32,
          color: appColors.secondary,
        ),
        centerTitle: false,
        title: const Text(
          'Instagram',
        ),
        actions: [
          CupertinoButton(
            padding: const EdgeInsets.all(0),
            onPressed: _onAddPostPress,
            child: Icon(
              CupertinoIcons.add_circled,
              color: appColors.secondary,
              size: 30,
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            onPressed: _onNotificationsPress,
            child: Icon(
              Icons.notifications_outlined,
              color: appColors.secondary,
              size: 30,
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              authData!.username,
            ),
          ],
        ),
      ),
    );
  }
}
