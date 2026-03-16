import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_songs.dart'; // మనం నెక్స్ట్ క్రియేట్ చేయబోయే ఫైల్

class AdminAlbums extends StatefulWidget {
  const AdminAlbums({super.key});

  @override
  State<AdminAlbums> createState() => _AdminAlbumsState();
}

class _AdminAlbumsState extends State<AdminAlbums> {
  final TextEditingController _albumNameController = TextEditingController();
  final TextEditingController _albumCoverController = TextEditingController();

  // ఆల్బమ్ యాడ్ చేసే పాపప్
  void _showAddAlbumDialog() {
    _albumNameController.clear();
    _albumCoverController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text("కొత్త ఆల్బమ్", style: GoogleFonts.balooTammudu2(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _albumNameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: "ఆల్బమ్ పేరు", hintStyle: TextStyle(color: Colors.white54)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _albumCoverController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: "కవర్ ఇమేజ్ లింక్ (URL)", hintStyle: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL", style: TextStyle(color: Colors.redAccent))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
            onPressed: () async {
              if (_albumNameController.text.isNotEmpty) {
                await FirebaseFirestore.instance.collection('albums').add({
                  'name': _albumNameController.text.trim(),
                  'coverUrl': _albumCoverController.text.trim(),
                  'timestamp': FieldValue.serverTimestamp(),
                });
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text("SAVE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ఆల్బమ్ డిలీట్ చేసే ఆప్షన్
  void _deleteAlbum(String albumId) async {
    await FirebaseFirestore.instance.collection('albums').doc(albumId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("ఆల్బమ్స్ మేనేజ్‌మెంట్", style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 22)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: _showAddAlbumDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('albums').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
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
                  // ఆల్బమ్ మీద క్లిక్ చేస్తే ఆ ఆల్బమ్ లోపల ఉన్న పాటల పేజీకి వెళ్తాం
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AdminSongs(albumId: album.id, albumName: album['name'])));
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(15),
                    image: cover.isNotEmpty ? DecorationImage(image: NetworkImage(cover), fit: BoxFit.cover, opacity: 0.4) : null,
                  ),
                  child: Stack(
                    children: [
                      Center(child: Text(album['name'], style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                      Positioned(
                        right: 0, top: 0,
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _deleteAlbum(album.id),
                        ),
                      )
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
