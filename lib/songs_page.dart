import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class SongsPage extends StatelessWidget {
  const SongsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("పాటలు", style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 24)),
        backgroundColor: Colors.black,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      // StreamBuilder ద్వారా ఫైర్‌బేస్ నుండి డేటా తెస్తున్నాం
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
              return Card(
                color: const Color(0xFF1A1A1A),
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    radius: 25,
                    child: Icon(Icons.music_note, color: Colors.white),
                  ),
                  title: Text(song['title'] ?? 'Unknown', style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Text(song['lyricist'] ?? '', style: GoogleFonts.balooTammudu2(color: Colors.white70, fontSize: 14)),
                  trailing: IconButton(
                    icon: const Icon(Icons.play_circle_fill, color: Colors.greenAccent, size: 45),
                    onPressed: () {
                      // నెక్స్ట్ ఇక్కడే ఆడియో ప్లేయర్ లాజిక్ రాస్తాం
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Playing: ${song['title']}")));
                    },
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
