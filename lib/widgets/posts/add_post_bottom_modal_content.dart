import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_insta/classes/app_colors.dart';
import 'package:flutter_insta/dio/posts/post_pictures.dart';
import 'package:flutter_insta/widgets/posts/select_image_to_post_scroll_view.dart';
import 'package:flutter_insta/widgets/posts/upload_post_confirm_modal_content.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class AddPostBottomModalContent extends StatefulWidget {
  const AddPostBottomModalContent({super.key});

  @override
  State<AddPostBottomModalContent> createState() =>
      _AddPostBottomModalContentState();
}

class _AddPostBottomModalContentState extends State<AddPostBottomModalContent> {
  final TextEditingController _captionTextEditingController =
      TextEditingController();
  final _imagePicker = ImagePicker();

  List<File> _selectedImages = [];
  int _pagesIndex = 1;
  bool _isLoadingPost = false;

  void _onTakeAPicturePress() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.camera,
    );

    if (image != null) {
      setState(() {
        _selectedImages = [File(image.path)];
        _pagesIndex = 2;
      });
    }
  }

  void _post() async {
    final picturesData = FormData();

    picturesData.fields.add(MapEntry(
      'caption',
      _captionTextEditingController.text,
    ));

    for (File picture in _selectedImages) {
      picturesData.files.addAll(
        [
          MapEntry(
              "posts",
              await MultipartFile.fromFile(picture.path,
                  filename: picture.path.split("/").last)),
        ],
      );
    }

    try {
      setState(() {
        _isLoadingPost = true;
      });
      final response = await postPictures(picturesData);

      if (context.mounted) {
        Navigator.of(context).pop();
        context.push(
            '/post/${response['post']['postId']}?user=${response['post']['user']['fullName']}');
      }
      setState(() {
        _isLoadingPost = false;
      });
    } on DioException catch (_) {
      setState(() {
        _isLoadingPost = false;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'An error has occured',
              style: GoogleFonts.poppins(),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget currentPage = SelectImageToPostScrollView(
      onSelectImages: (image) => setState(() {
        _selectedImages = image;
      }),
    );

    if (_pagesIndex == 2) {
      currentPage = UploadPostConfirmModalContent(
        selectedImages: _selectedImages,
        captionTextEditingController: _captionTextEditingController,
      );
    }

    return Scaffold(
      backgroundColor: appColors.primary,
      appBar: AppBar(
        backgroundColor: appColors.primary,
        centerTitle: true,
        actions: [
          CupertinoButton(
            onPressed: _onTakeAPicturePress,
            child: const Icon(
              CupertinoIcons.camera,
              color: CupertinoColors.activeBlue,
            ),
          ),
          if (_selectedImages.isNotEmpty)
            CupertinoButton(
              onPressed: _pagesIndex == 2
                  ? _post
                  : () => setState(() {
                        _pagesIndex = 2;
                      }),
              child: _isLoadingPost
                  ? defaultTargetPlatform == TargetPlatform.iOS
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CupertinoActivityIndicator(
                            color: appColors.secondary,
                          ),
                        )
                      : SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: appColors.secondary,
                          ),
                        )
                  : Text(
                      _pagesIndex == 1 ? 'Next' : 'Share',
                      style: GoogleFonts.poppins(
                        color: CupertinoColors.activeBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            )
        ],
        scrolledUnderElevation: 0,
        title: Text(
          'Post',
          style: GoogleFonts.poppins(),
        ),
        leading: CupertinoButton(
          child: Icon(
            Icons.close,
            size: 28,
            color: appColors.secondary,
          ),
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
        ),
      ),
      body: currentPage,
    );
  }
}
