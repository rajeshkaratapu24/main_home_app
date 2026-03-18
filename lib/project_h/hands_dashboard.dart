import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HandsDashboard extends StatefulWidget {
  const HandsDashboard({super.key});

  @override
  State<HandsDashboard> createState() => _HandsDashboardState();
}

class _HandsDashboardState extends State<HandsDashboard> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  
  String selectedFilter = "Daily";
  final List<String> filters = ["Daily", "Weekly", "Monthly", "Yearly"];

  final TextEditingController waController = TextEditingController();
  final TextEditingController instaController = TextEditingController();
  final TextEditingController fbController = TextEditingController();

  // కొత్తది యాడ్ చేయడానికి లేదా ఎడిట్ చేయడానికి ఫామ్
  void _showFormDialog({DocumentSnapshot? existingLog}) {
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please Login to track work!"), backgroundColor: Colors.red));
      return;
    }

    bool isEdit = existingLog != null;

    if (isEdit) {
      Map<String, dynamic> data = existingLog.data() as Map<String, dynamic>;
      waController.text = (data['wa'] ?? 0).toString();
      instaController.text = (data['insta'] ?? 0).toString();
      fbController.text = (data['fb'] ?? 0).toString();
    } else {
      waController.clear();
      instaController.clear();
      fbController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(isEdit ? "Edit Log" : "Log Today's Work", style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isEdit ? "నెంబర్స్ సరిచేసి సేవ్ చేయండి:" : "ఎంత మందికి వాక్యం షేర్ చేశావో ఎంటర్ చెయ్:", style: const TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 20),
            _buildInputBox("WhatsApp Reach", waController, Icons.chat, Colors.greenAccent),
            const SizedBox(height: 15),
            _buildInputBox("Instagram Reach", instaController, Icons.camera_alt, Colors.pinkAccent),
            const SizedBox(height: 15),
            _buildInputBox("Facebook Reach", fbController, Icons.facebook, Colors.blueAccent),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () async {
              int waAdd = int.tryParse(waController.text) ?? 0;
              int instaAdd = int.tryParse(instaController.text) ?? 0;
              int fbAdd = int.tryParse(fbController.text) ?? 0;
              int totalAdd = waAdd + instaAdd + fbAdd;

              if (totalAdd > 0 || isEdit) {
                // ఫైర్‌బేస్ కనెక్షన్
                CollectionReference logsRef = FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).collection('hands_logs');
                
                Map<String, dynamic> logData = {
                  'wa': waAdd,
                  'insta': instaAdd,
                  'fb': fbAdd,
                  'total': totalAdd,
                  'timestamp': isEdit ? existingLog.get('timestamp') : FieldValue.serverTimestamp(),
                };

                if (isEdit) {
                  await logsRef.doc(existingLog.id).update(logData);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Log Updated! ✏️"), backgroundColor: Colors.blue));
                } else {
                  await logsRef.add(logData);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("+$totalAdd People Reached! Praise God 🙌"), backgroundColor: Colors.green));
                }
                Navigator.pop(context);
              }
            },
            child: Text(isEdit ? "UPDATE" : "SAVE LOG", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // డేటా డిలీట్ చేయడానికి ఫంక్షన్
  void _deleteLog(String docId) async {
    await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).collection('hands_logs').doc(docId).delete();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Log Deleted 🗑️"), backgroundColor: Colors.red));
  }

  // టెక్స్ట్ బాక్స్ డిజైన్
  Widget _buildInputBox(String hint, TextEditingController controller, IconData icon, Color color) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: color, size: 20),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: Colors.black,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("H A N D S", style: GoogleFonts.ubuntu(color: Colors.white, letterSpacing: 4, fontSize: 18)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: currentUser == null 
        ? const Center(child: Text("Please login to see your impact.", style: TextStyle(color: Colors.white54)))
        : StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser!.uid)
                .collection('hands_logs')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }

              // ఫైర్‌బేస్ నుండి వచ్చిన డేటాని క్యాలిక్యులేట్ చేస్తున్నాం
              Map<String, Map<String, int>> calculatedData = {
                "Daily": {"wa": 0, "insta": 0, "fb": 0, "Total": 0},
                "Weekly": {"wa": 0, "insta": 0, "fb": 0, "Total": 0},
                "Monthly": {"wa": 0, "insta": 0, "fb": 0, "Total": 0},
                "Yearly": {"wa": 0, "insta": 0, "fb": 0, "Total": 0},
              };

              DateTime now = DateTime.now();

              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                for (var doc in snapshot.data!.docs) {
                  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                  int wa = data['wa'] ?? 0;
                  int insta = data['insta'] ?? 0;
                  int fb = data['fb'] ?? 0;
                  int total = data['total'] ?? 0;
                  
                  // Timestamp ని డేట్ లాగా మారుస్తున్నాం
                  Timestamp? ts = data['timestamp'];
                  DateTime logDate = ts != null ? ts.toDate() : DateTime.now();

                  // Yearly క్యాలిక్యులేషన్
                  if (logDate.year == now.year) {
                    _addToTotals(calculatedData["Yearly"]!, wa, insta, fb, total);
                  }
                  // Monthly
                  if (logDate.year == now.year && logDate.month == now.month) {
                    _addToTotals(calculatedData["Monthly"]!, wa, insta, fb, total);
                  }
                  // Daily
                  if (logDate.year == now.year && logDate.month == now.month && logDate.day == now.day) {
                    _addToTotals(calculatedData["Daily"]!, wa, insta, fb, total);
                  }
                  // Weekly (గత 7 రోజులు)
                  if (now.difference(logDate).inDays <= 7) {
                    _addToTotals(calculatedData["Weekly"]!, wa, insta, fb, total);
                  }
                }
              }

              var currentData = calculatedData[selectedFilter]!;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text("Your Impact Dashboard", style: GoogleFonts.balooTammudu2(color: Colors.white54, fontSize: 16)),
                    const SizedBox(height: 15),
                    
                    // Daily / Weekly / Monthly / Yearly బటన్స్
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: filters.map((filter) => _buildFilterChip(filter)).toList(),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // టోటల్ స్కోర్ కార్డ్
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF1A2980), Color(0xFF26D0CE)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Text("People Reached", style: TextStyle(color: Colors.white70, fontSize: 16)),
                          const SizedBox(height: 10),
                          Text("${currentData['Total']}", style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 50, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Text("in $selectedFilter timeframe", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),

                    Expanded(
                      child: ListView(
                        children: [
                          Text("Platform Breakdown", style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 15),
                          _buildPlatformRow("WhatsApp", currentData['wa']!, Colors.greenAccent, Icons.chat),
                          _buildPlatformRow("Instagram", currentData['insta']!, Colors.pinkAccent, Icons.camera_alt),
                          _buildPlatformRow("Facebook", currentData['fb']!, Colors.blueAccent, Icons.facebook),
                          
                          // ఫైర్‌బేస్ నుండి వచ్చే Recent Logs
                          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) ...[
                            const SizedBox(height: 25),
                            const Divider(color: Colors.white24),
                            const SizedBox(height: 10),
                            Text("Recent Logs", style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 15),
                            ...snapshot.data!.docs.map((doc) => _buildLogItem(doc)),
                            const SizedBox(height: 80),
                          ]
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
          ),
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(),
        backgroundColor: Colors.white,
        icon: const Icon(Icons.add, color: Colors.black),
        label: Text("ADD LOG", style: GoogleFonts.ubuntu(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // హెల్పర్ ఫంక్షన్ - క్యాలిక్యులేషన్ కోసం
  void _addToTotals(Map<String, int> target, int wa, int insta, int fb, int total) {
    target["wa"] = target["wa"]! + wa;
    target["insta"] = target["insta"]! + insta;
    target["fb"] = target["fb"]! + fb;
    target["Total"] = target["Total"]! + total;
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = label),
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.white : Colors.white24),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  Widget _buildPlatformRow(String name, int count, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Icon(icon, color: color)),
          const SizedBox(width: 15),
          Expanded(child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 16))),
          Text("$count", style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLogItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.transparent, border: Border.all(color: Colors.white12), borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.history, color: Colors.white54),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Total Reached: ${data['total']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 3),
                Text("WA: ${data['wa']} | Insta: ${data['insta']} | FB: ${data['fb']}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent, size: 20), onPressed: () => _showFormDialog(existingLog: doc)),
          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20), onPressed: () => _deleteLog(doc.id)),
        ],
      ),
    );
  }
}
