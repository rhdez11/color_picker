// ignore_for_file: avoid_print

import 'dart:io';

import 'package:color_picker/display_picture_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:path_provider/path_provider.dart';

class DemoView extends StatelessWidget {
  const DemoView({Key? key}) : super(key: key);

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.create(recursive: true);
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.builder(
        itemCount: 7,
        gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2),
        itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                  onTap: () async {
                    var myFile =
                        await getImageFileFromAssets('imgs/image$index.jpg');
                    print('file $myFile');
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DisplayPictureScreen(
                          imagePath: myFile.path,
                        ),
                      ),
                    );
                  },
                  child: Image.asset('assets/imgs/image$index.jpg')),
            ));
  }
}
