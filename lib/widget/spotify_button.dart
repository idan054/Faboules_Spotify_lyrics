import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SpotifyButton extends StatelessWidget {
  final String spotifyUrl;

  SpotifyButton({required this.spotifyUrl});

  Future<void> _launchSpotify() async {
    await launchUrl(Uri.parse(spotifyUrl));
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _launchSpotify,
      icon: const Icon(
        CupertinoIcons.back,
        color: Colors.white,
        size: 26,
      ),
    );
  }
}
