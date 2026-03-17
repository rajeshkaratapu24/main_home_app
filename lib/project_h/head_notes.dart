import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeadNotes extends StatefulWidget {
  const HeadNotes({super.key});

  @override
  State<HeadNotes> createState() => _HeadNotesState();
}

class _HeadNotesState extends State<HeadNotes> {
  // మన నోట్స్ స్టోర్ చేసుకోవడానికి లిస్ట్
  List<Map<String, dynamic>> myNotes = [
    {
      "id": "1",
      "title": "Trinity - Debate Points",
      "content": "1. ఆదికాండము 1:26 - మన స్వరూపమందు మన పోలికె చొప్పున నరులను చేయుదము...\n2. యోహాను 1:1 - వాక్యము దేవుడైయుండెను.",
      "category": "Apologetics",
      "color": const Color(0xFF1E3A8A), // Dark Blue
      "date": "Oct 12"
    },
  ];

  // కొత్త నోట్ యాడ్ చేయడానికి లేదా ఎడిట్ చేయడానికి ఫంక్షన్
  void _openNoteEditor({Map<String, dynamic>? existingNote}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(existingNote: existingNote),
      ),
    );

    // ఎడిటర్ నుండి డేటా వస్తే (Save/Delete) లిస్ట్ ని అప్‌డేట్ చేస్తాం
    if (result != null) {
      setState(() {
        if (result['action'] == 'delete') {
          myNotes.removeWhere((note) => note['id'] == result['id']);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Note Deleted 🗑️"), backgroundColor: Colors.redAccent));
        } else if (result['action'] == 'save') {
          if (existingNote != null) {
            // పాత నోట్ ఎడిట్ చేస్తే
            int index = myNotes.indexWhere((note) => note['id'] == result['data']['id']);
            if (index != -1) {
              myNotes[index] = result['data'];
            }
          } else {
            // కొత్త నోట్ యాడ్ చేస్తే
            myNotes.insert(0, result['data']);
          }
        }
      });
    }
  }

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
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("My Notes", style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Expanded(
              child: myNotes.isEmpty 
              ? const Center(child: Text("No Notes yet. Click '+' to add one!", style: TextStyle(color: Colors.white54)))
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85, 
                  ),
                  itemCount: myNotes.length,
                  itemBuilder: (context, index) {
                    var note = myNotes[index];
                    return GestureDetector(
                      onTap: () => _openNoteEditor(existingNote: note), // క్లిక్ చేస్తే ఎడిటర్ ఓపెన్ అవుతుంది
                      child: _buildNoteCard(note),
                    );
                  },
                ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openNoteEditor(), // కొత్త నోట్ కోసం
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.black, size: 30),
      ),
    );
  }

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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(8)),
            child: Text(note['category'], style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
          Text(
            note['title'],
            style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              note['content'],
              style: GoogleFonts.balooTammudu2(color: Colors.white70, fontSize: 14, height: 1.4),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(note['date'], style: const TextStyle(color: Colors.white38, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// నోట్స్ రాయడానికి సపరేట్ ఫుల్ స్క్రీన్ ఎడిటర్ (Google Keep Style)
// ----------------------------------------------------------------------

class NoteEditorScreen extends StatefulWidget {
  final Map<String, dynamic>? existingNote;
  const NoteEditorScreen({super.key, this.existingNote});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  
  String selectedCategory = "Bible Study";
  Color selectedColor = const Color(0xFF1F2937); // Default Dark Gray

  final List<String> categories = ["Bible Study", "Sermon", "Apologetics", "Prayer", "General"];
  final List<Color> cardColors = [
    const Color(0xFF1F2937), // Dark Gray
    const Color(0xFF1E3A8A), // Dark Blue
    const Color(0xFF064E3B), // Dark Green
    const Color(0xFF78350F), // Dark Brown
    const Color(0xFF4C1D95), // Dark Purple
    const Color(0xFF9F1239), // Dark Rose/Red
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingNote != null) {
      _titleController.text = widget.existingNote!['title'];
      _contentController.text = widget.existingNote!['content'];
      selectedCategory = widget.existingNote!['category'];
      selectedColor = widget.existingNote!['color'];
    }
  }

  void _saveNote() {
    if (_titleController.text.trim().isEmpty && _contentController.text.trim().isEmpty) {
      Navigator.pop(context); // ఖాళీగా ఉంటే సేవ్ చేయదు
      return;
    }

    Map<String, dynamic> newNote = {
      "id": widget.existingNote != null ? widget.existingNote!['id'] : DateTime.now().millisecondsSinceEpoch.toString(),
      "title": _titleController.text.trim().isEmpty ? "Untitled Note" : _titleController.text.trim(),
      "content": _contentController.text.trim(),
      "category": selectedCategory,
      "color": selectedColor,
      "date": "Today",
    };

    Navigator.pop(context, {'action': 'save', 'data': newNote});
  }

  void _deleteNote() {
    if (widget.existingNote != null) {
      Navigator.pop(context, {'action': 'delete', 'id': widget.existingNote!['id']});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (widget.existingNote != null)
            IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: _deleteNote),
          IconButton(icon: const Icon(Icons.check, color: Colors.greenAccent, size: 30), onPressed: _saveNote),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // కేటగిరీ & కలర్ పికర్ పైన చూపిస్తాం
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: selectedCategory,
                  dropdownColor: const Color(0xFF1A1A1A),
                  style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
                  items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) => setState(() => selectedCategory = val!),
                ),
                Row(
                  children: cardColors.map((color) => GestureDetector(
                    onTap: () => setState(() => selectedColor = color),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 25, height: 25,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: selectedColor == color ? Colors.white : Colors.transparent, width: 2),
                      ),
                    ),
                  )).toList(),
                )
              ],
            ),
            const Divider(color: Colors.white24),
            const SizedBox(height: 10),
            
            // టైటిల్ టెక్స్ట్ బాక్స్
            TextField(
              controller: _titleController,
              style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: "Title",
                hintStyle: TextStyle(color: Colors.white38, fontSize: 24),
                border: InputBorder.none,
              ),
            ),
            
            // మెయిన్ వాక్యం/నోట్స్ టెక్స్ట్ బాక్స్
            Expanded(
              child: TextField(
                controller: _contentController,
                style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 18, height: 1.5),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  hintText: "Type your thoughts, sermons or verses here...",
                  hintStyle: TextStyle(color: Colors.white24, fontSize: 18),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
