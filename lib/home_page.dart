import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'lyrics_services.dart';

class LyricsTranslator extends StatefulWidget {
  @override
  _LyricsTranslatorState createState() => _LyricsTranslatorState();
}

class _LyricsTranslatorState extends State<LyricsTranslator> {
  final TextEditingController _controller =
      TextEditingController(text: kDebugMode ? 'Arabian nights' : '');
  List<String> lyrics = [];
  List<String> translatedLines = [];

  Set<int> _selectedLineIndices = Set();

  bool _isHebrew(String text) {
    final hebrewRegex = RegExp(r'[\u0590-\u05FF]');
    return hebrewRegex.hasMatch(text);
  }

  Future<void> _getMediaInfo() async {
    // Replace this with the actual method to get media title and artist
    final mediaTitle =
        'Example Song'; // Replace with your media title fetching logic
    final mediaArtist =
        'Example Artist'; // Replace with your media artist fetching logic
    _controller.text = '$mediaArtist $mediaTitle ';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.orange],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            buildMainSearch(),
            const SizedBox(height: 20),
            buildLyricsCards(),
            const SizedBox(height: 40), // Space below the ListView
          ],
        ),
      ),
    );
  }

  Expanded buildLyricsCards() {
    return Expanded(
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: lyrics.length,
        itemBuilder: (context, index) {
          final isHebrewText = _isHebrew(lyrics[index]);
          final isHebrewTranslatedText = _isHebrew(translatedLines[index]);

          return Card(
            color: Colors.white.withOpacity(0.1),
            child: ListTile(
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
          );
        },
      ),
    );
  }

  Card buildMainSearch() {
    return Card(
      color: Colors.white.withOpacity(0.2),
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.music_note, color: Colors.white),
                onPressed: _getMediaInfo,
              ),
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
      backgroundColor: Colors.purple,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.network(
            'https://media.newyorker.com/photos/59095bb86552fa0be682d9d0/master/pass/Monkey-Selfie.jpg',
            width: 40,
            height: 40,
          ),
          SizedBox(width: 10),
          Text(
            'Faboules',
            style: GoogleFonts.rubik(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ],
      ),
      centerTitle: true,
    );
  }
}
