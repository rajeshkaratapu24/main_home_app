import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'full_player_page.dart'; // ఫుల్ ప్లేయర్ కి లింక్

class AlbumSongsPage extends StatefulWidget {
  final String albumId;
  final String albumName;
  final String coverUrl;

  const AlbumSongsPage({super.key, required this.albumId, required this.albumName, required this.coverUrl});

  @override
  State<AlbumSongsPage> createState() => _AlbumSongsPageState();
}

class _AlbumSongsPageState extends State<AlbumSongsPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late Stream<QuerySnapshot> _songsStream; 
  
  String? _currentlyPlayingId;
  String _currentTitle = "";
  bool _isPlaying = false;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    // ఈ ఆల్బమ్ ఐడీ తో ఉన్న పాటలు మాత్రమే ఫిల్టర్ చేస్తున్నాం
    _songsStream = FirebaseFirestore.instance.collection('songs').where('albumId', isEqualTo: widget.albumId).snapshots();
    
    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) setState(() => _duration = newDuration);
    });
    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playSong(String songId, String url, String title) async {
    if (_currentlyPlayingId == songId) {
      if (_isPlaying) {
        await _audioPlayer.pause();
        setState(() => _isPlaying = false);
      } else {
        await _audioPlayer.resume();
        setState(() => _isPlaying = true);
      }
    } else {
      await _audioPlayer.stop();
      setState(() {
        _currentlyPlayingId = songId;
        _currentTitle = title;
        _isPlaying = true;
      });
      await _audioPlayer.play(UrlSource(url));
    }
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.albumName, style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 22)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _songsStream, 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("ఈ ఆల్బమ్ లో ఇంకా పాటలు లేవు", style: GoogleFonts.balooTammudu2(color: Colors.white54, fontSize: 18)));
          }

          final songsList = snapshot.data!.docs;

          return Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 120),
                itemCount: songsList.length,
                itemBuilder: (context, index) {
                  var song = songsList[index];
                  var data = song.data() as Map<String, dynamic>;
                  var title = data['title'] ?? 'Unknown';
                  var lyricist = data['lyricist'] ?? '';
                  var songUrl = data['songUrl'];
                  var songCover = data['coverUrl'] ?? '';
                  
                  bool isThisSongPlaying = _currentlyPlayingId == song.id;

                  return Card(
                    color: isThisSongPlaying ? const Color(0xFF2A2A2A) : const Color(0xFF1A1A1A),
                    margin: const EdgeInsets.only(bottom: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: songCover.isNotEmpty 
                            ? Image.network(songCover, width: 50, height: 50, fit: BoxFit.cover)
                            : Container(width: 50, height: 50, color: Colors.blueAccent, child: const Icon(Icons.music_note, color: Colors.white)),
                      ),
                      title: Text(title, style: GoogleFonts.balooTammudu2(color: isThisSongPlaying ? Colors.greenAccent : Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: Text(lyricist, style: GoogleFonts.balooTammudu2(color: Colors.white70, fontSize: 14)),
                      onTap: () => _playSong(song.id, songUrl, title),
                    ),
                  );
                },
              ),
              
              if (_currentlyPlayingId != null)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onTap: () {
                      int currentIndex = songsList.indexWhere((doc) => doc.id == _currentlyPlayingId);
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => FullPlayerPage(
                            audioPlayer: _audioPlayer, songsList: songsList, initialIndex: currentIndex,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.all(10), padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF222222), borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white10), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10, spreadRadius: 2)],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StreamBuilder<Duration>(
                            stream: _audioPlayer.onPositionChanged,
                            builder: (context, posSnapshot) {
                              final position = posSnapshot.data ?? Duration.zero;
                              return Column(
                                children: [
                                  SizedBox(
                                    height: 15,
                                    child: SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        trackHeight: 2, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                                        activeTrackColor: Colors.greenAccent, inactiveTrackColor: Colors.white24, thumbColor: Colors.greenAccent,
                                      ),
                                      child: Slider(
                                        min: 0, max: _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1,
                                        value: position.inSeconds.toDouble().clamp(0, _duration.inSeconds.toDouble()),
                                        onChanged: (value) async => await _audioPlayer.seek(Duration(seconds: value.toInt())),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(_currentTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill, size: 35, color: Colors.greenAccent),
                                        onPressed: () {
                                          _isPlaying ? _audioPlayer.pause() : _audioPlayer.resume();
                                          setState(() => _isPlaying = !_isPlaying);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
