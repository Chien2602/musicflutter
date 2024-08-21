import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SpotifyAuthService {
  final String clientId = '38e8653140d54d0fb5e5726d480a1495';
  final String clientSecret = 'b566bd6d7bb04f559301f6811f8941bf';
  final String redirectUri = 'https://playmusic/callback';

  // Method to obtain access token using authorization code
  Future<String?> getAccessToken(String authCode) async {
    final String tokenUrl = 'https://accounts.spotify.com/api/token';

    try {
      final response = await http.post(
        Uri.parse(tokenUrl),
        headers: {
          'Authorization': 'Basic ' + base64Encode(utf8.encode('$clientId:$clientSecret')),
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'authorization_code',
          'code': authCode,
          'redirect_uri': redirectUri,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> tokenResponse = json.decode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', tokenResponse['access_token']);
        await prefs.setString('refresh_token', tokenResponse['refresh_token']);
        return tokenResponse['access_token'];
      } else {
        // Throw an exception with detailed error message
        throw Exception('Failed to get access token: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      // Catch and handle any exceptions during the HTTP request
      print('Error fetching access token: $e');
      rethrow;
    }
  }

  // Method to fetch the stored access token from SharedPreferences
  Future<String?> fetchAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('access_token');
    } catch (e) {
      // Catch and handle any exceptions during access to SharedPreferences
      print('Error fetching access token from SharedPreferences: $e');
      return null;
    }
  }
}
