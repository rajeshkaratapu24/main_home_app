import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart'; // మ్యూజిక్ ప్లేయర్ ప్యాకేజీ

class SongsPage extends StatefulWidget {
  const SongsPage({super.key});

  @override
  State<SongsPage> createState() => _SongsPageState();
}

class _SongsPageState extends State<SongsPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingId; // ప్రస్తుతం ఏ పాట ప్లే అవుతుందో తెలుసుకోవడానికి
  bool _isPlaying = false;

  @override
  void dispose() {
    _audioPlayer.dispose(); // పేజీ నుండి బయటకి వెళ్ళగానే పాట ఆగిపోవడానికి
    super.dispose();
  }

  // పాట ప్లే/పాజ్ చేసే లాజిక్
  void _togglePlay(String songId, String url) async {
    if (_currentlyPlayingId == songId) {
      if (_isPlaying) {
        await _audioPlayer.pause();
        setState(() => _isPlaying = false);
      } else {
        await _audioPlayer.resume();
        setState(() => _isPlaying = true);
      }
    } else {
      await _audioPlayer.stop(); // వేరే పాట ప్లే అవుతుంటే ఆపేస్తాం
      await _audioPlayer.play(UrlSource(url)); // కొత్త పాట స్టార్ట్ చేస్తాం
      setState(() {
        _currentlyPlayingId = songId;
        _isPlaying = true;
      });
    }
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
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('songs').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("ప్రస్తుతానికి పాటలు లేవు", style: GoogleFonts.balooTammudu2(color: Colors.white54, fontSize: 18)));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            padding: const EdgeInsets.all(15),
            itemBuilder: (context, index) {
              var song = snapshot.data!.docs[index];
              var songId = song.id;
              var songUrl = song['songUrl'];
              
              // ఈ పాటే ప్లే అవుతోందా అని చెక్ చేయడం
              bool isThisSongPlaying = _currentlyPlayingId == songId && _isPlaying;

              return Card(
                color: const Color(0xFF1A1A1A),
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    radius: 25,
                    child: Icon(Icons.music_note, color: Colors.white),
                  ),
                  title: Text(song['title'] ?? 'Unknown', style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Text(song['lyricist'] ?? '', style: GoogleFonts.balooTammudu2(color: Colors.white70, fontSize: 14)),
                  trailing: IconButton(
                    icon: Icon(
                      isThisSongPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill, 
                      color: isThisSongPlaying ? Colors.redAccent : Colors.greenAccent, 
                      size: 45
                    ),
                    onPressed: () => _togglePlay(songId, songUrl),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
