import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlParser;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:translator/translator.dart';

class LyricsServices {
  static Future<String?> getSongPath({required String q}) async {
    var headers = {
      'Authorization':
          'Bearer mBuPnQfgbuL5wjCojlIcfdV0Xw7krPPTg5oU0Fe5nUeunELizov3e9jkYSUydbtI',
    };
    var dio = Dio();
    try {
      var response = await dio.get(
        'https://api.genius.com/search',
        queryParameters: {'q': q},
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        // var path = response.data['response']['hits'][0]['result']['path'];
        var result = response.data['response']['hits'][0]['result'];
        print('result: ${result}');
        return result['path'].toString();
      } else {
        print('Error: ${response.statusMessage}');
      }
    } catch (e) {
      print('Exception: $e');
    }
    return null;
  }

  static Future<List<String>> fetchLyrics(String? songPath) async {
    final lyricsResponse = await http.get(Uri.parse(
      // lyricsUrl!
      // 'https://genius.com/Osher-cohen-ahava-lyrics',
      // 'https://genius.com/Adele-rolling-in-the-deep-lyrics',
      // 'https://genius.com//Will-smith-arabian-nights-lyrics',
      'https://genius.com$songPath',
    ));

    if (lyricsResponse.statusCode == 200) {
      print('songPath: ${songPath}');
      final document = htmlParser.parse(lyricsResponse.body);

      // final lyricsDiv = document.querySelector('[data-lyrics-container="true"]');

      final lyricsDivs =
          document.querySelectorAll('[data-lyrics-container="true"]');

      // Collect all lyrics from each div
      final allLyricsHtml =
          lyricsDivs.map((div) => div.innerHtml ?? '').join('\n');

      // Extract lines while preserving line breaks
      final linesHtml = allLyricsHtml
          .replaceAll(
              RegExp(r'<br\s*/?>'), '\n') // Convert <br> tags to newlines
          .replaceAll(RegExp(r'<.*?>'), '') // Remove HTML tags
          .trim() // Remove any leading/trailing whitespace
          .split('\n') // Split by newlines
          .where((line) => line.trim().isNotEmpty) // Remove empty lines
          .toList();

      // final cleanLyrics = _cleanLyrics(linesHtml);
      // return cleanLyrics;
      return linesHtml;
    }
    return [];
  }

  static Future<List<String>> translatedLyrics(List<String> lyrics) async {
    final translator = GoogleTranslator();
    const targetLanguage = 'he'; // Hebrew

    List<String> translatedLines = [];

    try {
      // Combine all lyrics into a single string with a unique delimiter
      String combinedLyrics = lyrics.join('\n');

      // Translate the combined string
      final translation =
          await translator.translate(combinedLyrics, to: targetLanguage);

      // Split the translated text back into lines
      List<String> translatedLinesUnfiltered = translation.text.split('\n');

      int lineIndex = 0;
      for (String line in lyrics) {
        String translatedLine = '';

        if (line.trim().isEmpty) {
          // If the original line was empty, use empty string to keep the sync
        } else {
          // Otherwise, add the translated line
          if (lineIndex < translatedLinesUnfiltered.length) {
            translatedLine = translatedLinesUnfiltered[lineIndex];
            lineIndex++;
          } else {
            // In case of missing lines in the translation result
            translatedLine = 'XXX';
          }
        }
        // print('translatedLine: ${translatedLine}');
        translatedLines.add(translatedLine);
      }
    } catch (e) {
      print('Translation error: $e');
      translatedLines = lyrics; // Fallback to original if an error occurs
    }

    return translatedLines;
  }

  static List<String> cleanLyrics(List<String> lines) {
    // Function to remove bracketed content
    // String _removeBrackets(String line) {
    //   final regex = RegExp(r'\[.*?\]');
    //   return line.replaceAll(regex, '').trim(); // Remove brackets and trim
    // }

    // Replace any item containing [ or ] with an empty string
    List<String> cleanedLines =
        lines.map((line) => line.contains('[') ? '·' : line).toList();
    print('cleanedLines: ${cleanedLines.length}');
    print('lines: ${lines.length}');

    // Remove empty items at the beginning

    // Remove '·' items at the beginning of the list
    int startIndex = 0;
    while (startIndex < cleanedLines.length &&
        (cleanedLines[startIndex].trim().isEmpty ||
            cleanedLines[startIndex] == '·')) {
      startIndex++;
    }

    // Extract the cleaned list after removing empty items at the start
    return cleanedLines.sublist(startIndex);
    // return cleanedLines;
  }
}
