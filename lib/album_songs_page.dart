import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'full_player_page.dart';

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
      backgroundColor: const Color(0xFF0A0A0A), // డీప్ బ్లాక్ థీమ్
      body: StreamBuilder<QuerySnapshot>(
        stream: _songsStream, 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
          
          final songsList = snapshot.hasData ? snapshot.data!.docs : [];

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // --- PREMIUM SPOTIFY STYLE HEADER ---
                  SliverAppBar(
                    expandedHeight: 280.0,
                    pinned: true,
                    backgroundColor: const Color(0xFF0A0A0A),
                    elevation: 0,
                    iconTheme: const IconThemeData(color: Colors.white),
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        widget.albumName, 
                        style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)
                      ),
                      centerTitle: true,
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          widget.coverUrl.isNotEmpty
                              ? Image.network(
                                  widget.coverUrl, 
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF1A1A1A), child: const Icon(Icons.album, size: 80, color: Colors.white24)),
                                )
                              : Container(color: const Color(0xFF1A1A1A), child: const Icon(Icons.album, size: 80, color: Colors.white24)),
                          // గ్రేడియంట్ షాడో (టెక్స్ట్ కోసం)
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, const Color(0xFF0A0A0A).withOpacity(0.8), const Color(0xFF0A0A0A)],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --- SONGS LIST ---
                  if (songsList.isEmpty)
                    SliverFillRemaining(
                      child: Center(child: Text("ఈ ఆల్బమ్ లో ఇంకా పాటలు లేవు", style: GoogleFonts.balooTammudu2(color: Colors.white54, fontSize: 18))),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          var song = songsList[index];
                          var data = song.data() as Map<String, dynamic>;
                          var title = data['title'] ?? 'Unknown';
                          var lyricist = data['lyricist'] ?? '';
                          var songUrl = data['songUrl'];
                          var songCover = data['coverUrl'] ?? '';
                          
                          bool isThisSongPlaying = _currentlyPlayingId == song.id;

                          // చివరి పాట కింద మినీ ప్లేయర్ కోసం గ్యాప్
                          double bottomPadding = (index == songsList.length - 1) ? 120.0 : 0.0;

                          return Padding(
                            padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: bottomPadding),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              tileColor: isThisSongPlaying ? Colors.white.withOpacity(0.05) : Colors.transparent, // ప్లే అవుతున్నప్పుడు హైలైట్
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: songCover.isNotEmpty 
                                    ? Image.network(
                                        songCover, width: 50, height: 50, fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(width: 50, height: 50, color: const Color(0xFF222222), child: const Icon(Icons.music_note, color: Colors.white54)),
                                      )
                                    : Container(width: 50, height: 50, color: const Color(0xFF222222), child: const Icon(Icons.music_note, color: Colors.white54)),
                              ),
                              title: Text(
                                title, 
                                style: GoogleFonts.balooTammudu2(color: isThisSongPlaying ? Colors.greenAccent : Colors.white, fontSize: 18, fontWeight: isThisSongPlaying ? FontWeight.bold : FontWeight.normal)
                              ),
                              subtitle: Text(lyricist, style: GoogleFonts.balooTammudu2(color: Colors.white54, fontSize: 13)),
                              trailing: isThisSongPlaying ? const Icon(Icons.equalizer, color: Colors.greenAccent) : const Icon(Icons.more_vert, color: Colors.white24),
                              onTap: () => _playSong(song.id, songUrl, title),
                            ),
                          );
                        },
                        childCount: songsList.length,
                      ),
                    ),
                ],
              ),
              
              // --- MINI PLAYER (FLOATING DESIGN) ---
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
                      margin: const EdgeInsets.only(left: 15, right: 15, bottom: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E), 
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10), 
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.8), blurRadius: 15, spreadRadius: 5)],
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
                                        icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill, size: 40, color: Colors.greenAccent),
                                        onPressed: () {
                                          _isPlaying ? _audioPlayer.pause() : _audioPlayer.resume();
                                          setState(() => _isPlaying = !_isPlaying);
                                        },
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                    child: SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        trackHeight: 2, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
                                        activeTrackColor: Colors.greenAccent, inactiveTrackColor: Colors.white24, thumbColor: Colors.greenAccent,
                                      ),
                                      child: Slider(
                                        min: 0, max: _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1,
                                        value: position.inSeconds.toDouble().clamp(0, _duration.inSeconds.toDouble()),
                                        onChanged: (value) async => await _audioPlayer.seek(Duration(seconds: value.toInt())),
                                      ),
                                    ),
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
