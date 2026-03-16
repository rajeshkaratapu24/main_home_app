import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';

class SongsPage extends StatefulWidget {
  const SongsPage({super.key});

  @override
  State<SongsPage> createState() => _SongsPageState();
}

class _SongsPageState extends State<SongsPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late Stream<QuerySnapshot> _songsStream; // ఫిక్స్ 1: స్ట్రీమ్ ని ఫ్రీజ్ చేయడం
  
  // Player States
  String? _currentlyPlayingId;
  String _currentTitle = "";
  String _currentLyricist = "";
  bool _isPlaying = false;
  
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    
    // డేటాబేస్ స్ట్రీమ్ ని ఒక్కసారే కాల్ చేసి దాచుకుంటున్నాం (బ్లింక్ అవ్వకుండా)
    _songsStream = FirebaseFirestore.instance.collection('songs').orderBy('timestamp', descending: true).snapshots();
    
    // పాట మొత్తం నిడివి కోసం
    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) setState(() => _duration = newDuration);
    });

    // పాట అయిపోగానే ఆగిపోవడానికి
    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // ప్లే & పాజ్ లాజిక్
  void _playSong(String songId, String url, String title, String lyricist) async {
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
        _currentLyricist = lyricist;
        _isPlaying = true;
      });
      await _audioPlayer.play(UrlSource(url));
    }
  }

  // టైమ్ ఫార్మాట్ (ఉదా: 03:45)
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
        title: Text("పాటలు", style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 24, letterSpacing: 2)),
        backgroundColor: Colors.black,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // ఫిక్స్ 1: ఫ్రీజ్ చేసిన స్ట్రీమ్ ని వాడుతున్నాం
          StreamBuilder<QuerySnapshot>(
            stream: _songsStream, 
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text("ప్రస్తుతానికి పాటలు లేవు", style: GoogleFonts.balooTammudu2(color: Colors.white54, fontSize: 18)));
              }

              return ListView.builder(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 120), 
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var song = snapshot.data!.docs[index];
                  var songId = song.id;
                  var title = song['title'] ?? 'Unknown';
                  var lyricist = song['lyricist'] ?? '';
                  var songUrl = song['songUrl'];
                  
                  bool isThisSongPlaying = _currentlyPlayingId == songId;

                  return Card(
                    color: isThisSongPlaying ? const Color(0xFF2A2A2A) : const Color(0xFF1A1A1A),
                    margin: const EdgeInsets.only(bottom: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: isThisSongPlaying ? Colors.greenAccent : Colors.blueAccent,
                        radius: 25,
                        child: Icon(isThisSongPlaying ? Icons.multitrack_audio : Icons.music_note, 
                                  color: isThisSongPlaying ? Colors.black : Colors.white),
                      ),
                      title: Text(title, style: GoogleFonts.balooTammudu2(color: isThisSongPlaying ? Colors.greenAccent : Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: Text(lyricist, style: GoogleFonts.balooTammudu2(color: Colors.white70, fontSize: 14)),
                      onTap: () => _playSong(songId, songUrl, title, lyricist),
                    ),
                  );
                },
              );
            },
          ),
          
          if (_currentlyPlayingId != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF222222),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white10),
                  boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10, spreadRadius: 2)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ఫిక్స్ 2: స్లైడర్ (ప్రోగ్రెస్) ని సపరేట్ StreamBuilder లో పెట్టాం
                    // దీనివల్ల బ్యాక్ గ్రౌండ్ లో లిస్ట్ రీఫ్రెష్ అవ్వదు, కేవలం స్లైడర్ మాత్రమే స్మూత్ గా వెళ్తుంది!
                    StreamBuilder<Duration>(
                      stream: _audioPlayer.onPositionChanged,
                      builder: (context, snapshot) {
                        final position = snapshot.data ?? Duration.zero;
                        return Column(
                          children: [
                            SizedBox(
                              height: 20,
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 3,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                                  activeTrackColor: Colors.greenAccent,
                                  inactiveTrackColor: Colors.white24,
                                  thumbColor: Colors.greenAccent,
                                ),
                                child: Slider(
                                  min: 0,
                                  max: _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1,
                                  value: position.inSeconds.toDouble().clamp(0, _duration.inSeconds.toDouble()),
                                  onChanged: (value) async {
                                    await _audioPlayer.seek(Duration(seconds: value.toInt()));
                                  },
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
                                      Text(_currentTitle, 
                                        maxLines: 1, overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                      Text("${_formatTime(position)} / ${_formatTime(_duration)}", 
                                        style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill, size: 40, color: Colors.greenAccent),
                                  onPressed: () {
                                    if (_isPlaying) {
                                      _audioPlayer.pause();
                                      setState(() => _isPlaying = false);
                                    } else {
                                      _audioPlayer.resume();
                                      setState(() => _isPlaying = true);
                                    }
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
        ],
      ),
    );
  }
}
