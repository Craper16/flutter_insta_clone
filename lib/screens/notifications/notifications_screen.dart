import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_insta/classes/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
    this.userId,
  });

  final String? userId;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColors.primary,
      appBar: AppBar(
        backgroundColor: appColors.primary,
        leading: CupertinoButton(
          onPressed: () => context.pop(),
          padding: const EdgeInsets.all(0),
          borderRadius: BorderRadius.circular(100),
          minSize: 15,
          child: Icon(
            CupertinoIcons.back,
            color: appColors.secondary,
          ),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            color: appColors.secondary,
          ),
        ),
      ),
    );
  }
}
