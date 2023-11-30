import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_insta/classes/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.onPress,
    required this.title,
    this.height = 35,
    this.width = double.infinity,
    this.backgroundColor,
    this.foregroundColor,
    this.isLoading = false,
    this.borderless = false,
    this.childAlignment = MainAxisAlignment.center,
    this.titlePrefix,
  });

  final void Function() onPress;
  final String title;
  final double height;
  final double width;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isLoading;
  final bool borderless;
  final MainAxisAlignment childAlignment;
  final Widget? titlePrefix;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        border: borderless
            ? null
            : Border.all(
                color: appColors.secondary.withOpacity(0.2),
              ),
        borderRadius: BorderRadius.circular(40),
      ),
      child: CupertinoButton(
        color: appColors.primary,
        padding: const EdgeInsets.all(0),
        borderRadius: BorderRadius.circular(40),
        onPressed: onPress,
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: defaultTargetPlatform == TargetPlatform.android
                    ? CircularProgressIndicator(
                        strokeWidth: 2,
                        color: appColors.primary,
                      )
                    : const CupertinoActivityIndicator(
                        radius: 10,
                      ),
              )
            : Row(
                mainAxisAlignment: childAlignment,
                children: [
                  if (titlePrefix != null) titlePrefix!,
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: appColors.secondary,
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
