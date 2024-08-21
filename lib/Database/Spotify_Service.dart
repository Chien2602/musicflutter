import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'Refrech_Token.dart';

class SpotifyService {
  String _token;
  final SpotifyAuthService _authService = SpotifyAuthService();

  SpotifyService(this._token);

  Future<void> _refreshTokenIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final tokenExpiry = prefs.getInt('token_expiry');
    final now = DateTime.now().millisecondsSinceEpoch;

    if (tokenExpiry != null && now > tokenExpiry) {
      await _authService.fetchAccessToken();
      _token = prefs.getString('access_token')!;
    }
  }

  Future<Map<String, dynamic>> search(String query) async {
    await _refreshTokenIfNeeded();

    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/search?q=${Uri.encodeComponent(query)}&type=track,album,artist,playlist&limit=50'),
      headers: {
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to search: ${response.reasonPhrase}');
    }
  }

  Future<Map<String, dynamic>> getPlaylistTracks(String playlistId, int limit) async {
    await _refreshTokenIfNeeded();

    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/playlists/$playlistId/tracks?market=US&limit=$limit'),
      headers: {
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load playlist tracks: ${response.reasonPhrase}');
    }
  }

  Future<void> playTrack(String trackUri) async {
    await _refreshTokenIfNeeded();

    final response = await http.put(
      Uri.parse('https://api.spotify.com/v1/me/player/play'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'uris': [trackUri],
      }),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to play track');
    }
  }

  Future<void> pausePlayback() async {
    await _refreshTokenIfNeeded();

    final response = await http.put(
      Uri.parse('https://api.spotify.com/v1/me/player/pause'),
      headers: {
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to pause playback');
    }
  }

  Future<void> resumePlayback() async {
    await _refreshTokenIfNeeded();

    final response = await http.put(
      Uri.parse('https://api.spotify.com/v1/me/player/play'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to resume playback');
    }
  }
}
