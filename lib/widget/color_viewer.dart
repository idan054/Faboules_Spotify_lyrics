import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class MainColorExtractor extends StatefulWidget {
  final String imageUrl;

  MainColorExtractor({required this.imageUrl});

  @override
  _MainColorExtractorState createState() => _MainColorExtractorState();
}

class _MainColorExtractorState extends State<MainColorExtractor> {
  Color _dominantColor = Colors.transparent;
  Color _vibrantColor = Colors.transparent;
  Color _mutedColor = Colors.transparent;
  Color _lightVibrantColor = Colors.transparent;
  Color _lightMutedColor = Colors.transparent;
  Color _darkMutedColor = Colors.transparent;
  Color _darkVibrantColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _extractColors();
  }

  Future<void> _extractColors() async {
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(
      NetworkImage(widget.imageUrl),
    );
    _dominantColor =
        paletteGenerator.dominantColor?.color ?? Colors.transparent;
    _vibrantColor = paletteGenerator.vibrantColor?.color ?? Colors.transparent;
    _mutedColor = paletteGenerator.mutedColor?.color ?? Colors.transparent;
    _lightVibrantColor =
        paletteGenerator.lightVibrantColor?.color ?? Colors.transparent;
    _lightMutedColor =
        paletteGenerator.lightMutedColor?.color ?? Colors.transparent;

    _darkMutedColor =
        paletteGenerator.darkMutedColor?.bodyTextColor ?? Colors.transparent;
    _darkVibrantColor =
        paletteGenerator.darkVibrantColor?.color ?? Colors.transparent;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Wrap(
        children: [
          _buildColorContainer('Dominant Color', _dominantColor),
          _buildColorContainer('Vibrant Color', _vibrantColor),
          _buildColorContainer('Muted Color', _mutedColor),
          _buildColorContainer('Light Vibrant Color', _lightVibrantColor),
          _buildColorContainer('Light Muted Color', _lightMutedColor),
          _buildColorContainer('darkMutedColor', _darkMutedColor),
          _buildColorContainer('darkVibrantColor', _darkVibrantColor),
        ],
      ),
    );
  }

  Widget _buildColorContainer(String name, Color color) {
    return Container(
      margin: EdgeInsets.all(8.0),
      padding: EdgeInsets.all(16.0),
      color: color,
      child: Center(
        child: Text(
          '$name\nHex: ${colorToHex(color)}',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }
}

void main() {
  runApp(MaterialApp(
    home: MainColorExtractor(
      imageUrl:
          'https://i.scdn.co/image/ab67616d0000b273d3a7fd4d957030f16d2b557f', // Replace with your image URL
    ),
  ));
}
