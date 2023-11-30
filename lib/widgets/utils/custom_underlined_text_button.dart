import 'package:flutter/material.dart';
import 'package:flutter_insta/classes/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomUnderlinedTextButton extends StatelessWidget {
  const CustomUnderlinedTextButton({
    super.key,
    required this.title,
    this.onTap,
    this.textDecoration = TextDecoration.underline,
    this.alignment = AlignmentDirectional.center,
    this.fontSize = 16,
    this.disabled = false,
  });

  final void Function()? onTap;
  final String title;
  final TextDecoration textDecoration;
  final AlignmentGeometry alignment;
  final double fontSize;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          title,
          style: GoogleFonts.poppins(
            decoration: textDecoration,
            fontSize: fontSize,
            color: appColors.secondary.withOpacity(disabled ? 0.5 : 1),
          ),
        ),
      ),
    );
  }
}
