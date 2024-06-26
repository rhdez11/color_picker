import 'dart:io';

import 'package:color_picker/bottom_bar_masks.dart';
import 'package:flutter/material.dart';

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    // return MaskImageWidget(
    //   initialImage: File(imagePath),
    // );
    return BottomNavigationBarMasksWidget(
      initialImage: File(imagePath),
    );
  }
}
