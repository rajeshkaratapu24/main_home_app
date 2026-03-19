import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui'; // గ్లాస్ ఎఫెక్ట్ (Blur) కోసం
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
            // HEADER SECTION (WOG BEATS)
            // ------------------------------------
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 20.0, bottom: 10.0),
              child: Row(
                children: [
                  // ఒకవేళ యూజర్ బ్యాక్ వెళ్ళడానికి (హోమ్ పేజీకి) బటన్ కావాలంటే
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    "W O G   B E A T S",
                    style: GoogleFonts.righteous(
                      color: Colors.white,
                      fontSize: 26,
                      letterSpacing: 3,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // ------------------------------------
            // FIREBASE ALBUM LIST (అందమైన కార్డ్ వ్యూ)
            // ------------------------------------
            Expanded(
              child: StreamBuilder(
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
                          const Icon(Icons.album_outlined, size: 80, color: Colors.white24),
                          const SizedBox(height: 15),
                          Text("ప్రస్తుతానికి ఆల్బమ్స్ లేవు", style: GoogleFonts.balooTammudu2(color: Colors.white54, fontSize: 20)),
                        ],
                      )
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var album = snapshot.data!.docs[index];
                      var cover = album['coverUrl'] ?? '';
                      var albumName = album['name'] ?? 'Unknown Album';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 20.0),
                        height: 120,
                        // కార్డ్ వెనకాల గ్లాస్ బ్లర్ ఎఫెక్ట్
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            children: [
                              // 1. కార్డ్ బ్యాక్‌గ్రౌండ్ ఇమేజ్ (బ్లర్ చేసి ఉంటుంది)
                              Positioned.fill(
                                child: cover.isNotEmpty
                                    ? Image.network(cover, fit: BoxFit.cover)
                                    : Container(color: const Color(0xFF222222)),
                              ),
                              
                              // 2. గ్లాస్ ఎఫెక్ట్ (బ్లర్ + ట్రాన్స్‌పరెంట్ బ్లాక్ కలర్)
                              Positioned.fill(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                                  child: Container(
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                ),
                              ),
                              
                              // 3. ఆల్బమ్ వివరాలు (Text & Image)
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Row(
                                  children: [
                                    // ఆల్బమ్ ఇమేజ్ (కార్డ్ లోపల క్లియర్ గా)
                                    Container(
                                      width: 90,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(color: Colors.white24, width: 2),
                                        boxShadow: [
                                          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5))
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(13),
                                        child: cover.isNotEmpty
                                            ? Image.network(
                                                cover, 
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.music_note, color: Colors.white24, size: 40),
                                              )
                                            : const Icon(Icons.album, color: Colors.white24, size: 40),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    
                                    // ఆల్బమ్ టైటిల్
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            albumName,
                                            style: GoogleFonts.balooTammudu2(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              height: 1.2
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 5),
                                          const Text(
                                            "Tap to play songs",
                                            style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // ప్లే బటన్ ఐకాన్
                                    const Icon(Icons.play_circle_fill, color: Colors.white70, size: 35),
                                  ],
                                ),
                              ),
                              
                              // 4. కార్డ్ చుట్టూ చిన్న బోర్డర్ (ప్రీమియం లుక్ కోసం)
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white12, width: 1),
                                ),
                              ),
                              
                              // 5. ట్యాప్ యాక్షన్ (నీ పాత నావిగేషన్ లాజిక్)
                              Positioned.fill(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => AlbumSongsPage(
                                          albumId: album.id, 
                                          albumName: albumName,
                                          coverUrl: cover,
                                        )
                                      ));
                                    },
                                  ),
                                ),
                              ),
                            ],
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
