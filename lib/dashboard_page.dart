// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:developer';

import 'package:entry/entry.dart';
import 'package:faboules/core/langs.dart';
import 'package:faboules/uniModel.dart';
import 'package:faboules/widget/blur_image.dart';
import 'package:faboules/widget/color_viewer.dart';
import 'package:faboules/widget/language_carousel.dart';
import 'package:faboules/widget/spotify_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:spotify/spotify.dart' as s;
import 'package:url_launcher/url_launcher.dart';

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
  bool isLoading = true;
  final fieldNode = FocusNode();

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
    print('imageUrl: ${imageUrl}');

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

            imageUrl == null
                ? buildHomePage(width, _controller)
                : buildMediaLyrics(imageUrl, width, uniModel, _controller),

            // Space below the ListView
          ],
        ),
      ),
    );
  }

  Widget buildHomePage(double width, TextEditingController _controller) {
    var box = Hive.box('myBox');
    var cacheLang = box.get('selectedLang');

    Map<String, String>? selectedLang =
        languages.firstWhere((j) => j['name'] == (cacheLang ?? 'Hebrew'));

    return StatefulBuilder(builder: (context, setState) {
      return Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              // Apply border radius here
              child: Container(
                height: width * 0.9,
                // color: Colors.white10,
                color: Colors.grey[800],
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
          const SizedBox(height: 15),
          Transform.translate(
            offset: Offset(0, -55),
            child: Column(
              children: [
                LanguageCarousel(
                  onLanguageSelected: (int index) {
                    selectedLang = languages[index];

                    setState(() {});
                  },
                ),
                Container(
                  height: 60,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: buildSubText(
                      selectedLang!['subText'].toString(),
                    ),

                    // Text(
                    //   selectedLang!['subText'].toString(),
                    //   textDirection: TextDirection.rtl,
                    //   textAlign: TextAlign.center,
                    //   style: TextStyle(color: Colors.white70, fontSize: 18),
                    // ),
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  // height: 60,
                  margin: const EdgeInsets.only(
                      left: 20, right: 20, top: 5, bottom: 15),
                  child: SizedBox(
                    width: 100,
                    height: 70,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        side: BorderSide(color: Colors.grey[700]!, width: 4),
                        // White border
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              15), // Optional: rounded corners
                        ),
                      ),
                      onPressed: () async {
                        await getSong();
                        getLyricsOnly(_controller.text);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Text(
                          //   'Faboules',
                          //   style: TextStyle(color: Colors.white, fontSize: 14),
                          // ),
                          // SizedBox(width: 8), // Spacing between icon and text

                          Image.asset('assets/logo_ios_transp.png', height: 50),

                          // Icon(
                          //   Icons.music_note,
                          //   color: Colors.white,
                          //   size: 24,
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      );
    });
  }

  Widget buildSubText(String data) {
    void launchSpotify() async {
      await launchUrl(Uri.parse('spotify://'));
    }

    List<TextSpan> _getRichTextSpans(String text) {
      List<TextSpan> spans = [];
      RegExp exp = RegExp(r"(Spotify)");
      Iterable<RegExpMatch> matches = exp.allMatches(text);

      int lastMatchEnd = 0;
      for (var match in matches) {
        // Add text before the match
        if (match.start > lastMatchEnd) {
          spans.add(TextSpan(
            text: text.substring(lastMatchEnd, match.start),
          ));
        }

        // Add "Spotify" with custom style and link functionality
        spans.add(TextSpan(
          text: 'Spotify',
          style: const TextStyle(
            // color: Colors.blue,
            color: Colors.white70,
            fontSize: 18,
            // fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              // Open Spotify link
              launchSpotify();
            },
        ));

        lastMatchEnd = match.end;
      }

      // Add any remaining text after the last match
      if (lastMatchEnd < text.length) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd)));
      }

      return spans;
    }

    return RichText(
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
      text: TextSpan(
        children: _getRichTextSpans(data),
        style: TextStyle(color: Colors.white70, fontSize: 18), // Default style
      ),
    );
  }

  Entry buildMediaLyrics(String? imageUrl, double width, UniModel uniModel,
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
            borderRadius: BorderRadius.circular(10),
            // Apply border radius here
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
                          onSubmitted: (value) =>
                              getLyricsOnly(_controller.text),
                          focusNode: fieldNode,
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
                  InkWell(
                    // child: Icon(
                    //   // Icons.play_circle_outline,
                    //   Icons.music_note_sharp,
                    //   color: Colors.white,
                    //   size: 36,
                    // ),

                    // child: Image.asset(
                    //   'assets/logo_ios_transp.png',
                    //   height: 45,
                    // ),

                    // child: Container(
                    //   width: 32, // Adjust the size as needed
                    //   height: 32,
                    //   decoration: BoxDecoration(
                    //     shape: BoxShape.circle,
                    //     border: Border.all(
                    //       color: Colors.white, // Border color
                    //       width: 2, // Border thickness
                    //     ),
                    //   ),
                    //   child: CircleAvatar(
                    //     backgroundColor: Colors.transparent,
                    //     child: Transform.translate(
                    //       offset: Offset(0.0, 0.0),
                    //       child: ColorFiltered(
                    //         colorFilter: ColorFilter.mode(
                    //           Colors.white,
                    //           BlendMode.srcIn,
                    //         ),
                    //         child: Image.asset(
                    //           'assets/logo_ios_note.png',
                    //           height: 20,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),

                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                      child: Image.asset(
                        'assets/circle_music_note.png',
                        height: 32,
                      ),
                    ),
                    onTap: () async {
                      await getSong();
                      getLyricsOnly(_controller.text);
                    },
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                      child: Icon(
                        fieldNode.hasFocus
                            ? Icons.check_circle_outline_outlined
                            : Icons.downloading,
                        // Icons.translate_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                      onTap: () async => fieldNode.hasFocus
                          ? getLyricsOnly(_controller.text)
                          : fieldNode.requestFocus(),
                      onLongPress: () {
                        // Extract track name and remove everything after "-" or "("
                        final txt = (uniModel.track?.name.toString() ?? '');
                        final cleanedTxt =
                            txt.split(RegExp(r'\s*[-(].*')).first.trim();
                        getLyricsOnly(cleanedTxt);
                      }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          buildLyricsCards(isLoading),
          const SizedBox(height: 40),
        ],
      )),
    );
  }

  Future getLyricsOnly(String query) async {
    isLoading = true;
    lyrics = [];
    translatedLines = [];
    _selectedLineIndices = Set();
    fieldNode.unfocus();
    setState(() {});

    final songPath = await LyricsServices.getSongPath(q: query);
    print('songPath: ${songPath}');
    lyrics = await LyricsServices.fetchLyrics(songPath)
        .then((result) => LyricsServices.cleanLyrics(result));
    translatedLines = await LyricsServices.translatedLyrics(lyrics)
        .then((result) => LyricsServices.cleanLyrics(result));

    isLoading = false;
    setState(() {});
  }

  Future getSong() async {
    lyrics = [];
    translatedLines = [];
    _selectedLineIndices = Set();
    isLoading = true;
    setState(() {});

    await context.read<UniModel>().setTrackFromClipboard();

    final imageUrl = context.read<UniModel>().track?.album?.images?[1].url;

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

  Widget buildLyricsCards(bool isLoading) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: isLoading ? 10 : lyrics.length,
      itemBuilder: (context, index) {
        if (isLoading) {
          lyrics = List<String>.filled(20, 'Well, U find my Easter Egg!');
          translatedLines = lyrics;
        }

        final isHebrewText = _isHebrew(lyrics[index]);
        final isHebrewTranslatedText = _isHebrew(translatedLines[index]);

        final content = Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
          ),
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Card(
            margin: EdgeInsets.zero,
            elevation: isLoading ? 0 : 10,
            color: vibrantColor?.withOpacity(0.90),
            child: ListTile(
              splashColor: Colors.transparent,
              title: Text(
                lyrics[index],
                style: const TextStyle(color: Colors.white),
                textAlign: isHebrewText ? TextAlign.right : TextAlign.left,
              ),
              subtitle: _selectedLineIndices.contains(index)
                  ? Directionality(
                      textDirection:
                          isHebrewText ? TextDirection.rtl : TextDirection.ltr,
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
        );

        return Entry.opacity(
          duration: const Duration(milliseconds: 400),
          child: isLoading
              ? Shimmer.fromColors(
                  baseColor: Colors.black12,
                  highlightColor: Colors.black38,
                  child: content,
                )
              : content,
        );
      },
    );
  }

  // Card _buildMainSearch() {
  //   final _controller = context.read<UniModel>().controller;
  //
  //   return Card(
  //     color: Colors.white.withOpacity(0.2),
  //     child: Padding(
  //         padding: const EdgeInsets.all(8.0),
  //         child: Row(
  //           children: [
  //             IconButton(
  //                 icon: Icon(Icons.music_note, color: Colors.white),
  //                 onPressed: () async {
  //                   await context.read<UniModel>().setTrackFromClipboard();
  //
  //                   final imageUrl =
  //                       context.read<UniModel>().track?.album?.images?[1].url;
  //                   print('X imageUrl: ${imageUrl}');
  //                   final PaletteGenerator paletteGenerator =
  //                       await PaletteGenerator.fromImageProvider(
  //                     NetworkImage(imageUrl ?? ''),
  //                   );
  //                   dominantColor = paletteGenerator.dominantColor?.color ??
  //                       Colors.transparent;
  //                   darkMutedColor = paletteGenerator.darkMutedColor?.color ??
  //                       Colors.transparent;
  //
  //                   vibrantColor = paletteGenerator.vibrantColor?.color ??
  //                       Colors.transparent;
  //
  //                   setState(() {});
  //                 }),
  //             Expanded(
  //               child: TextField(
  //                 controller: _controller,
  //                 style: TextStyle(color: Colors.white),
  //                 decoration: const InputDecoration(
  //                   hintText: 'Song name + Artist',
  //                   hintStyle: TextStyle(color: Colors.white54),
  //                   border: InputBorder.none,
  //                 ),
  //               ),
  //             ),
  //             IconButton(
  //               icon: Icon(Icons.send, color: Colors.white),
  //               onPressed: () async {
  //                 final songPath =
  //                     await LyricsServices.getSongPath(_controller.text);
  //                 lyrics = await LyricsServices.fetchLyrics(songPath);
  //                 translatedLines =
  //                     await LyricsServices.translatedLyrics(lyrics);
  //
  //                 setState(() {});
  //               },
  //             ),
  //           ],
  //         )),
  //   );
  // }

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
            'Trance',
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
