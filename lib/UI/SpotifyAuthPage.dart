import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:musicflutter/UI/Login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SpotifyAuthPage extends StatefulWidget {
  @override
  _SpotifyAuthPageState createState() => _SpotifyAuthPageState();
}

class _SpotifyAuthPageState extends State<SpotifyAuthPage> {
  final String clientId = '38e8653140d54d0fb5e5726d480a1495';
  final String clientSecret = 'b566bd6d7bb04f559301f6811f8941bf';
  final String redirectUri = 'https://playmusic/callback';
  final String scopes = 'user-read-playback-state user-modify-playback-state';

  String _authCode = '';

  Future<void> _authenticate() async {
    final String authUrl =
        'https://accounts.spotify.com/authorize?client_id=$clientId&response_type=code&redirect_uri=$redirectUri&scope=$scopes&code_challenge_method=S256';

    if (await canLaunch(authUrl)) {
      await launch(authUrl,
          forceSafariVC: false, forceWebView: false, enableJavaScript: true);
    } else {
      print('Không thể mở URL: $authUrl');
    }
  }

  Future<void> _getAccessToken() async {
    final String tokenUrl = 'https://accounts.spotify.com/api/token';

    final response = await http.post(
      Uri.parse(tokenUrl),
      headers: {
        'Authorization':
            'Basic ' + base64Encode(utf8.encode('$clientId:$clientSecret')),
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'authorization_code',
        'code': _authCode,
        'redirect_uri': redirectUri,
        'code_verifier': '',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> tokenResponse = json.decode(response.body);
      final String accessToken = tokenResponse['access_token'];
      print('Thông tin người dùng: $tokenResponse');
      await _saveToken(accessToken);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                LoginPage()),
      );
    } else {
      print('Không lấy được access token: ${response.body}');
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('spotify_token', token);
  }

  @override
  Widget build(BuildContext context) {
    final imgURL = 'lib/assets/Spotify_Primary_Logo_RGB_Green.png';
    return Scaffold(
      appBar: AppBar(
        title: Text('Spotify Auth'),
        backgroundColor: Colors.green,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green,
              Colors.white,
              Colors.white,
              Colors.green,
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, // Đẩy nội dung lên sát AppBar
              children: [
                SizedBox(height: 20), // Khoảng cách từ AppBar
                Image.asset(
                  imgURL,
                  height: 150,
                  width: 150,
                ),
                SizedBox(height: 50),
                Text(
                  'XÁC THỰC SPOTIFY',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 40),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Nhập mã xác thực',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _authCode = value;
                    });
                  },
                ),
                SizedBox(height: 60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _authenticate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: Text('Mã xác thực', style: TextStyle(color: Colors.black)),
                    ),
                    SizedBox(width: 50),
                    ElevatedButton(
                      onPressed: _getAccessToken,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: Text('Xác nhận', style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
