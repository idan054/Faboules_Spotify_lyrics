import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlParser;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:translator/translator.dart';

class LyricsServices {
  static Future<String?> getSongPath(String q) async {
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
      final document = htmlParser.parse(lyricsResponse.body);

      final lyricsDiv =
          document.querySelector('[data-lyrics-container="true"]');

      final lyricsHtml = lyricsDiv?.innerHtml ?? '';

      // Extract lines while preserving line breaks
      final linesHtml = lyricsHtml
          .replaceAll(
              RegExp(r'<br\s*/?>'), '\n') // Convert <br> tags to newlines
          .replaceAll(RegExp(r'<.*?>'), '') // Remove HTML tags
          .trim() // Remove any leading/trailing whitespace
          .split('\n') // Split by newlines
          .where((line) => line.trim().isNotEmpty) // Remove empty lines
          .toList();

      final cleanLyrics = _cleanLyrics(linesHtml);
      return cleanLyrics;
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

      // Reconstruct the translated lines list to match the original lyrics structure
      int lineIndex = 0;
      for (String line in lyrics) {
        if (line.trim().isEmpty) {
          // If the original line was empty, add an empty string to keep the sync
          translatedLines.add('');
        } else {
          // Otherwise, add the translated line
          if (lineIndex < translatedLinesUnfiltered.length) {
            translatedLines.add(translatedLinesUnfiltered[lineIndex]);
            lineIndex++;
          } else {
            // In case of missing lines in the translation result
            translatedLines.add('');
          }
        }
      }
    } catch (e) {
      print('Translation error: $e');
      translatedLines = lyrics; // Fallback to original if an error occurs
    }

    return translatedLines;
  }

  static List<String> _cleanLyrics(List<String> lines) {
    // Function to replace lines with brackets
    String _replaceBrackets(String line) {
      final regex = RegExp(r'\[.*?\]');
      return line.replaceAll(regex, '\n');
    }

    // Remove empty items at the start
    int startIndex = 0;
    while (startIndex < lines.length && lines[startIndex].trim().isEmpty) {
      startIndex++;
    }

    // Remove empty items at the end
    int endIndex = lines.length - 1;
    while (endIndex >= startIndex && lines[endIndex].trim().isEmpty) {
      endIndex--;
    }

    // Extract the cleaned list
    List<String> cleanedLines = lines.sublist(startIndex, endIndex + 1);

    // Replace lines with brackets and remove consecutive empty lines
    List<String> finalLines = [];
    String? previousLine;
    for (var line in cleanedLines) {
      line = _replaceBrackets(line);
      if (line.trim().isEmpty && previousLine?.trim().isEmpty == true) {
        continue; // Skip adding this line if it's an empty line after another empty line
      }

      finalLines.add(line);
      previousLine = line;
    }

    return finalLines;
  }
}
