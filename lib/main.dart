import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'UI/SpotifyAuthPage.dart';
import 'UI/ThemeNotifier.dart';
import 'font_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => FontProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final fontProvider = Provider.of<FontProvider>(context);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: fontProvider.selectedFont, // Áp dụng font chữ tùy chỉnh
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: fontProvider.selectedFont, // Áp dụng font chữ tùy chỉnh
      ),
      themeMode: themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: SpotifyAuthPage(),
    );
  }
}


// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: LyricsPage(),
//     );
//   }
// }
//
// class LyricsPage extends StatefulWidget {
//   @override
//   _LyricsPageState createState() => _LyricsPageState();
// }
//
// class _LyricsPageState extends State<LyricsPage> {
//   String _lyrics = 'Fetching lyrics...';
//
//   @override
//   void initState() {
//     super.initState();
//     fetchLyrics('Sơn Tùng M-TP', 'Nơi này có anh');
//   }
//
//   Future<void> fetchLyrics(String artist, String trackName) async {
//     final String apiKey = 'ba34ba55864ca3519ffef77262b327f7'; // Thay thế bằng API Key của bạn
//
//     // Bước 1: Lấy track ID từ tên bài hát
//     final trackId = await getTrackId(apiKey, artist, trackName);
//
//     // Bước 2: Lấy lời bài hát từ track ID
//     if (trackId != null) {
//       final lyrics = await getFullLyrics(apiKey, trackId);
//       if (lyrics != null) {
//         setState(() {
//           _lyrics = lyrics;
//         });
//       } else {
//         setState(() {
//           _lyrics = 'Lyrics not found';
//         });
//       }
//     } else {
//       setState(() {
//         _lyrics = 'Track not found';
//       });
//     }
//   }
//
//   Future<int?> getTrackId(String apiKey, String artist, String trackName) async {
//     final url =
//         'https://api.musixmatch.com/ws/1.1/track.search?q_artist=${Uri.encodeComponent(artist)}&q_track=${Uri.encodeComponent(trackName)}&apikey=$apiKey';
//
//     final response = await http.get(Uri.parse(url));
//
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       final trackList = data['message']['body']['track_list'];
//       if (trackList.isNotEmpty) {
//         return trackList[0]['track']['track_id'];
//       }
//     }
//
//     return null;
//   }
//
//   Future<String?> getFullLyrics(String apiKey, int trackId) async {
//     final url =
//         'https://api.musixmatch.com/ws/1.1/track.lyrics.get?track_id=$trackId&apikey=$apiKey';
//
//     final response = await http.get(Uri.parse(url));
//
//     if (response.statusCode == 200) {
//       String lyrics = json.decode(response.body)['message']['body']['lyrics']['lyrics_body'];
//
//       // Xóa bỏ phần dấu ba chấm nếu có
//       final ellipsisIndex = lyrics.indexOf('...');
//       if (ellipsisIndex != -1) {
//         lyrics = lyrics.substring(0, ellipsisIndex).trim();
//       }
//
//       // Xóa bỏ các dòng chứa chú thích bản quyền
//       lyrics = lyrics.split('\n').where((line) => !line.contains('*****')).join('\n').trim();
//
//       // Trả về phần lời bài hát đã xử lý
//       return lyrics;
//     } else {
//       print('Error: ${response.statusCode}');
//       return null;
//     }
//   }

//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Lyrics'),
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: EdgeInsets.all(16.0),
//           child: Text(_lyrics),
//         ),
//       ),
//     );
//   }
// }
