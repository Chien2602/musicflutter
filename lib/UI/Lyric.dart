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
        textTheme: GoogleFonts.robotoMonoTextTheme(
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

    // Check if trackName and artistName are not null or empty
    if (trackName == null || artistName == null || trackName.isEmpty || artistName.isEmpty) {
      setState(() {
        _lyrics = "No song information found.";
        _isLoading = false;
      });
      return;
    }

    // Initialize Genius API client with your access token
    Genius genius = Genius(
        accessToken:
        'm9cKhYPQI6ws8WQJzaXL4DOoSebWnA3DnO1U35QL10dRyz-tzCWwfbGZiP_vkkRY');

    try {
      // Search for a specific song by artist and title
      Song? song = await genius.searchSong(
          artist: artistName, title: trackName); // Fixed missing semicolon here

      if (song != null) {
        setState(() {
          _lyrics = song.lyrics ?? "Lyrics not available."; // Handling null lyrics
          _songTitle = song.title ?? "Unknown Title"; // Handling null title
          _artistName = song.primaryArtist?.name ?? "Unknown Artist"; // Handling null artist
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
          'Lyrics Viewer',
          style: GoogleFonts.pacifico(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
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
                    color: Colors.grey[400],
                  ),
                ),
                Divider(
                  color: Colors.deepPurple,
                  thickness: 1,
                  height: 30,
                ),
                Text(
                  _lyrics,
                  style: GoogleFonts.robotoMono(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}