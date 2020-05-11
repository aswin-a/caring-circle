import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class LargeAvatar extends StatelessWidget {
  final bool editMode;
  final bool autoFocus;

  final TextEditingController nameController = TextEditingController();
  final String name;
  final void Function(String) onNameChanged;
  final void Function(String) onNameSubmitted;

  final ImageProvider imageProvider;
  final void Function(File) onImageUpdated;

  final String subtext;

  LargeAvatar({
    this.editMode = false,
    this.autoFocus = false,
    this.name,
    this.onNameChanged,
    this.onNameSubmitted,
    this.imageProvider,
    this.onImageUpdated,
    this.subtext,
  }) {
    if (this.name != null) {
      nameController.text = this.name;
      nameController.selection =
          TextSelection.fromPosition(TextPosition(offset: this.name.length));
    }
  }

  void onTapAvatar(BuildContext context) {
    FocusScope.of(context).unfocus(focusPrevious: true);
    ImagePicker.pickImage(source: ImageSource.gallery).then((imageFile) {
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
        this.onImageUpdated(imageFile);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 20, bottom: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          InkWell(
            onTap: this.editMode ? () => this.onTapAvatar(context) : null,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                CircleAvatar(
                  radius: 66,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 62,
                    backgroundColor: Colors.transparent,
                    backgroundImage: this.imageProvider,
                  ),
                ),
                this.editMode
                    ? Positioned(
                        top: 110,
                        left: 52,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: Container(
                            color: Colors.black.withOpacity(0.7),
                            padding: EdgeInsets.symmetric(
                                vertical: 2, horizontal: 4),
                            child: Text(
                              'Edit',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              child: TextField(
                controller: this.nameController,
                onChanged: this.onNameChanged,
                onSubmitted: this.onNameSubmitted,
                cursorColor: Colors.white,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    filled: this.editMode,
                    fillColor: Colors.white.withOpacity(0.3),
                    hintText: 'Name',
                    hintStyle: Theme.of(context).textTheme.display1),
                showCursor: true,
                style: Theme.of(context).textTheme.display3,
                textAlign: TextAlign.center,
                enabled: this.editMode,
                autofocus: this.autoFocus,
              ),
            ),
          ),
          this.subtext != null
              ? Text(
                  this.subtext,
                  style: TextStyle(color: Colors.white70),
                )
              : Container(),
        ],
      ),
    );
  }
}
