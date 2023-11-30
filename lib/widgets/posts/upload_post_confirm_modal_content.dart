import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_insta/classes/app_colors.dart';
import 'package:flutter_insta/widgets/inputs/custom_text_form_field.dart';

class UploadPostConfirmModalContent extends StatefulWidget {
  const UploadPostConfirmModalContent({
    super.key,
    required this.selectedImages,
    required this.captionTextEditingController,
  });

  final TextEditingController captionTextEditingController;

  final List<File> selectedImages;

  @override
  State<UploadPostConfirmModalContent> createState() =>
      _UploadPostConfirmModalContentState();
}

class _UploadPostConfirmModalContentState
    extends State<UploadPostConfirmModalContent> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(
        FocusNode(),
      ),
      child: Scaffold(
        backgroundColor: appColors.primary,
        body: AnimatedOpacity(
          opacity: 1,
          duration: const Duration(milliseconds: 300),
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: Image.file(
                        widget.selectedImages[0],
                      ),
                    ),
                    Expanded(
                      child: CustomTextFormField(
                        controller: widget.captionTextEditingController,
                        hintTextColor: appColors.secondary.withOpacity(
                          0.5,
                        ),
                        cursorColor: appColors.secondary,
                        hintText: 'Caption',
                        fillColor: appColors.primary,
                        textColor: appColors.secondary,
                        focusedBorderColor: appColors.secondary,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
