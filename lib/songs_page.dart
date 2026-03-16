import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'album_songs_page.dart';

class SongsPage extends StatelessWidget {
  const SongsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A), // డీప్ బ్లాక్ థీమ్
      appBar: AppBar(
        title: Text("ఆల్బమ్స్", style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        backgroundColor: Colors.transparent,
        centerTitle: false, // ఎడమవైపుకి జరిపాం (మాడ్రన్ లుక్ కోసం)
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('albums').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.album_outlined, size: 80, color: Colors.white24),
                  const SizedBox(height: 15),
                  Text("ప్రస్తుతానికి ఆల్బమ్స్ లేవు", style: GoogleFonts.balooTammudu2(color: Colors.white54, fontSize: 20)),
                ],
              )
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, 
              crossAxisSpacing: 16, 
              mainAxisSpacing: 16, 
              childAspectRatio: 0.8 // కార్డ్ కొంచెం పొడవుగా ఉండటానికి
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var album = snapshot.data!.docs[index];
              var cover = album['coverUrl'] ?? '';
              
              return GestureDetector(
                onTap: () {
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
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xFF1A1A1A),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ]
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        // 1. ఆల్బమ్ ఇమేజ్ లేయర్ (ఎర్రర్ వస్తే డీఫాల్ట్ ఐకాన్ చూపిస్తుంది)
                        Positioned.fill(
                          child: cover.isNotEmpty
                              ? Image.network(
                                  cover,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: const Color(0xFF222222),
                                      child: const Icon(Icons.music_note, color: Colors.white24, size: 50),
                                    );
                                  },
                                )
                              : Container(
                                  color: const Color(0xFF222222),
                                  child: const Icon(Icons.album, color: Colors.white24, size: 50),
                                ),
                        ),
                        
                        // 2. గ్రేడియంట్ బ్లాక్ షాడో (టెక్స్ట్ చదవడానికి ఈజీగా ఉండటానికి)
                        Positioned(
                          bottom: 0, left: 0, right: 0,
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.9),
                                  Colors.black.withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // 3. ఆల్బమ్ పేరు 
                        Positioned(
                          bottom: 12, left: 12, right: 12,
                          child: Text(
                            album['name'], 
                            style: GoogleFonts.balooTammudu2(
                              color: Colors.white, 
                              fontSize: 18, 
                              fontWeight: FontWeight.bold,
                              height: 1.2
                            ), 
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
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
