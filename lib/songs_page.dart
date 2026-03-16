import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
// ఫోల్డర్ స్ట్రక్చర్ ప్రకారం కరెక్ట్ లింక్ ఇస్తున్నాం
import 'songs/album_songs_page.dart'; 

class SongsPage extends StatelessWidget {
  const SongsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("ఆల్బమ్స్", style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 24, letterSpacing: 2)),
        backgroundColor: Colors.black,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('albums').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("ప్రస్తుతానికి ఆల్బమ్స్ లేవు", style: GoogleFonts.balooTammudu2(color: Colors.white54, fontSize: 18)));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(15),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 0.85
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var album = snapshot.data!.docs[index];
              var cover = album['coverUrl'] ?? '';
              
              return GestureDetector(
                onTap: () {
                  // ఆల్బమ్ మీద క్లిక్ చేస్తే దాని పాటల పేజీకి వెళ్తాం
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => AlbumSongsPage(
                      albumId: album.id, 
                      albumName: album['name'],
                      coverUrl: cover,
                    )
                  ));
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(15),
                    image: cover.isNotEmpty ? DecorationImage(image: NetworkImage(cover), fit: BoxFit.cover, opacity: 0.6) : null,
                  ),
                  child: Center(
                    child: Text(
                      album['name'], 
                      style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold), 
                      textAlign: TextAlign.center
                    )
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
