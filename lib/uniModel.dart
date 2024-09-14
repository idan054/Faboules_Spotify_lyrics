import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spotify/spotify.dart' as s;

class UniModel with ChangeNotifier {
  s.Track? track;
  String? clipboard;
  final TextEditingController controller =
      TextEditingController(text: kDebugMode ? 'Arabian nights' : '');

  // void updateTrack(s.Track? data) {
  //   track = data;
  //   notifyListeners();
  // }

  Future<void> setTrackFromClipboard() async {
    final clipboardData = await Clipboard.getData('text/plain');
    clipboard = clipboardData?.text;
    notifyListeners();

    final trackId = _getTrackId('${clipboardData?.text}');
    final credentials = s.SpotifyApiCredentials(
        '539d94f804f94f8394f23a303949dff9', '20d5a9c958a1421395c55e91a8260618');

    final spotify = s.SpotifyApi(credentials);
    track = await spotify.tracks.get(trackId);
    controller.text = '${track?.artists?.first.name} ${track?.name}';
    notifyListeners();
  }

  String _getTrackId(String url) {
    Uri uri = Uri.parse(url);
    List<String> segments = uri.pathSegments;
    if (segments.isNotEmpty && segments[0] == 'track') {
      return segments[1]; // The track ID is the second segment after 'track'
    }
    return '';
  }
}
