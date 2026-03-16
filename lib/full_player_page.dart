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

    // Listeners
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
      _playNext(); // పాట అయిపోతే ఆటోమేటిక్ గా నెక్స్ట్ పాటకి
    });
  }

  void _playSong(int index) async {
    if (index < 0 || index >= widget.songsList.length) return;
    setState(() {
      currentIndex = index;
      _position = Duration.zero;
    });
    var songUrl = widget.songsList[index]['songUrl'];
    await widget.audioPlayer.play(UrlSource(songUrl));
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

  void _seekForward() async {
    final newPosition = _position + const Duration(seconds: 10);
    await widget.audioPlayer.seek(newPosition > _duration ? _duration : newPosition);
  }

  void _seekBackward() async {
    final newPosition = _position - const Duration(seconds: 10);
    await widget.audioPlayer.seek(newPosition < Duration.zero ? Duration.zero : newPosition);
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    var currentSong = widget.songsList[currentIndex];
    var title = currentSong['title'] ?? 'Unknown';
    var lyricist = currentSong['lyricist'] ?? '';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 35),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.favorite_border, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // --- VINYL RECORD IMAGE ---
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade900,
                border: Border.all(color: Colors.white10, width: 2),
                boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20, spreadRadius: 5)],
              ),
              child: Icon(Icons.album, size: 100, color: Colors.grey.shade800),
            ),
          ),
          const SizedBox(height: 40),

          // --- PROGRESS BAR & TIMERS ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatTime(_position), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    Text(_formatTime(_duration), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // --- MEDIA CONTROLS ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(icon: const Icon(Icons.skip_previous, color: Colors.white, size: 35), onPressed: _playPrevious),
              IconButton(icon: const Icon(Icons.fast_rewind, color: Colors.white, size: 30), onPressed: _seekBackward),
              GestureDetector(
                onTap: () {
                  _isPlaying ? widget.audioPlayer.pause() : widget.audioPlayer.resume();
                },
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.black, size: 40),
                ),
              ),
              IconButton(icon: const Icon(Icons.fast_forward, color: Colors.white, size: 30), onPressed: _seekForward),
              IconButton(icon: const Icon(Icons.skip_next, color: Colors.white, size: 35), onPressed: _playNext),
            ],
          ),
          const SizedBox(height: 20),

          // --- NOW PLAYING & QUEUE (Up Next) ---
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF121212),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Now Playing Info
                  ListTile(
                    leading: const Icon(Icons.volume_up, color: Colors.white),
                    title: Text(title, style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    subtitle: Text(lyricist, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    trailing: const Icon(Icons.more_vert, color: Colors.white54),
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  
                  // Up Next Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Up next", style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 16)),
                        Row(
                          children: const [
                            Icon(Icons.shuffle, color: Colors.white54, size: 20),
                            SizedBox(width: 20),
                            Icon(Icons.repeat, color: Colors.white54, size: 20),
                            SizedBox(width: 20),
                            Icon(Icons.more_vert, color: Colors.white54, size: 20),
                          ],
                        )
                      ],
                    ),
                  ),

                  // The Queue List
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.songsList.length - (currentIndex + 1),
                      itemBuilder: (context, index) {
                        var nextIndex = currentIndex + 1 + index;
                        var song = widget.songsList[nextIndex];
                        return ListTile(
                          leading: Text("${index + 1}", style: const TextStyle(color: Colors.white54, fontSize: 16)),
                          title: Text(song['title'] ?? 'Unknown', style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 16)),
                          subtitle: Text(song['lyricist'] ?? '', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                          trailing: const Icon(Icons.more_vert, color: Colors.white54),
                          onTap: () => _playSong(nextIndex), // క్యూ లో పాట నొక్కితే ప్లే అవుతుంది
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
