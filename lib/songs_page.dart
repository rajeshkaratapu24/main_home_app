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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------------------------
            // HEADER SECTION
            // ------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "A L B U M S",
                    style: GoogleFonts.ubuntu(
                      color: Colors.white, 
                      fontSize: 22, 
                      fontWeight: FontWeight.bold, 
                      letterSpacing: 2
                    ),
                  ),
                  // కుడివైపు మూలన చిన్నగా, స్టైలిష్ గా WOG BEATS
                  Text(
                    "WOG BEATS",
                    style: GoogleFonts.righteous(
                      color: Colors.pinkAccent, 
                      fontSize: 14, 
                      letterSpacing: 1
                    ),
                  ),
                ],
              ),
            ),

            // ------------------------------------
            // FIREBASE GRID VIEW (కార్డ్ డిజైన్)
            // ------------------------------------
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('albums').orderBy('timestamp', descending: true).snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.pinkAccent));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.album_outlined, size: 80, color: Colors.white24),
                          const SizedBox(height: 15),
                          Text("ప్రస్తుతానికి ఆల్బమ్స్ లేవు", style: GoogleFonts.balooTammudu2(color: Colors.white54, fontSize: 20)),
                        ],
                      )
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, 
                      crossAxisSpacing: 15, 
                      mainAxisSpacing: 15, 
                      childAspectRatio: 0.8 // కార్డ్ పర్ఫెక్ట్ సైజ్ కోసం
                    ),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var album = snapshot.data!.docs[index];
                      var cover = album['coverUrl'] ?? '';
                      var albumName = album['name'] ?? 'Unknown Album';
                      // ఫైర్‌బేస్ లో 'year' ఉంటే అది వస్తుంది, లేకపోతే డీఫాల్ట్ గా 2026 చూపిస్తుంది
                      var year = (album.data() as Map<String, dynamic>).containsKey('year') ? album['year'] : '2026';

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => AlbumSongsPage(
                              albumId: album.id, 
                              albumName: albumName,
                              coverUrl: cover,
                            )
                          ));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: const Color(0xFF1A1A1A),
                            border: Border.all(color: Colors.white12, width: 1),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5))
                            ]
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Stack(
                              children: [
                                // 1. ఆల్బమ్ ఇమేజ్
                                Positioned.fill(
                                  child: cover.isNotEmpty
                                      ? Image.network(cover, fit: BoxFit.cover)
                                      : Container(color: const Color(0xFF222222)),
                                ),

                                // 2. టెక్స్ట్ చదవడానికి గ్రేడియంట్ షాడో
                                Positioned(
                                  bottom: 0, left: 0, right: 0,
                                  child: Container(
                                    height: 90,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [Colors.black.withOpacity(0.95), Colors.transparent],
                                      ),
                                    ),
                                  ),
                                ),

                                // 3. ఇయర్ బ్యాడ్జ్ (కార్డ్ లోపల కుడి వైపు పైన)
                                Positioned(
                                  top: 8, right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.white24, width: 0.5)
                                    ),
                                    child: Text(
                                      year,
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                                    ),
                                  ),
                                ),

                                // 4. ఆల్బమ్ పేరు
                                Positioned(
                                  bottom: 12, left: 12, right: 12,
                                  child: Text(
                                    albumName, 
                                    style: GoogleFonts.balooTammudu2(
                                      color: Colors.white, 
                                      fontSize: 16, 
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
            ),
          ],
        ),
      ),
    );
  }
}
