import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class UploadSong extends StatefulWidget {
  const UploadSong({super.key});

  @override
  State<UploadSong> createState() => _UploadSongState();
}

class _UploadSongState extends State<UploadSong> {
  // పాత కంట్రోలర్స్
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _lyricistController = TextEditingController(text: "రాజేష్ కరాటపు / రాజా తాళ్లూరి");
  final TextEditingController _urlController = TextEditingController();
  
  // కొత్తగా యాడ్ చేసిన కంట్రోలర్స్
  final TextEditingController _albumNameController = TextEditingController();
  final TextEditingController _playlistController = TextEditingController();
  final TextEditingController _yearController = TextEditingController(text: "2026");
  final TextEditingController _songCoverController = TextEditingController();
  final TextEditingController _albumCoverController = TextEditingController();
  
  bool _isLoading = false;

  Future<void> _saveSongToDatabase() async {
    if (_titleController.text.isEmpty || _urlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("దయచేసి పాట పేరు మరియు లింక్ ఇవ్వండి!")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ఫైర్‌బేస్ డేటాబేస్ లోకి పాత లాజిక్ తో పాటే కొత్త డేటా కూడా పంపుతున్నాం
      await FirebaseFirestore.instance.collection('songs').add({
        'title': _titleController.text.trim(),
        'lyricist': _lyricistController.text.trim(),
        'songUrl': _urlController.text.trim(),
        
        // కొత్త ఫీల్డ్స్
        'albumName': _albumNameController.text.trim(),
        'playlistName': _playlistController.text.trim(),
        'albumYear': _yearController.text.trim(),
        'songCoverUrl': _songCoverController.text.trim(),
        'albumCoverUrl': _albumCoverController.text.trim(),
        
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("పాట సక్సెస్ ఫుల్ గా సేవ్ అయ్యింది!")));
        
        // సక్సెస్ అయ్యాక బాక్సులన్నీ ఖాళీ చేయడానికి
        _titleController.clear();
        _urlController.clear();
        _albumNameController.clear();
        _playlistController.clear();
        _songCoverController.clear();
        _albumCoverController.clear();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("ఎర్రర్: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("పాటల అప్‌లోడ్", style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 22)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      // ఫీల్డ్స్ ఎక్కువయ్యాయి కాబట్టి ListView వాడాము
      body: ListView(
        padding: const EdgeInsets.all(25.0),
        children: [
          const Text("పాట & ఆల్బమ్ వివరాలు ఎంటర్ చేయండి", style: TextStyle(color: Colors.white54, fontSize: 14, letterSpacing: 1)),
          const SizedBox(height: 30),
          
          // కొత్త ఆల్బమ్ ఫీల్డ్స్
          _buildTextField(_albumNameController, "ఆల్బమ్ పేరు (Album Name)", Icons.album),
          const SizedBox(height: 15),
          _buildTextField(_playlistController, "ప్లే లిస్ట్ (Play List Name)", Icons.playlist_play),
          const SizedBox(height: 15),
          _buildTextField(_yearController, "సంవత్సరం (Album Year) ఉదా: 2026", Icons.date_range),
          const SizedBox(height: 15),
          
          // పాత పాట వివరాలు
          _buildTextField(_titleController, "పాట పేరు (ఉదా: దేవుని స్నేహం)", Icons.music_note),
          const SizedBox(height: 15),
          _buildTextField(_lyricistController, "రచన", Icons.person),
          const SizedBox(height: 15),
          
          // కొత్త కవర్ పేజ్ లింక్స్
          _buildTextField(_songCoverController, "Song Cover Page Link", Icons.image),
          const SizedBox(height: 15),
          _buildTextField(_albumCoverController, "Album Cover Page Link", Icons.photo_album),
          const SizedBox(height: 15),
          
          // గిట్‌హబ్ లింక్ (పాతది)
          _buildTextField(_urlController, "GitHub MP3 లింక్ ఇక్కడ పేస్ట్ చేయండి", Icons.link),
          const SizedBox(height: 40),

          // సేవ్ బటన్ (నీ పాత డిజైన్)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
              ),
              onPressed: _isLoading ? null : _saveSongToDatabase,
              child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : Text("SAVE TO DATABASE", style: GoogleFonts.balooTammudu2(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // టెక్స్ట్ ఫీల్డ్ డిజైన్ (నీ పాత స్టైల్ యాజ్ టీజ్ గా)
  Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }
}
