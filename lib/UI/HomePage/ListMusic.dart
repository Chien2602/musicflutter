import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Database/Spotify_Service.dart'; // Đảm bảo rằng SpotifyService sử dụng token chính xác
import '../../Database/Refrech_Token.dart';
import '../MusicPlayerPage.dart';

class ListPage extends StatefulWidget {
  @override
  _ListPage createState() => _ListPage();
}

class _ListPage extends State<ListPage> {
  late SpotifyService _spotifyService;
  Map<String, dynamic>? _searchResults;
  Map<String, dynamic>? _playlistTracks;
  final TextEditingController _searchController = TextEditingController();
  final String _playlistId = '37i9dQZF1DX4g8Gs5nUhpp'; // ID của playlist
  bool _isSearching = false;
  bool _isLoadingPlaylist = false;
  String? _accessToken;

  @override
  void initState() {
    super.initState();
    _initializeSpotifyService();
  }

  Future<void> _initializeSpotifyService() async {
    final authService = SpotifyAuthService();
    final token = await authService.fetchAccessToken();
    print(token);
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _accessToken = prefs.getString('spotify_token');
    });
    print(_accessToken);
    if (_accessToken != null) {
      setState(() {
        _spotifyService = SpotifyService(_accessToken!);
      });
      await _loadPlaylistTracks();
    } else {
      print('Failed to get access token');
    }
  }

  Future<void> _search() async {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      setState(() {
        _isSearching = true;
        _searchResults = null; // Đặt lại kết quả tìm kiếm cũ
      });
      try {
        final results = await _spotifyService.search(query);
        setState(() {
          _searchResults = results;
        });
      } catch (e) {
        print('Search error: $e');
      } finally {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  Future<void> _loadPlaylistTracks() async {
    setState(() {
      _isLoadingPlaylist = true;
    });
    try {
      final tracks = await _spotifyService.getPlaylistTracks(_playlistId, 100);
      setState(() {
        _playlistTracks = tracks;
      });
    } catch (e) {
      print('Error loading playlist tracks: $e');
    } finally {
      setState(() {
        _isLoadingPlaylist = false;
      });
    }
  }

  void _navigateToMusicPlayer() async {
    final prefs = await SharedPreferences.getInstance();
    String? trackName = prefs.getString('current_track_name');
    String? artistName = prefs.getString('current_artist_name');
    String? albumImageUrl = prefs.getString('current_album_image_url');
    String? trackUrl = prefs.getString('current_track_url');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MusicPlayerPage(
          trackName: trackName ?? 'No song playing',
          artistName: artistName ?? '',
          albumImageUrl: albumImageUrl ?? '',
          trackUrl: trackUrl ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.blue,
            ],
          ),
        ),
        child: GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity != null &&
                details.primaryVelocity! > 0) {
              _navigateToMusicPlayer(); // Vuốt phải, điều hướng đến trang MusicPlayerPage
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText:
                              'Tìm kiếm bài hát, album, nghệ sĩ, playlist',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onSubmitted: (_) => _search(),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _search,
                      style: ElevatedButton.styleFrom(
                        textStyle: TextStyle(color: Colors.white),
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Search'),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Expanded(
                  child: _isSearching
                      ? Center(child: CircularProgressIndicator())
                      : _searchResults != null && _searchResults!.isNotEmpty
                          ? ListView(
                              children: _buildSearchResults(),
                            )
                          : _isLoadingPlaylist
                              ? Center(child: CircularProgressIndicator())
                              : _playlistTracks != null &&
                                      _playlistTracks!.isNotEmpty
                                  ? ListView(
                                      children: _buildPlaylistTracks(),
                                    )
                                  : Center(child: Text('No results found')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSearchResults() {
    List<Widget> resultList = [];

    if (_searchResults?['tracks']?['items']?.isNotEmpty ?? false) {
      resultList.addAll(
        _searchResults!['tracks']['items'].map<Widget>((track) => Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              color: Colors.green[600],
              child: ListTile(
                leading: track['album']['images'].isNotEmpty
                    ? Image.network(track['album']['images'][0]['url'],
                        width: 50, height: 50, fit: BoxFit.cover)
                    : null,
                title: Text(track['name'],
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(track['artists'][0]['name']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MusicPlayerPage(
                        trackName: track['name'],
                        artistName: track['artists'][0]['name'],
                        albumImageUrl: track['album']['images'][0]['url'],
                        trackUrl: track['external_urls']['spotify'],
                      ),
                    ),
                  );
                },
              ),
            )),
      );
    }

    if (_searchResults?['albums']?['items']?.isNotEmpty ?? false) {
      resultList.addAll(
        _searchResults!['albums']['items'].map<Widget>((album) => Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: album['images'].isNotEmpty
                    ? Image.network(album['images'][0]['url'],
                        width: 50, height: 50, fit: BoxFit.cover)
                    : null,
                title: Text(album['name'],
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(album['artists'][0]['name']),
              ),
            )),
      );
    }

    if (_searchResults?['artists']?['items']?.isNotEmpty ?? false) {
      resultList.addAll(
        _searchResults!['artists']['items'].map<Widget>((artist) => Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: artist['images'].isNotEmpty
                    ? Image.network(artist['images'][0]['url'],
                        width: 50, height: 50, fit: BoxFit.cover)
                    : null,
                title: Text(artist['name'],
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Artist'),
              ),
            )),
      );
    }

    if (_searchResults?['playlists']?['items']?.isNotEmpty ?? false) {
      resultList.addAll(
        _searchResults!['playlists']['items'].map<Widget>((playlist) => Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: playlist['images'].isNotEmpty
                    ? Image.network(playlist['images'][0]['url'],
                        width: 50, height: 50, fit: BoxFit.cover)
                    : null,
                title: Text(playlist['name'],
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Playlist'),
              ),
            )),
      );
    }

    return resultList;
  }

  List<Widget> _buildPlaylistTracks() {
    if (_playlistTracks?['items'] == null ||
        _playlistTracks!['items'].isEmpty) {
      return [Center(child: Text('No tracks found in playlist'))];
    }

    return _playlistTracks!['items'].map<Widget>((item) {
      final track = item['track'];
      return Card(
        color: Colors.green[600],
        margin: EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading: track['album']['images'].isNotEmpty
              ? Image.network(track['album']['images'][0]['url'],
                  width: 50, height: 50, fit: BoxFit.cover)
              : null,
          title: Text(track['name'],
              style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(track['artists'][0]['name']),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MusicPlayerPage(
                  trackName: track['name'],
                  artistName: track['artists'][0]['name'],
                  albumImageUrl: track['album']['images'][0]['url'],
                  trackUrl: track['external_urls']['spotify'],
                ),
              ),
            );
          },
        ),
      );
    }).toList();
  }
}
