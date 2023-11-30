import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_insta/classes/app_colors.dart';

class ListProgressIndicator extends StatelessWidget {
  const ListProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return SizedBox(
        height: 300,
        width: 300,
        child: CupertinoActivityIndicator(
          color: appColors.secondary,
        ),
      );
    }
    return SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        color: appColors.secondary,
      ),
    );
  }
}
