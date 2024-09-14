// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:developer';

import 'package:entry/entry.dart';
import 'package:faboules/uniModel.dart';
import 'package:faboules/widget/blur_image.dart';
import 'package:faboules/widget/color_viewer.dart';
import 'package:faboules/widget/spotify_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';
import 'package:spotify/spotify.dart' as s;

import 'lyrics_services.dart';

class LyricsTranslator extends StatefulWidget {
  @override
  _LyricsTranslatorState createState() => _LyricsTranslatorState();
}

class _LyricsTranslatorState extends State<LyricsTranslator> {
  List<String> lyrics = [];
  List<String> translatedLines = [];
  Color? dominantColor = Colors.grey[900];
  Color? darkMutedColor = Colors.grey[900];
  Color? vibrantColor = Colors.grey[900];
  Color? darkVibrantColor = Colors.grey[900];

  Set<int> _selectedLineIndices = Set();

  bool _isHebrew(String text) {
    final hebrewRegex = RegExp(r'[\u0590-\u05FF]');
    return hebrewRegex.hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    final uniModel = context.watch<UniModel>();
    final imageUrl = uniModel.track?.album?.images?[1].url;
    final _controller = context.read<UniModel>().controller;

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: vibrantColor,
      // appBar: ,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        // color: vibrantColor,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            // colors: [vibrantColor!, Colors.black.withOpacity(0.6)],
            colors: [
              vibrantColor!,
              Colors.grey[900]!,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          children: [
            buildAppBar(),
            // if (imageUrl != null) MainColorExtractor(imageUrl: imageUrl ?? ''),

            const SizedBox(height: 30),
            // if (kDebugMode)Text(uniModel.clipboard ?? '', style: TextStyle(color: Colors.white),),
            if (uniModel.track?.previewUrl != null)
              buildFaboulesLyrics(imageUrl, width, uniModel, _controller),

            // buildMainSearch(),

            if (uniModel.track?.previewUrl == null) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(10), // Apply border radius here
                  child: Container(
                    height: width * 0.9,
                    color: Colors.white10,
                    child: Center(
                      child: Icon(
                        Icons.album,
                        color: Colors.white.withOpacity(0.25),
                        size: width * 0.4,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: 60,
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: Colors.white, width: 3), // White border
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          99), // Optional: rounded corners
                    ),
                  ),
                  onPressed: () async {
                    await getSong();
                    print('START: _controller()');
                    getLyrics(_controller);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Text(
                      //   'Faboules',
                      //   style: TextStyle(color: Colors.white, fontSize: 14),
                      // ),
                      // SizedBox(width: 8), // Spacing between icon and text
                      Icon(
                        Icons.music_note,
                        color: Colors.white,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              )
            ],

            const SizedBox(height: 20),
            buildLyricsCards(),
            const SizedBox(height: 40),
            // Space below the ListView
          ],
        ),
      ),
    );
  }

  Entry buildFaboulesLyrics(String? imageUrl, double width, UniModel uniModel,
      TextEditingController _controller) {
    return Entry.opacity(
      duration: const Duration(milliseconds: 600),
      child: Container(
          // padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          // color: cardColor,
          // color: Colors.transparent,
          // width: width * 0.9,
          // height: width * 0.9,
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10), // Apply border radius here
            child: FadeInImage.assetNetwork(
              fadeInDuration: const Duration(milliseconds: 200),
              placeholder: '',
              image: imageUrl ?? '',
              width: width * 0.9,
              height: width * 0.9,
              fit: BoxFit.cover, // Ensure the image covers the box
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: SizedBox(
              width: width * 0.9,
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: width * 0.6,
                        child: Text(
                          overflow: TextOverflow.ellipsis,
                          uniModel.track?.name.toString() ?? '',
                          style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        width: width * 0.6,
                        child: TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            isDense: true, // Removes vertical padding
                            contentPadding: EdgeInsets.zero,
                            // focusedBorder: InputBorder.none,
                          ),
                          controller: _controller,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    // icon: Icon(
                    //   Icons.play_circle_outline,
                    //   color: Colors.white,
                    //   size: 36,
                    // ),
                    icon: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                      child: Image.asset(
                        'assets/circle_music_note.png',
                        height: 32,
                      ),
                    ),
                    onPressed: () async {
                      await getSong();
                      print('START: _controller()');
                      getLyrics(_controller);
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.downloading,
                      color: Colors.white,
                      size: 36,
                    ),
                    onPressed: () async => getLyrics(_controller),
                  ),
                ],
              ),
            ),
          )
        ],
      )),
    );
  }

  Future getLyrics(_controller) async {
    lyrics = [];
    translatedLines = [];
    setState(() {});

    final songPath = await LyricsServices.getSongPath(_controller.text);
    print('songPath: ${songPath}');
    lyrics = await LyricsServices.fetchLyrics(songPath);
    translatedLines = await LyricsServices.translatedLyrics(lyrics);

    setState(() {});
  }

  Future getSong() async {
    lyrics = [];
    translatedLines = [];
    setState(() {});

    await context.read<UniModel>().setTrackFromClipboard();

    final imageUrl = context.read<UniModel>().track?.album?.images?[1].url;
    print('imageUrl: ${imageUrl}');
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(
      NetworkImage(imageUrl ?? ''),
    );
    dominantColor = paletteGenerator.dominantColor?.color ?? Colors.transparent;

    darkMutedColor = paletteGenerator.mutedColor?.color ?? Colors.transparent;

    vibrantColor = paletteGenerator.vibrantColor?.color ?? Colors.transparent;

    darkVibrantColor = vibrantColor =
        paletteGenerator.darkVibrantColor?.color ?? Colors.transparent;

    setState(() {});
  }

  Widget buildLyricsCards() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: lyrics.length,
      itemBuilder: (context, index) {
        final isHebrewText = _isHebrew(lyrics[index]);
        final isHebrewTranslatedText = _isHebrew(translatedLines[index]);

        return Entry.opacity(
          duration: const Duration(milliseconds: 600),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
            ),
            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Card(
              margin: EdgeInsets.zero,
              elevation: 10,
              // color: Colors.white.withOpacity(0.1),
              color: vibrantColor?.withOpacity(0.90),
              // color: darkVibrantColor,
              // color: darkMutedColor,
              child: ListTile(
                title: Text(
                  lyrics[index],
                  style: const TextStyle(color: Colors.white),
                  textAlign: isHebrewText ? TextAlign.right : TextAlign.left,
                ),
                subtitle: _selectedLineIndices.contains(index)
                    ? Directionality(
                        textDirection: isHebrewText
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        child: Text(
                          textAlign: isHebrewTranslatedText
                              ? TextAlign.right
                              : TextAlign.left,
                          translatedLines.isNotEmpty &&
                                  index < translatedLines.length
                              ? translatedLines[index]
                              : '',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.70),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
                onTap: () {
                  if (_selectedLineIndices.contains(index)) {
                    _selectedLineIndices.remove(index);
                  } else {
                    _selectedLineIndices.add(index);
                  }
                  setState(() {});
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Card buildMainSearch() {
    final _controller = context.read<UniModel>().controller;

    return Card(
      color: Colors.white.withOpacity(0.2),
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              IconButton(
                  icon: Icon(Icons.music_note, color: Colors.white),
                  onPressed: () async {
                    await context.read<UniModel>().setTrackFromClipboard();

                    final imageUrl =
                        context.read<UniModel>().track?.album?.images?[1].url;
                    print('imageUrl: ${imageUrl}');
                    final PaletteGenerator paletteGenerator =
                        await PaletteGenerator.fromImageProvider(
                      NetworkImage(imageUrl ?? ''),
                    );
                    dominantColor = paletteGenerator.dominantColor?.color ??
                        Colors.transparent;
                    darkMutedColor = paletteGenerator.darkMutedColor?.color ??
                        Colors.transparent;

                    vibrantColor = paletteGenerator.vibrantColor?.color ??
                        Colors.transparent;

                    setState(() {});
                  }),
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Song name + Artist',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send, color: Colors.white),
                onPressed: () async {
                  final songPath =
                      await LyricsServices.getSongPath(_controller.text);
                  lyrics = await LyricsServices.fetchLyrics(songPath);
                  translatedLines =
                      await LyricsServices.translatedLyrics(lyrics);

                  setState(() {});
                },
              ),
            ],
          )),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      // backgroundColor: vibrantColor,
      backgroundColor: Colors.transparent,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SpotifyButton(
            spotifyUrl:
                'spotify://', // Or a specific URI, e.g., 'spotify:track:34aKXUhVdHGTzWOt85RjGq'
          ),

          // Image.network(
          //   'https://media.newyorker.com/photos/59095bb86552fa0be682d9d0/master/pass/Monkey-Selfie.jpg',
          //   width: 40,
          //   height: 40,
          // ),
          const Spacer(
            flex: 40,
          ),
          Text(
            'Faboules',
            style: GoogleFonts.rubik(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const Spacer(
            flex: 60,
          ),
        ],
      ),
      centerTitle: true,
    );
  }
}
