import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class LargeAvatar extends StatelessWidget {
  final String imageURL;
  final File imageFile;
  final String imageAssetPath;

  LargeAvatar({this.imageURL, this.imageFile, this.imageAssetPath});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: CircleAvatar(
        radius: 66,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: 62,
          backgroundColor: Colors.transparent,
          backgroundImage: this.imageURL != null
              ? CachedNetworkImageProvider(this.imageURL)
              : (this.imageFile != null
                  ? FileImage(this.imageFile)
                  : (this.imageAssetPath != null
                      ? AssetImage(this.imageAssetPath)
                      : null)),
        ),
      ),
    );
  }
}

class LargeAvatarEdit extends StatefulWidget {
  final String imageURL;
  final File imageFile;
  final String imageAssetPath;
  final void Function(File) onImageUpdated;

  LargeAvatarEdit(
      {this.imageURL,
      this.imageFile,
      this.imageAssetPath,
      this.onImageUpdated});

  @override
  _LargeAvatarEditState createState() => _LargeAvatarEditState();
}

class _LargeAvatarEditState extends State<LargeAvatarEdit> {
  File uploadedImage;

  void onTapAvatar(BuildContext context) {
    FocusScope.of(context)
        .unfocus(disposition: UnfocusDisposition.previouslyFocusedChild);
    ImagePicker.pickImage(source: ImageSource.gallery).then((imageFile) {
      if (imageFile != null) {
        ImageCropper.cropImage(
            sourcePath: imageFile.path,
            aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
            cropStyle: CropStyle.circle,
            maxHeight: 300,
            maxWidth: 300,
            androidUiSettings: AndroidUiSettings(
              toolbarColor: Theme.of(context).scaffoldBackgroundColor,
              toolbarWidgetColor: Colors.white,
              cropFrameColor: Colors.transparent,
              showCropGrid: false,
              hideBottomControls: true,
            )).then((imageFile) {
          if (imageFile != null) {
            this.setState(() {
              this.uploadedImage = imageFile;
            });
            this.widget.onImageUpdated(imageFile);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(76),
      onTap: () => this.onTapAvatar(context),
      child: uploadedImage == null
          ? LargeAvatar(
              imageURL: this.widget.imageURL,
              imageFile: this.widget.imageFile,
              imageAssetPath: this.widget.imageAssetPath,
            )
          : LargeAvatar(imageFile: this.uploadedImage),
    );
  }
}
