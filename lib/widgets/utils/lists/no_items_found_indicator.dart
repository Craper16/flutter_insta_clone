import 'package:flutter/cupertino.dart';
import 'package:flutter_insta/classes/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class NoItemsFoundIndicator extends StatelessWidget {
  const NoItemsFoundIndicator({
    super.key,
    this.isComments = false,
  });

  final bool isComments;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const SizedBox(
          height: 25,
        ),
        Container(
          height: 110,
          width: 110,
          decoration: BoxDecoration(
            border: isComments
                ? null
                : Border.all(
                    width: 1,
                    color: appColors.secondary,
                  ),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Icon(
            isComments ? CupertinoIcons.chat_bubble : CupertinoIcons.camera,
            color: appColors.secondary,
            size: 60,
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        Text(
          isComments ? 'No comments yet' : 'No posts yet',
          style: GoogleFonts.poppins(
            color: appColors.secondary,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (isComments)
          Text(
            'Start the conversation',
            style: GoogleFonts.poppins(
              color: appColors.secondary.withOpacity(0.8),
              fontSize: 18,
            ),
          ),
      ],
    );
  }
}
