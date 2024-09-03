// ignore_for_file: avoid_print

// import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:ditredi/ditredi.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class ApiResponse {
  ApiResponse({
    required this.walls,
    required this.floor,
    required this.wallContours,
    required this.wallSegments,
  });

  final List<Wall> walls;
  final Floor? floor;
  final List<List<List<List<int>>>> wallContours;
  final List<WallSegment> wallSegments;

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      walls: json["walls"] == null
          ? []
          : List<Wall>.from(json["walls"]!.map((x) => Wall.fromJson(x))),
      floor: json["floor"] == null ? null : Floor.fromJson(json["floor"]),
      wallContours: json["wallContours"] == null
          ? []
          : List<List<List<List<int>>>>.from(json["wallContours"]!.map((x) =>
              x == null
                  ? []
                  : List<List<List<int>>>.from(x!.map((x) => x == null
                      ? []
                      : List<List<int>>.from(x!.map((x) => x == null
                          ? []
                          : List<int>.from(x!.map((x) => x)))))))),
      wallSegments: json["wallSegments"] == null
          ? []
          : List<WallSegment>.from(
              json["wallSegments"]!.map((x) => WallSegment.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "walls": walls.map((x) => x?.toJson()).toList(),
        "floor": floor?.toJson(),
        "wallContours": wallContours
            .map((x) => x
                .map((x) => x.map((x) => x.map((x) => x).toList()).toList())
                .toList())
            .toList(),
        "wallSegments": wallSegments.map((x) => x?.toJson()).toList(),
      };

  @override
  String toString() {
    return "$walls, $floor, $wallContours, $wallSegments, ";
  }
}

class Floor {
  Floor({
    required this.points,
  });

  final List<Point> points;

  factory Floor.fromJson(Map<String, dynamic> json) {
    return Floor(
      points: json["points"] == null
          ? []
          : List<Point>.from(json["points"]!.map((x) => Point.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "points": points.map((x) => x?.toJson()).toList(),
      };

  @override
  String toString() {
    return "$points, ";
  }
}

class Point {
  Point({
    required this.y,
    required this.x,
  });

  final num? y;
  final num? x;

  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(
      y: json["y"],
      x: json["x"],
    );
  }

  Map<String, dynamic> toJson() => {
        "y": y,
        "x": x,
      };

  @override
  String toString() {
    return "$y, $x, ";
  }
}

class WallSegment {
  WallSegment({
    required this.area,
    required this.height,
    required this.wallId,
    required this.wallNormal,
    required this.width,
    required this.points,
  });

  final double? area;
  final double? height;
  final int? wallId;
  final WallNormal? wallNormal;
  final double? width;
  final List<WallNormal> points;

  factory WallSegment.fromJson(Map<String, dynamic> json) {
    return WallSegment(
      area: json["area"],
      height: json["height"],
      wallId: json["wall_id"],
      wallNormal: json["wall_normal"] == null
          ? null
          : WallNormal.fromJson(json["wall_normal"]),
      width: json["width"],
      points: json["points"] == null
          ? []
          : List<WallNormal>.from(
              json["points"]!.map((x) => WallNormal.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "area": area,
        "height": height,
        "wall_id": wallId,
        "wall_normal": wallNormal?.toJson(),
        "width": width,
        "points": points.map((x) => x?.toJson()).toList(),
      };

  @override
  String toString() {
    return "$area, $height, $wallId, $wallNormal, $width, $points, ";
  }
}

class WallNormal {
  WallNormal({
    required this.z,
    required this.y,
    required this.x,
  });

  final num? z;
  final num? y;
  final num? x;

  factory WallNormal.fromJson(Map<String, dynamic> json) {
    return WallNormal(
      z: json["z"],
      y: json["y"],
      x: json["x"],
    );
  }

  Map<String, dynamic> toJson() => {
        "z": z,
        "y": y,
        "x": x,
      };

  @override
  String toString() {
    return "$z, $y, $x, ";
  }
}

class Wall {
  Wall({
    required this.cy,
    required this.wallId,
    required this.points,
    required this.cx,
  });

  final num? cy;
  final int? wallId;
  final List<Point> points;
  final num? cx;

  factory Wall.fromJson(Map<String, dynamic> json) {
    return Wall(
      cy: json["cy"],
      wallId: json["wall_id"],
      points: json["points"] == null
          ? []
          : List<Point>.from(json["points"]!.map((x) => Point.fromJson(x))),
      cx: json["cx"],
    );
  }

  Map<String, dynamic> toJson() => {
        "cy": cy,
        "wall_id": wallId,
        "points": points.map((x) => x?.toJson()).toList(),
        "cx": cx,
      };

  @override
  String toString() {
    return "$cy, $wallId, $points, $cx, ";
  }
}

class TestImageWidget extends StatefulWidget {
  final File? initialImage;

  const TestImageWidget({super.key, this.initialImage});

  @override
  _TestImageWidgetState createState() => _TestImageWidgetState();
}

class _TestImageWidgetState extends State<TestImageWidget> {
  final picker = ImagePicker();
  File? _image;
  double _aspectRatio = 0.0;
  // List<List<Offset>>? _whitePixelsArray;
  // Color _currentColor = Colors.transparent;
  // Future<List<ui.Image>>? _futureImages;
  // List<Color>? _currentColorsArray;
  // List<dynamic>? _pickerPositions;
  // List<String>? _labelsArray;
  // int? _selectedIndex;
  // ui.Image? _texture;
  // List<Color>? _colorOptionButtons;

  Future<ui.Image>? _futureImage;
  List<Wall>? _walls;
  // Floor? _floor;
  // List<List<List<List<int>>>>? _wallContours;
  // List<Floor>? _pointsI;
  // List<Floor>? _pointsIi;

  List<WallSegment>? _wallSegments;
  // "points": [
  //         { "z": -3.6027064323425293, "y": 1.6442946195602417, "x": -2.897993326187134 },
  //         { "z": -8.399847984313965, "y": 1.6442946195602417, "x": -3.2349252700805664 },
  //         { "z": -3.6027064323425293, "y": -1.5, "x": -2.897993326187134 },
  //         { "z": -8.399847984313965, "y": -1.5, "x": -3.2349252700805664 }
  //       ]

  @override
  void initState() {
    super.initState();
    _image = widget.initialImage;
    _loadImageDB(_image!);
    // _colorOptionButtons = [
    //   Colors.deepPurple.shade900,
    //   Colors.teal.shade900,
    //   Colors.deepOrange.shade900,
    //   Colors.pink,
    //   Colors.transparent
    // ];
  }

  // Future<ui.Image> loadUiImage(String assetPath) async {
  //   final Completer<ui.Image> completer = Completer();
  //   final ByteData data = await rootBundle.load(assetPath);
  //   final Uint8List bytes = data.buffer.asUint8List();
  //   ui.decodeImageFromList(bytes, (ui.Image img) {
  //     completer.complete(img);
  //   });
  //   return completer.future;
  // }

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.create(recursive: true);
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  Future<void> _loadImageDB(File imageFile) async {
    // _texture = await loadUiImage('assets/brick.jpg');
    print('Testinggg..... $_image');
    // final bytes = await imageFile.readAsBytes();
    var response = await http.post(Uri.parse(
        "https://bc14-2806-2f0-91a0-68bf-7ca1-a773-34b-84e5.ngrok-free.app/segment"));

    print('Testinggg res..... $response');

    if (response.statusCode == 200) {
      // List<Wall> walls = json.decode(response.body)['walls'] as List<Wall>;
      // String mask = json.decode(response.body)['mask'] as String;
      ApiResponse apiResponse =
          ApiResponse.fromJson(json.decode(response.body));
      // print('mask ${apiResponse.mask}');
      img.Image image;
      Future<ui.Image> futureImage;
      Uint8List imageBytes;
      // if (apiResponse.mask != null) {
      //   imageBytes = base64Decode(apiResponse.mask!);
      //   print('imageBytes $imageBytes');
      // } else {
      File myFile = await getImageFileFromAssets('imgs/image5.jpg');
      imageBytes = await myFile.readAsBytes();
      print('imageBytes $imageBytes');
      // }
      image = img.decodeImage(imageBytes)!;
      print(
          'aspect ${image.height} ${image.width} ${image.height / image.width}');
      print('image $image');
      futureImage = _imageToUiImage(image);
      print('futureImage $futureImage');
      setState(() {
        _aspectRatio = image.height / image.width;
        _futureImage = futureImage;
        _walls = apiResponse.walls;
        // _floor = apiResponse.floor;
        // _wallContours = apiResponse.wallContours;
        // _pointsI = apiResponse.pointsI;
        // _pointsIi = apiResponse.pointsIi;
        _wallSegments = apiResponse.wallSegments;
      });
      print('Testinggg colors..... ${apiResponse.wallContours[0][0][0]}');
    } else {
      // Handle the error
      throw Exception('Failed to load image');
    }
  }

  // List<Offset> detectWhitePixels(img.Image image) {
  //   final List<Offset> whitePixels = [];
  //   print('Dimensiones de mascara');
  //   print(image.width);
  //   print(image.height);
  //   for (int y = 0; y < image.height; y++) {
  //     for (int x = 0; x < image.width; x++) {
  //       final pixel = image.getPixel(x, y);
  //       final int r = img.getRed(pixel);
  //       final int g = img.getGreen(pixel);
  //       final int b = img.getBlue(pixel);
  //       final int a = img.getAlpha(pixel);
  //       if (r == 255 && g == 255 && b == 255 && a == 255) {
  //         whitePixels.add(Offset(x.toDouble(), y.toDouble()));
  //       }
  //     }
  //   }
  //   return whitePixels;
  // }

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

  // Future<List<ui.Image>> convertImagesToUiImages(List<img.Image> images) async {
  //   List<Future<ui.Image>> futures =
  //       images.map((image) => _imageToUiImage(image)).toList();
  //   return Future.wait(futures);
  // }

  // Future getImageFromGallery() async {
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  //   setState(() {
  //     if (pickedFile != null) {
  //       _image = File(pickedFile.path);
  //       _loadImageDB(File(pickedFile.path));
  //     }
  //   });
  // }

  // Future getImageFromCamera() async {
  //   final pickedFile = await picker.pickImage(source: ImageSource.camera);
  //   setState(() {
  //     if (pickedFile != null) {
  //       _image = File(pickedFile.path);
  //       _loadImageDB(File(pickedFile.path));
  //     }
  //   });
  // }

  // Future showOptions() async {
  //   showCupertinoModalPopup(
  //     context: context,
  //     builder: (context) => CupertinoActionSheet(
  //       actions: [
  //         CupertinoActionSheetAction(
  //           child: const Text('Photo Gallery'),
  //           onPressed: () {
  //             Navigator.of(context).pop();
  //             getImageFromGallery();
  //           },
  //         ),
  //         CupertinoActionSheetAction(
  //           child: const Text('Camera'),
  //           onPressed: () {
  //             Navigator.of(context).pop();
  //             getImageFromCamera();
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // ElevatedButton getColorOptionButton(Color color) {
  //   if (color == Colors.pink) {
  //     return ElevatedButton(
  //       onPressed: () {
  //         setState(() {
  //           _currentColorsArray![_selectedIndex!] = color;
  //           _selectedIndex = null;
  //         });
  //       },
  //       style: ElevatedButton.styleFrom(
  //         fixedSize: const Size(60, 60),
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(10),
  //         ),
  //         padding: EdgeInsets.zero,
  //       ),
  //       child: Container(
  //         width: 60,
  //         height: 60,
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(10),
  //           image: const DecorationImage(
  //             image: AssetImage('assets/brick.jpg'),
  //             fit: BoxFit.cover,
  //           ),
  //         ),
  //       ),
  //     );
  //   } else if (color == Colors.transparent) {
  //     return ElevatedButton(
  //       onPressed: () {
  //         setState(() {
  //           _currentColorsArray![_selectedIndex!] = color;
  //           _selectedIndex = null;
  //         });
  //       },
  //       style: ElevatedButton.styleFrom(
  //           fixedSize: const Size(60, 60),
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //           padding: EdgeInsets.zero),
  //       child: const Icon(
  //         Icons.remove_circle_outline,
  //         color: Colors.white,
  //       ),
  //     );
  //   } else {
  //     return ElevatedButton(
  //         onPressed: () {
  //           setState(() {
  //             _currentColorsArray![_selectedIndex!] = color;
  //             _selectedIndex = null;
  //           });
  //         },
  //         style: ElevatedButton.styleFrom(
  //           backgroundColor: color, // Background color
  //           fixedSize: const Size(60, 60),
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //         ),
  //         child: null);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.Image>(
      future: _futureImage,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text('Error loading image');
        } else {
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              print(snapshot.data);
              if (snapshot.data != null && _walls != null) {
                return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: Size(
                                constraints.maxWidth,
                                constraints.maxWidth *
                                    _aspectRatio), // Escalar mascara (misma dimension que la imagen de fondo)
                            painter: ImageMaskPainter2(snapshot.data!, _walls!),
                          ),
                          // SizedBox(
                          //     width: 100,
                          //     height: 100,
                          //     child: DiTreDi(
                          //       figures: [
                          //         Line3D(vm.Vector3(0, 0, 0),
                          //             vm.Vector3(10, 10, 10),
                          //             width: 10, color: Colors.amber),
                          //       ],
                          //     )),
                          SizedBox(
                              width: 100,
                              height: 100,
                              child: DiTreDi(
                                figures: [
                                  Point3D(vm.Vector3(0, 0, 0),
                                      width: 2, color: Colors.red),
                                ],
                              )),
                          for (final wall in _wallSegments!)
                            // Text(segment.points.toString())
                            for (final segment in wall.points)
                              // Text(segment.toString())
                              SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: DiTreDi(
                                    figures: [
                                      Point3D(
                                          vm.Vector3(
                                              segment.x as double,
                                              segment.y as double,
                                              segment.z as double),
                                          color: Colors.green),
                                    ],
                                  ))
                        ],
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

class ImageMaskPainter2 extends CustomPainter {
  final ui.Image image;
  final List<Wall> walls;
  // final Floor floor;
  // final List<List<List<List<int>>>> wallContours;
  // final List<Floor> pointsI;
  // final List<Floor> pointsIi;

  ImageMaskPainter2(this.image, this.walls);

  @override
  void paint(Canvas canvas, Size size) {
    print('walls $walls');
    var rect = Rect.fromLTRB(0, 0, size.width, size.height);
    final maskPaint = Paint()..style = PaintingStyle.fill;

    Size inputSize = Size(image.width.toDouble(), image.height.toDouble());
    final FittedSizes fittedSizes =
        applyBoxFit(BoxFit.cover, inputSize, rect.size);
    final Size sourceSize = fittedSizes.source;
    final Rect sourceRect =
        Alignment.center.inscribe(sourceSize, Offset.zero & inputSize);
    canvas.drawImageRect(
      image,
      sourceRect,
      rect,
      maskPaint,
    );

    // final maskPaint = Paint()
    //   ..color = maskColor
    //   ..style = PaintingStyle.fill;

    // print('HEREEEE ${wallContours[0][0][0]}');
    double aR = image.height / image.width;
    Path path = Path();
    path.moveTo(size.width * 0, size.height * 0); // Start point
    // for (final offset in wallContours[0]) {
    //   final List<int> point = offset[0];
    //   final int x = point[0];
    //   final int y = point[1];
    //   // print('object $aR');
    //   // // Offset scaledOffset = Offset((x) * size.width, (y) * size.height);
    //   // // (image.width / 1.58) = 2560
    //   // // aspectrati * 2560(image.height / 1.58)
    //   // // The maximum image width is 2560, if the image is larger it will rescale

    //   double offsetX = (x / (image.width)) * size.width;
    //   double offsetY = (y / (image.height)) * size.height;
    //   // print(
    //   //     'offsets ${(image.width / 1.58)} ${(image.height / 1.58)}, 2560 ${(aR * 2560)}');
    //   // Offset scaledOffset = Offset(offsetX, offsetY);

    //   // canvas.drawCircle(
    //   //     scaledOffset,
    //   //     3,
    //   //     maskPaint
    //   //       ..color = Colors.blue
    //   //       ..style = PaintingStyle.fill);

    //   path.lineTo(offsetX, offsetY);
    // }
    path.close(); // Close the path

    canvas.drawPath(path, maskPaint..color = Colors.blue);

    // for (final offset in wallContours[1]) {
    //   final List<int> point = offset[0];
    //   final int x = point[0];
    //   final int y = point[1];
    //   print('object $aR');
    //   // Offset scaledOffset = Offset((x) * size.width, (y) * size.height);
    //   // (image.width / 1.58) = 2560
    //   // aspectrati * 2560(image.height / 1.58)

    //   double offsetX = (x / (image.width)) * size.width;
    //   double offsetY = (y / (image.height)) * size.height;
    //   print(
    //       'offsets ${(image.width / 1.58)} ${(image.height / 1.58)}, 2560 ${(aR * 2560)}');
    //   Offset scaledOffset = Offset(offsetX, offsetY);

    //   canvas.drawCircle(
    //       scaledOffset,
    //       3,
    //       maskPaint
    //         ..color = Colors.pink
    //         ..style = PaintingStyle.fill);
    // }

    // for (final wall in walls) {
    //   for (final offset in wall.points) {
    //     Offset scaledOffset =
    //         Offset((offset.x!) * size.width, (offset.y!) * size.height);

    //     canvas.drawCircle(
    //         scaledOffset,
    //         5,
    //         maskPaint
    //           ..color = Colors.orange
    //           ..style = PaintingStyle.fill); // Adjust the radius as needed
    //   }
    // }

    // for (final wall in pointsI) {
    //   for (final offset in wall.points) {
    //     Offset scaledOffset =
    //         Offset((offset.x!) * size.width, (offset.y!) * size.height);

    //     canvas.drawCircle(
    //         scaledOffset,
    //         5,
    //         maskPaint
    //           ..color = Colors.purple
    //           ..style = PaintingStyle.fill); // Adjust the radius as needed
    //   }
    // }

    // for (final wall in pointsIi) {
    //   for (final offset in wall.points) {
    //     Offset scaledOffset = Offset(((offset.x! + 1) / 2) * size.width,
    //         ((offset.y! + 1) / 2) * size.height);

    //     canvas.drawCircle(
    //         scaledOffset,
    //         5,
    //         maskPaint
    //           ..color = Colors.cyan
    //           ..style = PaintingStyle.fill); // Adjust the radius as needed
    //   }
    // }

    // for (final offset in floor.points) {
    //   print(
    //       'Point ${offset.x!} ${offset.y!} ${(offset.x! / image.width) * size.width}');
    //   Offset scaledOffset =
    //       Offset((offset.x!) * size.width, (offset.y!) * size.height);

    //   canvas.drawCircle(
    //       scaledOffset,
    //       5,
    //       maskPaint
    //         ..color = Colors.blue
    //         ..style = PaintingStyle.fill); // Adjust the radius as needed
    // }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
