import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FullPlayerPage extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final List<DocumentSnapshot> songsList;
  final int initialIndex;

  const FullPlayerPage({
    super.key,
    required this.audioPlayer,
    required this.songsList,
    required this.initialIndex,
  });

  @override
  State<FullPlayerPage> createState() => _FullPlayerPageState();
}

class _FullPlayerPageState extends State<FullPlayerPage> {
  late int currentIndex;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;

    widget.audioPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    widget.audioPlayer.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    widget.audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });
    widget.audioPlayer.onPlayerComplete.listen((_) {
      _playNext(); 
    });
  }

  void _playSong(int index) async {
    if (index < 0 || index >= widget.songsList.length) return;
    setState(() {
      currentIndex = index;
      _position = Duration.zero;
    });
    var songData = widget.songsList[index].data() as Map<String, dynamic>?; // టైప్ కాస్టింగ్
    var songUrl = songData?['songUrl'] ?? '';
    if (songUrl.isNotEmpty) {
      await widget.audioPlayer.play(UrlSource(songUrl));
    }
  }

  void _playNext() {
    if (currentIndex < widget.songsList.length - 1) {
      _playSong(currentIndex + 1);
    }
  }

  void _playPrevious() {
    if (currentIndex > 0) {
      _playSong(currentIndex - 1);
    }
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  // --- UP NEXT QUEUE (Bottom Sheet) ---
  void _showQueueBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Column(
          children: [
            const SizedBox(height: 15),
            Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 15),
            Text("Up Next", style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: widget.songsList.length - (currentIndex + 1),
                itemBuilder: (context, index) {
                  var nextIndex = currentIndex + 1 + index;
                  var songData = widget.songsList[nextIndex].data() as Map<String, dynamic>?;
                  
                  return ListTile(
                    leading: Text("${index + 1}", style: const TextStyle(color: Colors.white54, fontSize: 16)),
                    title: Text(songData?['title'] ?? 'Unknown', style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 16)),
                    subtitle: Text(songData?['lyricist'] ?? '', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    trailing: const Icon(Icons.play_arrow, color: Colors.white54),
                    onTap: () {
                      Navigator.pop(context);
                      _playSong(nextIndex);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var currentSongData = widget.songsList[currentIndex].data() as Map<String, dynamic>?;
    var title = currentSongData?['title'] ?? 'Unknown';
    var lyricist = currentSongData?['lyricist'] ?? '';
    var coverUrl = currentSongData?['coverUrl'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF050505), // ఫుల్ డార్క్ థీమ్
      body: Stack(
        children: [
          Column(
            children: [
              // --- 1. U-SHAPE COVER IMAGE ---
              Container(
                width: screenWidth,
                height: MediaQuery.of(context).size.height * 0.55, // స్క్రీన్ లో సగం ఇమేజ్
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(screenWidth / 2)), // U-Shape కర్వ్
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.8), blurRadius: 30, spreadRadius: 5)],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(screenWidth / 2)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // ఇమేజ్ 
                      coverUrl.isNotEmpty
                          ? Image.network(coverUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.album, size: 100, color: Colors.white24))
                          : const Icon(Icons.album, size: 100, color: Colors.white24),
                      
                      // బ్లాక్ గ్రేడియంట్ (టెక్స్ట్ కనిపించడానికి)
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withOpacity(0.7), Colors.black],
                          ),
                        ),
                      ),
                      
                      // పాట పేరు & లిరిసిస్ట్
                      Positioned(
                        bottom: 40,
                        left: 20,
                        right: 20,
                        child: Column(
                          children: [
                            Text(title, textAlign: TextAlign.center, style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, height: 1.2)),
                            const SizedBox(height: 5),
                            Text(lyricist, textAlign: TextAlign.center, style: GoogleFonts.balooTammudu2(color: Colors.white54, fontSize: 16)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // --- 2. PROGRESS BAR & TIME ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.white24,
                        thumbColor: Colors.white,
                      ),
                      child: Slider(
                        min: 0,
                        max: _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1,
                        value: _position.inSeconds.toDouble().clamp(0, _duration.inSeconds.toDouble()),
                        onChanged: (val) => widget.audioPlayer.seek(Duration(seconds: val.toInt())),
                      ),
                    ),
                    // సెంటర్ లో టైమ్ (డిజైన్ లాగా)
                    Text(
                      "${_formatTime(_position)}  /  ${_formatTime(_duration)}",
                      style: const TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // --- 3. MEDIA CONTROLS ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(icon: const Icon(Icons.shuffle, color: Colors.white54, size: 28), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.fast_rewind, color: Colors.white, size: 35), onPressed: _playPrevious),
                    
                    // ప్లే బటన్ (పెద్దగా, వైట్ కలర్ లో)
                    GestureDetector(
                      onTap: () {
                        _isPlaying ? widget.audioPlayer.pause() : widget.audioPlayer.resume();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.2), blurRadius: 20, spreadRadius: 5)],
                        ),
                        child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.black, size: 45),
                      ),
                    ),
                    
                    IconButton(icon: const Icon(Icons.fast_forward, color: Colors.white, size: 35), onPressed: _playNext),
                    IconButton(icon: const Icon(Icons.menu, color: Colors.white54, size: 28), onPressed: _showQueueBottomSheet), // క్యూ ఓపెన్ అవుతుంది
                  ],
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),

          // --- APP BAR (Top Over Image) ---
          Positioned(
            top: 40, left: 10, right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 35), onPressed: () => Navigator.pop(context)),
                IconButton(icon: const Icon(Icons.more_vert, color: Colors.white, size: 30), onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
