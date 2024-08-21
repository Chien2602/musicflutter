import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List> _topSongs;
  String? _accessToken;

  @override
  void initState() {
    super.initState();
    _initializeSpotifyService();
  }

  Future<void> _initializeSpotifyService() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _accessToken = prefs.getString('spotify_token');
    });

    if (_accessToken != null) {
      setState(() {
        _topSongs = getTopTracks(_accessToken!);
      });
    } else {
      print('Failed to get access token');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Top Songs This Week'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FutureBuilder<List>(
          future: _topSongs,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No data available'));
            } else {
              final songs = snapshot.data!;

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.2,
                ),
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  final song = songs[index];
                  final albumImageUrl = song['album']['images'][1]['url'];
                  final songTitle = song['name'];
                  final artistName = song['artists'][0]['name'];

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 8,
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.network(
                            albumImageUrl,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              } else {
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                        null
                                        ? loadingProgress
                                        .cumulativeBytesLoaded /
                                        (loadingProgress
                                            .expectedTotalBytes ??
                                            1)
                                        : null,
                                  ),
                                );
                              }
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                Center(child: Icon(Icons.error)),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                songTitle,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(artistName),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  Future<List<dynamic>> getTopTracks(String token) async {
    final response = await http.get(
      Uri.parse(
          'https://api.spotify.com/v1/browse/categories/toplists/playlists?country=VN'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final playlists = json['playlists']['items'];

      // Lấy các bài hát từ danh sách phát đầu tiên
      final firstPlaylistId = playlists[0]['id'];
      return await getPlaylistTracks(token, firstPlaylistId);
    } else {
      throw Exception('Failed to load top playlists');
    }
  }

  Future<List<dynamic>> getPlaylistTracks(String token, String playlistId) async {
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/playlists/$playlistId/tracks'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['items'].map((item) => item['track']).toList();
    } else {
      throw Exception('Failed to load playlist tracks');
    }
  }
}
