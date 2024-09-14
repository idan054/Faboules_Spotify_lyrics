import 'dart:ui';
import 'package:flutter/material.dart';

class BlurryImage extends StatelessWidget {
  final String imageUrl;
  final double blurAmount;

  BlurryImage({required this.imageUrl, this.blurAmount = 10.0});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          imageUrl,
          fit: BoxFit.cover,
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
          child: Container(
            color: Colors.black.withOpacity(0),
          ),
        ),
      ],
    );
  }
}
