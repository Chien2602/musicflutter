import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:genius_lyrics/genius_lyrics.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LyricsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lyrics Viewer',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        textTheme: GoogleFonts.robotoTextTheme(
          Theme.of(context).textTheme,
        ),
        scaffoldBackgroundColor: Colors.blue,
      ),
      home: LyricsScreen(),
    );
  }
}

class LyricsScreen extends StatefulWidget {
  @override
  _LyricsScreenState createState() => _LyricsScreenState();
}

class _LyricsScreenState extends State<LyricsScreen> {
  String _lyrics = "Loading lyrics...";
  String _songTitle = "";
  String _artistName = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLyrics();
  }

  Future<void> _fetchLyrics() async {
    final prefs = await SharedPreferences.getInstance();
    String? trackName = prefs.getString('current_track_name');
    String? artistName = prefs.getString('current_artist_name');
    print(trackName);

    if (trackName == null || artistName == null || trackName.isEmpty || artistName.isEmpty) {
      setState(() {
        _lyrics = "No song information found.";
        _isLoading = false;
      });
      return;
    }

    Genius genius = Genius(
      accessToken: 'm9cKhYPQI6ws8WQJzaXL4DOoSebWnA3DnO1U35QL10dRyz-tzCWwfbGZiP_vkkRY',
    );

    try {
      Song? song = await genius.searchSong(artist: artistName, title: trackName);

      if (song != null) {
        setState(() {
          _lyrics = song.lyrics ?? "Lyrics not available.";
          _songTitle = song.title ?? "Unknown Title";
          _artistName = song.primaryArtist?.name ?? "Unknown Artist";
          _isLoading = false;
        });
      } else {
        setState(() {
          _lyrics = "Song not found.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _lyrics = "Error fetching lyrics.";
        _isLoading = false;
      });
      print("Error fetching lyrics: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lời bài hát',
          style: GoogleFonts.roboto(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple,
              Colors.black,
              Colors.deepPurple,
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: _isLoading
                ? CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
                : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _songTitle,
                    style: GoogleFonts.lobster(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _artistName,
                    style: GoogleFonts.roboto(
                      fontSize: 22,
                      fontWeight: FontWeight.w300,
                      color: Colors.white70,
                    ),
                  ),
                  Divider(
                    color: Colors.white70,
                    thickness: 1,
                    height: 30,
                  ),
                  Text(
                    _lyrics,
                    style: GoogleFonts.robotoMono(
                      fontSize: 18,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
