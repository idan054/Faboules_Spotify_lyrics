import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:faboules/uniModel.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlParser;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'home_page.dart';
import 'life_cycle.dart';
import 'lyrics_services.dart';

void main() {
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(
        create: (context) => UniModel(),
      )
    ], child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LifeCycleManager(
      child: MaterialApp(
        theme: ThemeData(
          primaryColor: Colors.purple,
          hintColor: Colors.orange,
          textTheme: GoogleFonts.rubikTextTheme(), // Apply Rubik font globally
        ),
        home: LyricsTranslator(),
      ),
    );
  }
}
