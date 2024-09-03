import 'dart:async';
import 'package:camera/camera.dart';
import 'package:color_picker/display_picture_screen.dart';
// import 'package:color_picker/mask_img.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  List<CameraDescription>? _availableCameras;
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _getAvailableCameras();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  Future<void> _getAvailableCameras() async {
    WidgetsFlutterBinding.ensureInitialized();
    _availableCameras = await availableCameras();
  }

  Future<void> _initCamera(CameraDescription description) async {
    _controller =
        CameraController(description, ResolutionPreset.max, enableAudio: true);

    try {
      await _controller.initialize();
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  void toggleCameraLens() {
    final lensDirection = _controller.description.lensDirection;
    CameraDescription newDescription;
    if (lensDirection == CameraLensDirection.front) {
      newDescription = _availableCameras!.firstWhere((description) =>
          description.lensDirection == CameraLensDirection.back);
    } else {
      newDescription = _availableCameras!.firstWhere((description) =>
          description.lensDirection == CameraLensDirection.front);
    }

    _initCamera(newDescription);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future getImageFromGallery(BuildContext context) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (!context.mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DisplayPictureScreen(
            imagePath: pickedFile.path,
          ),
        ),
      );
    }
  }

  Future takePicture(BuildContext context) async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();

      if (!context.mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DisplayPictureScreen(
            imagePath: image.path,
          ),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tomale una foto a tu pared')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // return CameraPreview(_controller);
            return Stack(
              children: [
                Positioned.fill(child: CameraPreview(_controller)),
                Positioned.fill(
                    child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 35),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(60, 60),
                          shape: const CircleBorder(),
                          padding: EdgeInsets.zero),
                      child: const Icon(Icons.insert_photo_outlined),
                      onPressed: () async {
                        await getImageFromGallery(context);
                      },
                    ),
                  ),
                )),
                Positioned.fill(
                    child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(90, 90),
                          shape: const CircleBorder(),
                          padding: EdgeInsets.zero),
                      onPressed: () async {
                        await takePicture(context);
                      },
                      child: const Icon(
                        Icons.camera_alt,
                        size: 35,
                      ),
                    ),
                  ),
                )),
                Positioned.fill(
                    child: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 35),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(60, 60),
                          shape: const CircleBorder(),
                          padding: EdgeInsets.zero),
                      onPressed: () async {
                        toggleCameraLens();
                      },
                      child: const Icon(Icons.switch_camera_outlined),
                    ),
                  ),
                ))
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
