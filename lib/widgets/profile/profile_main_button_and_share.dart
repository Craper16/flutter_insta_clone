import 'package:flutter/material.dart';
import 'package:flutter_insta/classes/app_colors.dart';
import 'package:flutter_insta/widgets/utils/custom_button.dart';

class ProfileMainButtonAndShare extends StatelessWidget {
  const ProfileMainButtonAndShare({
    super.key,
    required this.onPressMainButton,
    required this.mainButtonTitle,
    required this.onShareButtonPress,
  });

  final void Function() onPressMainButton;
  final String mainButtonTitle;
  final void Function() onShareButtonPress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: <Widget>[
          Expanded(
            child: CustomButton(
              onPress: onPressMainButton,
              title: mainButtonTitle,
              backgroundColor: appColors.primary,
              foregroundColor: appColors.secondary,
            ),
          ),
          const SizedBox(
            width: 30,
          ),
          Expanded(
            child: CustomButton(
              onPress: onShareButtonPress,
              title: 'Share profile',
              backgroundColor: appColors.primary,
              foregroundColor: appColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
