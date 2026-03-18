import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HeadNotes extends StatefulWidget {
  const HeadNotes({super.key});

  @override
  State<HeadNotes> createState() => _HeadNotesState();
}

class _HeadNotesState extends State<HeadNotes> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // కొత్త నోట్ యాడ్ చేయడానికి లేదా ఎడిట్ చేయడానికి ఫంక్షన్
  void _openNoteEditor({DocumentSnapshot? existingNote}) {
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please Login to save notes!"), backgroundColor: Colors.red),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(existingNote: existingNote, userId: currentUser!.uid),
      ),
    );
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
            
            // ఫైర్‌బేస్ నుండి లైవ్ డేటా లాగడానికి StreamBuilder
            Expanded(
              child: currentUser == null 
              ? const Center(child: Text("Please login to see your notes.", style: TextStyle(color: Colors.white54)))
              : StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUser!.uid)
                      .collection('head_notes')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No Notes yet. Click '+' to add one!", style: TextStyle(color: Colors.white54)));
                    }

                    var notes = snapshot.data!.docs;

                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85, 
                      ),
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        var note = notes[index];
                        return GestureDetector(
                          onTap: () => _openNoteEditor(existingNote: note), 
                          child: _buildNoteCard(note),
                        );
                      },
                    );
                  },
                ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openNoteEditor(), 
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.black, size: 30),
      ),
    );
  }

  Widget _buildNoteCard(DocumentSnapshot note) {
    Map<String, dynamic> data = note.data() as Map<String, dynamic>;
    Color cardColor = Color(data['color'] ?? 0xFF1F2937);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(8)),
            child: Text(data['category'] ?? 'General', style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
          Text(
            data['title'] ?? '',
            style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              data['content'] ?? '',
              style: GoogleFonts.balooTammudu2(color: Colors.white70, fontSize: 14, height: 1.4),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(data['date'] ?? '', style: const TextStyle(color: Colors.white38, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// నోట్స్ రాయడానికి ఫుల్ స్క్రీన్ ఎడిటర్ (ఫైర్‌బేస్ సేవ్/డిలీట్ లాజిక్ తో)
// ----------------------------------------------------------------------

class NoteEditorScreen extends StatefulWidget {
  final DocumentSnapshot? existingNote;
  final String userId;
  
  const NoteEditorScreen({super.key, this.existingNote, required this.userId});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  
  String selectedCategory = "Bible Study";
  Color selectedColor = const Color(0xFF1F2937); 

  final List<String> categories = ["Bible Study", "Sermon", "Apologetics", "Prayer", "General"];
  final List<Color> cardColors = [
    const Color(0xFF1F2937), // Dark Gray
    const Color(0xFF1E3A8A), // Dark Blue
    const Color(0xFF064E3B), // Dark Green
    const Color(0xFF78350F), // Dark Brown
    const Color(0xFF4C1D95), // Dark Purple
    const Color(0xFF9F1239), // Dark Rose/Red
  ];

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingNote != null) {
      Map<String, dynamic> data = widget.existingNote!.data() as Map<String, dynamic>;
      _titleController.text = data['title'] ?? '';
      _contentController.text = data['content'] ?? '';
      selectedCategory = data['category'] ?? 'Bible Study';
      selectedColor = Color(data['color'] ?? 0xFF1F2937);
    }
  }

  // ఫైర్‌బేస్ లో సేవ్ చేసే ఫంక్షన్
  Future<void> _saveNote() async {
    if (_titleController.text.trim().isEmpty && _contentController.text.trim().isEmpty) {
      Navigator.pop(context); 
      return;
    }

    setState(() => isSaving = true);

    CollectionReference notesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('head_notes');

    Map<String, dynamic> noteData = {
      "title": _titleController.text.trim().isEmpty ? "Untitled Note" : _titleController.text.trim(),
      "content": _contentController.text.trim(),
      "category": selectedCategory,
      "color": selectedColor.value, // కలర్ కోడ్ ని నంబర్ లాగా సేవ్ చేస్తున్నాం
      "date": "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
      "timestamp": FieldValue.serverTimestamp(), // సార్టింగ్ కోసం లైవ్ టైమ్
    };

    if (widget.existingNote == null) {
      await notesRef.add(noteData); // కొత్తది అయితే Add
    } else {
      await notesRef.doc(widget.existingNote!.id).update(noteData); // పాతది అయితే Update
    }

    if (mounted) Navigator.pop(context);
  }

  // ఫైర్‌బేస్ నుండి డిలీట్ చేసే ఫంక్షన్
  Future<void> _deleteNote() async {
    if (widget.existingNote != null) {
      setState(() => isSaving = true);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('head_notes')
          .doc(widget.existingNote!.id)
          .delete();
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Note Deleted 🗑️"), backgroundColor: Colors.redAccent));
      }
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
            IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: isSaving ? null : _deleteNote),
          
          isSaving 
            ? const Padding(padding: EdgeInsets.all(12.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.greenAccent, strokeWidth: 2)))
            : IconButton(icon: const Icon(Icons.check, color: Colors.greenAccent, size: 30), onPressed: _saveNote),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
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
            
            TextField(
              controller: _titleController,
              style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: "Title",
                hintStyle: TextStyle(color: Colors.white38, fontSize: 24),
                border: InputBorder.none,
              ),
            ),
            
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
