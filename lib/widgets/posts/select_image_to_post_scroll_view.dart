import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_insta/classes/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_manager/photo_manager.dart';

class SelectImageToPostScrollView extends StatefulWidget {
  const SelectImageToPostScrollView({
    super.key,
    required this.onSelectImages,
  });

  final void Function(List<File> selectedFiles) onSelectImages;

  @override
  State<SelectImageToPostScrollView> createState() =>
      _SelectImageToPostScrollViewState();
}

class _SelectImageToPostScrollViewState
    extends State<SelectImageToPostScrollView> {
  List<File> _userDeviceMedia = [];
  List<File> _selectedImageOrVideo = [];

  bool _isLoading = false;

  Future<void> _getUserDevicePhotos() async {
    setState(() {
      _isLoading = true;
    });
    final PermissionState permissionState =
        await PhotoManager.requestPermissionExtend();

    if (permissionState.isAuth) {
      if (context.mounted) {
        try {
          final List<AssetEntity> photosAndVideos =
              await PhotoManager.getAssetListRange(
            start: 0,
            end: 80,
            type: RequestType.image,
          );

          List<File> updatedUserDeviceMedia = [];

          for (AssetEntity asset in photosAndVideos) {
            final file = await asset.file;

            if (file != null) {
              updatedUserDeviceMedia.add(file);
            }
          }

          setState(() {
            _userDeviceMedia = updatedUserDeviceMedia;
            _selectedImageOrVideo = [updatedUserDeviceMedia[0]];
            _isLoading = false;
          });

          widget.onSelectImages(updatedUserDeviceMedia);
        } catch (e) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      if (context.mounted) {
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            actions: [
              CupertinoDialogAction(
                onPressed: () async {
                  await PhotoManager.openSetting();
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                isDefaultAction: true,
                child: Text(
                  'Settings',
                  style: GoogleFonts.poppins(),
                ),
              ),
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(
                  context,
                ),
                isDestructiveAction: true,
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(),
                ),
              ),
            ],
            title: Text(
              'Alert',
              style: GoogleFonts.poppins(),
            ),
            content: Center(
              child: Text(
                'You need to enable permissions for instagram to see your device photos',
                style: GoogleFonts.poppins(),
              ),
            ),
          ),
        );
      }
    }
  }

  void _onTapImage(File tappedImage) {
    final isAlreadyPickedAndCanRemove =
        _selectedImageOrVideo.contains(tappedImage) &&
            _selectedImageOrVideo.length != 1;

    if (isAlreadyPickedAndCanRemove) {
      final updatedSelectedImagesOrVideo = _selectedImageOrVideo;

      updatedSelectedImagesOrVideo.remove(tappedImage);

      setState(() {
        _selectedImageOrVideo = updatedSelectedImagesOrVideo;
      });
      widget.onSelectImages(updatedSelectedImagesOrVideo);
    } else {
      setState(() {
        _selectedImageOrVideo = [..._selectedImageOrVideo, tappedImage];
      });
      widget.onSelectImages(
        [..._selectedImageOrVideo],
      );
    }
  }

  @override
  void initState() {
    super.initState();

    _getUserDevicePhotos();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: defaultTargetPlatform == TargetPlatform.iOS
            ? const CupertinoActivityIndicator()
            : const CircularProgressIndicator(),
      );
    }

    if (!_isLoading && _userDeviceMedia.isEmpty) {
      return Center(
        child: Text(
          'No media found',
          style: GoogleFonts.poppins(
            color: appColors.secondary,
          ),
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          stretch: true,
          leading: const Text(''),
          elevation: 0,
          backgroundColor: appColors.primary,
          pinned: true,
          scrolledUnderElevation: 0,
          expandedHeight: 400,
          floating: true,
          snap: true,
          toolbarHeight: 0,
          collapsedHeight: 0,
          flexibleSpace: FlexibleSpaceBar(
            stretchModes: const [
              StretchMode.fadeTitle,
              StretchMode.zoomBackground,
            ],
            collapseMode: CollapseMode.parallax,
            background: _userDeviceMedia.isNotEmpty
                ? Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.contain,
                        image: FileImage(
                          _selectedImageOrVideo[0],
                        ),
                      ),
                    ),
                  )
                : null,
          ),
        ),
        SliverGrid.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisSpacing: 0,
            mainAxisSpacing: 0,
            crossAxisCount: 3,
          ),
          itemCount: _userDeviceMedia.length,
          itemBuilder: (context, index) {
            final isImageSelected = _selectedImageOrVideo.contains(
              _userDeviceMedia[index],
            );

            return GestureDetector(
              onTap: () => _onTapImage(_userDeviceMedia[index]),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isImageSelected
                            ? CupertinoColors.activeBlue
                            : appColors.primary,
                        width: 3,
                      ),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: FileImage(
                          _userDeviceMedia[index],
                        ),
                      ),
                    ),
                  ),
                  if (isImageSelected)
                    const Padding(
                      padding: EdgeInsets.all(10),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Icon(
                          Icons.check_circle,
                          color: CupertinoColors.activeBlue,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
