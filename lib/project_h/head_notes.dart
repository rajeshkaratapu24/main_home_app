import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeadNotes extends StatefulWidget {
  const HeadNotes({super.key});

  @override
  State<HeadNotes> createState() => _HeadNotesState();
}

class _HeadNotesState extends State<HeadNotes> {
  // గూగుల్ కీప్ స్టైల్ డమ్మీ నోట్స్ డేటా
  List<Map<String, dynamic>> myNotes = [
    {
      "title": "Trinity - Debate Points",
      "content": "1. ఆదికాండము 1:26 - మన స్వరూపమందు మన పోలికె చొప్పున నరులను చేయుదము...\n2. యోహాను 1:1 - వాక్యము దేవుడైయుండెను.",
      "category": "Apologetics",
      "color": const Color(0xFF1E3A8A), // Dark Blue
      "date": "Oct 12"
    },
    {
      "title": "Sunday Sermon: Faith",
      "content": "భయపడకుము, నేను నీకు తోడైయున్నాను. (యెషయా 41:10). దేవుని వాగ్దానం మీద నమ్మకం ఉంచాలి. పరిస్థితులను చూసి భయపడకూడదు.",
      "category": "Sermon",
      "color": const Color(0xFF064E3B), // Dark Green
      "date": "Oct 15"
    },
    {
      "title": "Historical Evidence of Bible",
      "content": "Tacitus and Josephus writings perfectly align with the New Testament historical events regarding Jesus.",
      "category": "Apologetics",
      "color": const Color(0xFF78350F), // Dark Brown
      "date": "Oct 18"
    },
    {
      "title": "Romans Chapter 8 Study",
      "content": "కాబట్టి ఇప్పుడు క్రీస్తుయేసునందున్న వారికి ఏ శిక్షావిధియు లేదు. శరీరము నాశ్రయించి నడుచుకొనక ఆత్మనాశ్రయించియే...",
      "category": "Bible Study",
      "color": const Color(0xFF4C1D95), // Dark Purple
      "date": "Today"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("H E A D", style: GoogleFonts.ubuntu(color: Colors.white, letterSpacing: 4, fontSize: 18)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.grid_view, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("My Notes", style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85, // కార్డ్ హైట్ అడ్జస్ట్ చేయడానికి
                ),
                itemCount: myNotes.length,
                itemBuilder: (context, index) {
                  var note = myNotes[index];
                  return _buildNoteCard(note);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // కొత్త నోట్ యాడ్ చేసే ఫామ్ ఫ్యూచర్ లో ఇక్కడ వస్తుంది
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Add Note coming soon!")));
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.black, size: 30),
      ),
    );
  }

  // గూగుల్ కీప్ స్టైల్ కార్డ్ డిజైన్
  Widget _buildNoteCard(Map<String, dynamic> note) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: note['color'].withOpacity(0.6),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // కేటగిరీ ట్యాగ్
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(note['category'], style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
          
          // టైటిల్
          Text(
            note['title'],
            style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          
          // కంటెంట్ (వాక్యం/నోట్స్)
          Expanded(
            child: Text(
              note['content'],
              style: GoogleFonts.balooTammudu2(color: Colors.white70, fontSize: 14, height: 1.4),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // డేట్
          Align(
            alignment: Alignment.bottomRight,
            child: Text(note['date'], style: const TextStyle(color: Colors.white38, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
