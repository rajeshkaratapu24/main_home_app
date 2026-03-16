import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminSongs extends StatefulWidget {
  final String albumId;
  final String albumName;

  const AdminSongs({super.key, required this.albumId, required this.albumName});

  @override
  State<AdminSongs> createState() => _AdminSongsState();
}

class _AdminSongsState extends State<AdminSongs> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _lyricistController = TextEditingController(text: "రాజేష్ కరాటపు / రాజా తాళ్లూరి");
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _coverController = TextEditingController();

  // పాట యాడ్/ఎడిట్ చేసే పాపప్ ఫామ్
  void _showSongDialog({String? songId, Map<String, dynamic>? existingData}) {
    if (existingData != null) {
      _titleController.text = existingData['title'] ?? '';
      _lyricistController.text = existingData['lyricist'] ?? '';
      _urlController.text = existingData['songUrl'] ?? '';
      _coverController.text = existingData['coverUrl'] ?? '';
    } else {
      _titleController.clear();
      _urlController.clear();
      _coverController.clear();
      _lyricistController.text = "రాజేష్ కరాటపు / రాజా తాళ్లూరి";
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(songId == null ? "కొత్త పాట యాడ్ చేయండి" : "పాట ఎడిట్ చేయండి", style: GoogleFonts.balooTammudu2(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _titleController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "పాట పేరు", hintStyle: TextStyle(color: Colors.white54))),
              const SizedBox(height: 10),
              TextField(controller: _lyricistController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "రచయిత", hintStyle: TextStyle(color: Colors.white54))),
              const SizedBox(height: 10),
              TextField(controller: _urlController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "ఆడియో లింక్ (MP3 URL)", hintStyle: TextStyle(color: Colors.white54))),
              const SizedBox(height: 10),
              TextField(controller: _coverController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "సాంగ్ కవర్ ఇమేజ్ (URL)", hintStyle: TextStyle(color: Colors.white54))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL", style: TextStyle(color: Colors.redAccent))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
            onPressed: () async {
              if (_titleController.text.isNotEmpty && _urlController.text.isNotEmpty) {
                var songData = {
                  'albumId': widget.albumId, // ఈ పాట ఏ ఆల్బమ్ దో గుర్తుపట్టడానికి
                  'title': _titleController.text.trim(),
                  'lyricist': _lyricistController.text.trim(),
                  'songUrl': _urlController.text.trim(),
                  'coverUrl': _coverController.text.trim(),
                  'timestamp': FieldValue.serverTimestamp(),
                };

                if (songId == null) {
                  await FirebaseFirestore.instance.collection('songs').add(songData); // కొత్తది
                } else {
                  await FirebaseFirestore.instance.collection('songs').doc(songId).update(songData); // ఎడిట్
                }
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text("SAVE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _deleteSong(String songId) async {
    await FirebaseFirestore.instance.collection('songs').doc(songId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.albumName, style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 22)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.greenAccent,
        onPressed: () => _showSongDialog(),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      // ఇక్కడ కేవలం ఈ ఆల్బమ్ (albumId) కి సంబంధించిన పాటలే లాగుతున్నాం
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('songs').where('albumId', isEqualTo: widget.albumId).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) return Center(child: Text("ఈ ఆల్బమ్ లో పాటలు లేవు", style: GoogleFonts.balooTammudu2(color: Colors.white54, fontSize: 18)));

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var song = snapshot.data!.docs[index];
              var data = song.data() as Map<String, dynamic>;
              var cover = data['coverUrl'] ?? '';

              return Card(
                color: const Color(0xFF1A1A1A),
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: cover.isNotEmpty 
                      ? ClipRRect(borderRadius: BorderRadius.circular(5), child: Image.network(cover, width: 50, height: 50, fit: BoxFit.cover))
                      : const Icon(Icons.music_note, color: Colors.white, size: 40),
                  title: Text(data['title'] ?? '', style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 18)),
                  subtitle: Text(data['lyricist'] ?? '', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blueAccent), onPressed: () => _showSongDialog(songId: song.id, existingData: data)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () => _deleteSong(song.id)),
                    ],
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
