import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:circle_flags/circle_flags.dart';
import 'package:hive/hive.dart';
import '../core/langs.dart';

class LanguageCarousel extends StatefulWidget {
  final Function(int) onLanguageSelected;

  const LanguageCarousel({Key? key, required this.onLanguageSelected})
      : super(key: key);

  @override
  _LanguageCarouselState createState() => _LanguageCarouselState();
}

class _LanguageCarouselState extends State<LanguageCarousel> {
  int _langIndex = 0;
  final controller = CarouselSliderController();

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

  Future<void> _loadSelectedLanguage() async {
    var box =
        await Hive.openBox('myBox'); // Ensure the box is opened asynchronously
    var cacheLang = box.get('selectedLang', defaultValue: 'Hebrew');
    Map<String, String>? selectedLang =
        languages.firstWhereOrNull((j) => j['name'] == cacheLang);

    if (selectedLang != null) {
      _langIndex = languages
          .indexWhere((element) => element['name'] == selectedLang['name']);

      controller.jumpToPage(_langIndex);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      carouselController: controller,
      options: CarouselOptions(
        height: 80, // Adjust height to accommodate larger flags
        enlargeCenterPage: false,
        viewportFraction: 0.125, // Show 5 flags at a time
        initialPage: 2,
        onPageChanged: (index, reason) {
          _langIndex = index;
          var box = Hive.box('myBox');
          box.put('selectedLang', languages[index]['name']);
          // var name = box.get('name');

          widget.onLanguageSelected(index);
          setState(() {});
        },
      ),
      itemCount: languages.length,
      itemBuilder: (context, index, realIdx) {
        double flagSize =
            index == _langIndex ? 50 : 25; // Highlight center flag
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color:
                  Colors.grey[index == _langIndex ? 800 : 900]!, // Border color
              width: index == _langIndex ? 7 : 5.0, // Border width
            ),
          ),
          child: CircleFlag(
            languages[index]['flag']!,
            size: flagSize,
          ),
        );
      },
    );
  }
}
