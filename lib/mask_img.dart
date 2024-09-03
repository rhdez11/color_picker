// ignore_for_file: avoid_print

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;

class MaskImageWidget extends StatefulWidget {
  final File? initialImage;

  const MaskImageWidget({super.key, this.initialImage});

  @override
  _MaskImageWidgetState createState() => _MaskImageWidgetState();
}

class _MaskImageWidgetState extends State<MaskImageWidget> {
  // Color _currentColor = Colors.transparent;
  final picker = ImagePicker();
  File? _image;
  double _aspectRatio = 0.0;
  List<List<Offset>>? _whitePixelsArray;
  Future<List<ui.Image>>? _futureImages;
  List<Color>? _currentColorsArray;
  List<dynamic>? _pickerPositions;
  List<String>? _labelsArray;
  int? _selectedIndex;
  ui.Image? _texture;
  List<Color>? _colorOptionButtons;

  @override
  void initState() {
    super.initState();
    _image = widget.initialImage;
    _loadImageDB(_image!);
    _colorOptionButtons = [
      Colors.deepPurple.shade900,
      Colors.teal.shade900,
      Colors.deepOrange.shade900,
      Colors.pink,
      Colors.transparent
    ];
  }

  Future<ui.Image> loadUiImage(String assetPath) async {
    final Completer<ui.Image> completer = Completer();
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();
    ui.decodeImageFromList(bytes, (ui.Image img) {
      completer.complete(img);
    });
    return completer.future;
  }

  Future<void> _loadImageDB(File imageFile) async {
    _texture = await loadUiImage('assets/brick.jpg');
    print('Testinggg..... $_image');
    final bytes = await imageFile.readAsBytes();
    var response = await http.post(
      Uri.parse(
          "https://1181-2806-2f0-91a0-68bf-2907-8902-c70-e5d0.ngrok-free.app/segment"),
      body: bytes,
    );

    print('Testinggg res..... $response');

    if (response.statusCode == 200) {
      int numOfMasks = (json.decode(response.body)['images'] as List).length;
      List<List<Offset>> whitePixelsArray = [];
      List<img.Image> imagesArray = [];
      List<Color> currentColorsArray = [];
      List<dynamic> pickerPositions = [];
      List<String> labelsArray = [];

      print('Num of masks $numOfMasks');
      for (int i = 0; i < numOfMasks; i++) {
        print('testet ${json.decode(response.body)['boxes'][i][0]}');
        dynamic imageStr = json.decode(response.body)['images'][i].toString();
        Uint8List imageBytes = base64Decode(imageStr);

        final img.Image image = img.decodeImage(imageBytes)!;
        final List<Offset> whitePixels = detectWhitePixels(image);

        imagesArray.add(image);
        whitePixelsArray.add(whitePixels);
        pickerPositions.add(json.decode(response.body)['boxes'][i]);
        labelsArray.add(json.decode(response.body)['labels'][i]);
        currentColorsArray.add(Colors.transparent);
      }

      Future<List<ui.Image>> futureImages =
          convertImagesToUiImages(imagesArray);

      setState(() {
        _aspectRatio = imagesArray[0].height / imagesArray[0].width;
        _whitePixelsArray = whitePixelsArray;
        _futureImages = futureImages;
        _currentColorsArray = currentColorsArray;
        _pickerPositions = pickerPositions;
        _labelsArray = labelsArray;
      });

      print('Testinggg colors..... ${_currentColorsArray?.length}');
    } else {
      // Handle the error
      throw Exception('Failed to load image');
    }
  }

  List<Offset> detectWhitePixels(img.Image image) {
    final List<Offset> whitePixels = [];
    print('Dimensiones de mascara');
    print(image.width);
    print(image.height);
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final int r = img.getRed(pixel);
        final int g = img.getGreen(pixel);
        final int b = img.getBlue(pixel);
        final int a = img.getAlpha(pixel);
        if (r == 255 && g == 255 && b == 255 && a == 255) {
          whitePixels.add(Offset(x.toDouble(), y.toDouble()));
        }
      }
    }
    return whitePixels;
  }

  Future<ui.Image> _imageToUiImage(img.Image image) async {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      image.getBytes(),
      image.width,
      image.height,
      ui.PixelFormat.rgba8888,
      (result) => completer.complete(result),
    );
    return completer.future;
  }

  Future<List<ui.Image>> convertImagesToUiImages(List<img.Image> images) async {
    List<Future<ui.Image>> futures =
        images.map((image) => _imageToUiImage(image)).toList();
    return Future.wait(futures);
  }

  Future getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _loadImageDB(File(pickedFile.path));
      }
    });
  }

  Future getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _loadImageDB(File(pickedFile.path));
      }
    });
  }

  Future showOptions() async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: const Text('Photo Gallery'),
            onPressed: () {
              Navigator.of(context).pop();
              getImageFromGallery();
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Camera'),
            onPressed: () {
              Navigator.of(context).pop();
              getImageFromCamera();
            },
          ),
        ],
      ),
    );
  }

  ElevatedButton getColorOptionButton(Color color) {
    if (color == Colors.pink) {
      return ElevatedButton(
        onPressed: () {
          setState(() {
            _currentColorsArray![_selectedIndex!] = color;
            _selectedIndex = null;
          });
        },
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(60, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: const DecorationImage(
              image: AssetImage('assets/brick.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    } else if (color == Colors.transparent) {
      return ElevatedButton(
        onPressed: () {
          setState(() {
            _currentColorsArray![_selectedIndex!] = color;
            _selectedIndex = null;
          });
        },
        style: ElevatedButton.styleFrom(
            fixedSize: const Size(60, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.zero),
        child: const Icon(
          Icons.remove_circle_outline,
          color: Colors.white,
        ),
      );
    } else {
      return ElevatedButton(
          onPressed: () {
            setState(() {
              _currentColorsArray![_selectedIndex!] = color;
              _selectedIndex = null;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: color, // Background color
            fixedSize: const Size(60, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ui.Image>>(
      future: _futureImages,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text('Error loading image');
        } else {
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              if (snapshot.data != null) {
                return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // const SizedBox(height: 180),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Visibility(
                            visible: _image != null,
                            child: Image.file(
                              _image!,
                              width: constraints
                                  .maxWidth, // Escalar imagen de fondo (Ancho del celular)
                              height: constraints.maxWidth * _aspectRatio,
                            ),
                          ),
                          for (var i = 0; i < snapshot.data!.length; i++)
                            CustomPaint(
                              size: Size(
                                  constraints.maxWidth,
                                  constraints.maxWidth *
                                      _aspectRatio), // Escalar mascara (misma dimension que la imagen de fondo)
                              painter: ImageMaskPainter(
                                  snapshot.data![i],
                                  _whitePixelsArray![i],
                                  _currentColorsArray![i],
                                  _texture!),
                            ),
                          for (var i = 0; i < snapshot.data!.length; i++)
                            _selectedIndex == null || _selectedIndex == i
                                ? Positioned(
                                    left: _pickerPositions![i][0] *
                                        constraints.maxWidth,
                                    top: _pickerPositions![i][1] *
                                        (constraints.maxWidth * _aspectRatio),
                                    child: FractionalTranslation(
                                      translation: const Offset(-0.5, -0.5),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: const Size(50, 25),
                                          padding: EdgeInsets.zero,
                                          textStyle:
                                              const TextStyle(fontSize: 11),
                                          backgroundColor:
                                              _labelsArray![i] == 'pared'
                                                  ? Colors.purple.shade900
                                                  : Colors.cyan.shade700,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _selectedIndex = i;
                                          });
                                          // _openColorPicker(i);
                                        },
                                        child: Text(_labelsArray![i]),
                                      ),
                                    ),
                                  )
                                : Container(),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Visibility(
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        visible: _selectedIndex != null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            for (var i = 0;
                                i < _colorOptionButtons!.length;
                                i++)
                              getColorOptionButton(_colorOptionButtons![i])
                          ],
                        ),
                      ),
                    ]);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          );
        }
      },
    );
  }
}

class ImageMaskPainter extends CustomPainter {
  final ui.Image image;
  final ui.Image texture;
  final List<Offset> whitePixels;
  final Color maskColor;

  ImageMaskPainter(this.image, this.whitePixels, this.maskColor, this.texture);

  @override
  void paint(Canvas canvas, Size size) {
    if (maskColor == Colors.pink) {
      var rect = Rect.fromLTRB(0, 0, size.width, size.height);
      // Create the mask paint
      final maskPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.saveLayer(rect, maskPaint);

      // Draw white pixels on the mask
      for (final offset in whitePixels) {
        Offset scaledOffset = Offset(
          (offset.dx / image.width) * size.width,
          (offset.dy / image.height) * size.height,
        );
        canvas.drawCircle(
            scaledOffset, 1, maskPaint); // Adjust the radius as needed
      }
      // Draw the texture only on the white mask areas
      Size inputSize =
          Size(texture.width.toDouble(), texture.height.toDouble());
      final FittedSizes fittedSizes =
          applyBoxFit(BoxFit.cover, inputSize, rect.size);
      final Size sourceSize = fittedSizes.source;
      final Rect sourceRect =
          Alignment.center.inscribe(sourceSize, Offset.zero & inputSize);
      canvas.drawImageRect(
        texture,
        sourceRect,
        rect,
        maskPaint..blendMode = BlendMode.srcIn,
      );

      canvas.restore();
    } else {
      final paint = Paint()
        ..color = Colors.transparent
        ..blendMode = BlendMode.srcOver;
      canvas.drawImage(image, Offset.zero, paint);

      final maskPaint = Paint()
        ..color = maskColor
        ..style = PaintingStyle.fill;

      for (final offset in whitePixels) {
        Offset scaledOffset = Offset((offset.dx / image.width) * size.width,
            (offset.dy / image.height) * size.height);

        canvas.drawCircle(
            scaledOffset, 1, maskPaint); // Adjust the radius as needed
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
