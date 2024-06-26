import 'dart:io';
import 'package:color_picker/demo_view.dart';
import 'package:color_picker/mask_img.dart';
import 'package:flutter/material.dart';

class BottomNavigationBarMasksWidget extends StatefulWidget {
  final File? initialImage;
  const BottomNavigationBarMasksWidget({super.key, this.initialImage});

  @override
  State<BottomNavigationBarMasksWidget> createState() =>
      _BottomNavigationBarMasksState();
}

class _BottomNavigationBarMasksState
    extends State<BottomNavigationBarMasksWidget> {
  int _selectedIndex = 1;
  late List<Widget> _widgetOptions = [];
  File? _image;

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  @override
  void initState() {
    super.initState();
    _image = widget.initialImage;
    setState(() {
      _widgetOptions = <Widget>[
        const Text(
          'Inspiración',
          style: optionStyle,
        ),
        _image != null
            ? MaskImageWidget(
                initialImage: _image,
              )
            : const Center(child: CircularProgressIndicator()),
        const DemoView(),
      ];
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.isNotEmpty
            ? _widgetOptions.elementAt(_selectedIndex)
            : const CircularProgressIndicator(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Inspiración',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.other_houses),
            label: 'Demo',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
