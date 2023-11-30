import 'package:flutter/material.dart';
import 'package:flutter_insta/classes/app_colors.dart';

class BottomModalSheetHandle extends StatelessWidget {
  const BottomModalSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 5,
      width: 40,
      decoration: BoxDecoration(
        color: appColors.secondary,
        borderRadius: BorderRadius.circular(
          20,
        ),
      ),
    );
  }
}
