import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'Lyric.dart';

class MusicPlayerPage extends StatefulWidget {
  final String trackName;
  final String artistName;
  final String albumImageUrl;
  final String trackUrl;
  final bool isPlaying;
  final int currentPosition;

  MusicPlayerPage({
    required this.trackName,
    required this.artistName,
    required this.albumImageUrl,
    required this.trackUrl,
    this.isPlaying = false,
    this.currentPosition = 0,
  });

  @override
  _MusicPlayerPageState createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  bool isFavorite = false;
  String? activeDeviceId;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  bool isPlaying = false;
  bool isUpdatingPosition = false;
  bool isTrackEnded = false;
  late bool _isPlaying;
  late int _currentPosition;
  String? _currentTrackID;
  int? _savedPositionMs;

  @override
  void initState() {
    super.initState();
    _isPlaying = widget.isPlaying;
    _currentPosition = widget.currentPosition;
    _getDevices();
    _resumeTrack();
    _playTrack();
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('spotify_token') ?? '';
  }

  Future<void> _getDevices() async {
    final String token = await _getToken();
    final String devicesUrl = 'https://api.spotify.com/v1/me/player/devices';

    final response = await http.get(
      Uri.parse(devicesUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final devices = json.decode(response.body)['devices'];
      if (devices.isNotEmpty) {
        setState(() {
          activeDeviceId = devices[0]['id'];
        });
      } else {
        print('Không tìm thấy thiết bị nào.');
      }
    } else {
      print('Lỗi khi lấy danh sách thiết bị: ${response.body}');
    }
  }

  Future<void> _pauseTrack() async {
    if (activeDeviceId == null) {
      print('Không có thiết bị nào hoạt động.');
      return;
    }

    final String token = await _getToken();
    final String pauseUrl =
        'https://api.spotify.com/v1/me/player/pause?device_id=$activeDeviceId';

    final response = await http.put(
      Uri.parse(pauseUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      print('Bài hát đã tạm dừng.');
      setState(() {
        isPlaying = false;
        isUpdatingPosition = false;
      });

      final prefs = await SharedPreferences.getInstance();
      prefs.setInt('position_ms', position.inMilliseconds);
      prefs.setString('current_track_id', _currentTrackID ?? '');
    } else if (response.statusCode == 403) {
      final responseBody = json.decode(response.body);
      print(
          'Lỗi quyền truy cập khi tạm dừng bài hát: ${responseBody['error']['message']}');
    } else {
      print(
          'Lỗi khi tạm dừng bài hát: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> _resumeTrack() async {
    if (activeDeviceId == null) {
      print('Không có thiết bị nào hoạt động.');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final savedPositionMs = prefs.getInt('position_ms') ?? 0;
    final savedTrackID = prefs.getString('current_track_id') ?? '';

    if (savedTrackID == _currentTrackID) {
      position = Duration(milliseconds: savedPositionMs);
    } else {
      position = Duration.zero;
    }

    if (!_isPlaying) {
      await _playTrack();
    }
  }

  Future<void> _playTrack() async {
    if (activeDeviceId == null) {
      print('Không có thiết bị nào hoạt động.');
      return;
    }

    final String token = await _getToken();
    final String playUrl =
        'https://api.spotify.com/v1/me/player/play?device_id=$activeDeviceId';
    final trackID = widget.trackUrl.split('/').last.split('?').first;

    final int startPositionMs = isTrackEnded ? 0 : position.inMilliseconds;
    final response = await http.put(
      Uri.parse(playUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'uris': ['spotify:track:$trackID'],
        'position_ms': startPositionMs,
      }),
    );

    if (response.statusCode == 204) {
      print('Bài hát đang được phát.');
      setState(() {
        isPlaying = true;
        isUpdatingPosition = true;
        isTrackEnded = false;
        _currentTrackID = trackID;
      });
      _updatePosition();
    } else {
      print('Lỗi khi phát bài hát: ${response.statusCode} - ${response.body}');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_track_name', widget.trackName);
    await prefs.setString('current_artist_name', widget.artistName);
    await prefs.setString('current_album_image_url', widget.albumImageUrl);
    await prefs.setString('current_track_url', widget.trackUrl);
    await prefs.setInt('current_track_position', position.inMilliseconds);
  }

  Future<void> _seekTrack(double value) async {
    if (activeDeviceId == null) {
      print('Không có thiết bị nào hoạt động.');
      return;
    }

    final String token = await _getToken();
    final String seekUrl =
        'https://api.spotify.com/v1/me/player/seek?position_ms=${(value * 1000).toInt()}&device_id=$activeDeviceId';

    final response = await http.put(
      Uri.parse(seekUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      print('Đã tua đến vị trí: $value giây');
      setState(() {
        position = Duration(milliseconds: (value * 1000).toInt());
      });
    } else {
      print('Lỗi khi tua bài hát: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> _seekForward() async {
    final newPosition = position.inSeconds + 10.0;
    await _seekTrack(newPosition);
  }

  Future<void> _seekRelay() async {
    final newPosition = position.inSeconds - 10.0;
    await _seekTrack(newPosition);
  }

  Future<void> _updatePosition() async {
    while (isPlaying) {
      if (activeDeviceId == null) {
        print('Không có thiết bị nào hoạt động.');
        return;
      }

      final String token = await _getToken();
      final String positionUrl =
          'https://api.spotify.com/v1/me/player/currently-playing';

      final response = await http.get(
        Uri.parse(positionUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final currentPosition = jsonResponse['progress_ms'] ?? 0;
        final trackDuration = jsonResponse['item']['duration_ms'] ?? 0;

        setState(() {
          position = Duration(milliseconds: currentPosition);
          duration = Duration(milliseconds: trackDuration);
        });

        if (currentPosition >= trackDuration) {
          setState(() {
            isTrackEnded = true;
            isPlaying = false;
          });

          await _playTrack();
        }
      } else if (response.statusCode == 204) {
        print('Không có bài hát nào đang phát.');
        setState(() {
          position = Duration.zero;
          duration = Duration.zero;
        });
      } else {
        print(
            'Lỗi khi lấy thông tin bài hát hiện tại: ${response.statusCode} - ${response.body}');
      }

      await Future.delayed(Duration(seconds: 1));
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.trackUrl)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Copied to clipboard!')),
      );
    }).catchError((e) {
      print('Failed to copy text: $e');
    });
  }

  @override
  Widget build(BuildContext context) {
    void _showLyricsDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return LyricsApp();
        },
      );
    }

    final positionInSeconds = position.inSeconds.toDouble();
    final durationInSeconds = duration.inSeconds.toDouble();
    final sliderMax = durationInSeconds > 0.0 ? durationInSeconds : 1.0;
    final positionValue =
        positionInSeconds > sliderMax ? sliderMax : positionInSeconds;

    return Scaffold(
      backgroundColor: Colors.green[800],
      appBar: AppBar(
        backgroundColor: Color(0xFF667EEA),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () async {
            await _pauseTrack();
            Navigator.pop(context);
          },
        ),
          title: Center(child: Text("PHÁT NHẠC")),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667EEA),
              Colors.green,
              Color(0xFF764BA2),
            ],
          ),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.all(20),
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    image: DecorationImage(
                      image: NetworkImage(widget.albumImageUrl),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 15,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                ),
                Text(
                  widget.trackName,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  widget.artistName,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 20),
                Slider(
                  activeColor: Colors.white,
                  inactiveColor: Colors.white24,
                  value: positionValue,
                  min: 0.0,
                  max: sliderMax,
                  onChanged: (value) {
                    _seekTrack(value);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')}",
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        "${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                        size: 32,
                      ),
                      onPressed: () {
                        setState(() {
                          isFavorite = !isFavorite;
                        });
                      },
                    ),
                    SizedBox(width: 20),
                    IconButton(
                      icon: Icon(Icons.replay_5),
                      color: Colors.white,
                      iconSize: 40,
                      onPressed: _seekRelay,
                    ),
                    SizedBox(width: 20),
                    GestureDetector(
                      onTap: isPlaying ? _pauseTrack : _resumeTrack,
                      child: Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.green[800],
                          size: 35,
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    IconButton(
                      icon: Icon(Icons.forward_5),
                      color: Colors.white,
                      iconSize: 40,
                      onPressed: _seekForward,
                    ),
                    SizedBox(width: 20),
                    IconButton(
                      icon: Icon(Icons.share, color: Colors.white),
                      onPressed: _copyToClipboard,
                    ),
                    SizedBox(width: 20),
                    IconButton(
                      icon: Icon(Icons.lyrics, color: Colors.white),
                      onPressed: () {
                        _showLyricsDialog(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
