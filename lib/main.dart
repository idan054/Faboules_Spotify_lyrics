import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:faboules/uniModel.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart' as h;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlParser;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'dashboard_page.dart';
import 'life_cycle.dart';
import 'lyrics_services.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure Flutter is ready before Hive initialization

  await Hive.initFlutter();

  await Hive.openBox('myBox');
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
