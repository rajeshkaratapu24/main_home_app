import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HandsDashboard extends StatefulWidget {
  const HandsDashboard({super.key});

  @override
  State<HandsDashboard> createState() => _HandsDashboardState();
}

class _HandsDashboardState extends State<HandsDashboard> {
  String selectedFilter = "Daily";
  final List<String> filters = ["Daily", "Weekly", "Monthly", "Yearly"];

  // డమ్మీ డేటా
  Map<String, Map<String, int>> trackingData = {
    "Daily": {"WhatsApp": 12, "Instagram": 5, "Facebook": 3, "Total": 20},
    "Weekly": {"WhatsApp": 85, "Instagram": 40, "Facebook": 25, "Total": 150},
    "Monthly": {"WhatsApp": 320, "Instagram": 150, "Facebook": 90, "Total": 560},
    "Yearly": {"WhatsApp": 1200, "Instagram": 600, "Facebook": 450, "Total": 2250},
  };

  // రీసెంట్ గా ఎంటర్ చేసిన డేటా స్టోర్ చేసుకోవడానికి లిస్ట్ (Edit/Delete కోసం)
  List<Map<String, dynamic>> recentLogs = [];

  final TextEditingController waController = TextEditingController();
  final TextEditingController instaController = TextEditingController();
  final TextEditingController fbController = TextEditingController();

  // కొత్తది యాడ్ చేయడానికి ఫామ్
  void _showAddEntryDialog() {
    waController.clear();
    instaController.clear();
    fbController.clear();
    _showFormDialog(isEdit: false);
  }

  // ఎడిట్ చేయడానికి ఫామ్ (పాత వాల్యూస్ తో ఓపెన్ అవుతుంది)
  void _showEditDialog(Map<String, dynamic> log) {
    waController.text = log['wa'].toString();
    instaController.text = log['insta'].toString();
    fbController.text = log['fb'].toString();
    _showFormDialog(isEdit: true, existingLog: log);
  }

  // మెయిన్ ఫామ్ (Add & Edit కి కామన్ గా పనిచేస్తుంది)
  void _showFormDialog({required bool isEdit, Map<String, dynamic>? existingLog}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(isEdit ? "Edit Log" : "Log Today's Work", style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isEdit ? "నెంబర్స్ సరిచేసి సేవ్ చేయండి:" : "ఎంత మందికి వాక్యం షేర్ చేశావో ఇక్కడ ఎంటర్ చెయ్:", style: const TextStyle(color: Colors.white70, fontSize: 13)),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              int newWa = int.tryParse(waController.text) ?? 0;
              int newInsta = int.tryParse(instaController.text) ?? 0;
              int newFb = int.tryParse(fbController.text) ?? 0;
              int newTotal = newWa + newInsta + newFb;

              if (newTotal > 0 || isEdit) {
                setState(() {
                  if (isEdit && existingLog != null) {
                    // పాత నంబర్స్ కి, కొత్త నంబర్స్ కి తేడా (Difference) కనుక్కుంటున్నాం
                    int waDiff = newWa - (existingLog['wa'] as int);
                    int instaDiff = newInsta - (existingLog['insta'] as int);
                    int fbDiff = newFb - (existingLog['fb'] as int);
                    int totalDiff = waDiff + instaDiff + fbDiff;

                    // ఆ తేడాని టోటల్స్ కి అప్లై చేస్తున్నాం
                    _updateTotals(waDiff, instaDiff, fbDiff, totalDiff);

                    // రీసెంట్ లాగ్ లో అప్‌డేట్ చేస్తున్నాం
                    existingLog['wa'] = newWa;
                    existingLog['insta'] = newInsta;
                    existingLog['fb'] = newFb;
                    existingLog['total'] = newTotal;
                    
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Log Updated Successfully! ✏️"), backgroundColor: Colors.blue));
                  } else {
                    // కొత్తది అయితే డైరెక్ట్ గా యాడ్ చేస్తున్నాం
                    _updateTotals(newWa, newInsta, newFb, newTotal);
                    
                    recentLogs.insert(0, {
                      'id': DateTime.now().toString(),
                      'time': "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}",
                      'wa': newWa,
                      'insta': newInsta,
                      'fb': newFb,
                      'total': newTotal,
                    });

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("+$newTotal People Reached Today! Praise God 🙌"), backgroundColor: Colors.green));
                  }
                });
                Navigator.pop(context);
              } else {
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
  void _deleteLog(Map<String, dynamic> log) {
    setState(() {
      // టోటల్స్ లో నుండి ఈ నంబర్స్ ని తీసేస్తున్నాం (Minus)
      _updateTotals(-log['wa'], -log['insta'], -log['fb'], -log['total']);
      // లిస్ట్ లోంచి డిలీట్ చేస్తున్నాం
      recentLogs.removeWhere((item) => item['id'] == log['id']);
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Log Deleted 🗑️"), backgroundColor: Colors.red));
  }

  // గ్రాఫ్స్ కి డేటా అప్‌డేట్ చేసే హెల్పర్ ఫంక్షన్
  void _updateTotals(int wa, int insta, int fb, int total) {
    trackingData["Daily"]!["WhatsApp"] = trackingData["Daily"]!["WhatsApp"]! + wa;
    trackingData["Daily"]!["Instagram"] = trackingData["Daily"]!["Instagram"]! + insta;
    trackingData["Daily"]!["Facebook"] = trackingData["Daily"]!["Facebook"]! + fb;
    trackingData["Daily"]!["Total"] = trackingData["Daily"]!["Total"]! + total;
    
    trackingData["Weekly"]!["Total"] = trackingData["Weekly"]!["Total"]! + total;
    trackingData["Monthly"]!["Total"] = trackingData["Monthly"]!["Total"]! + total;
    trackingData["Yearly"]!["Total"] = trackingData["Yearly"]!["Total"]! + total;
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
    var currentData = trackingData[selectedFilter]!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("H A N D S", style: GoogleFonts.ubuntu(color: Colors.white, letterSpacing: 4, fontSize: 18)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text("Your Impact Dashboard", style: GoogleFonts.balooTammudu2(color: Colors.white54, fontSize: 16)),
            const SizedBox(height: 15),
            
            // Daily / Weekly / Monthly బటన్స్
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
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A2980), Color(0xFF26D0CE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text("People Reached", style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 10),
                  Text(
                    "${currentData['Total']}",
                    style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 50, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text("in $selectedFilter timeframe", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // కింద ఉన్న లిస్ట్ (ప్లాట్‌ఫామ్స్ + ఎడిట్ లాగ్స్)
            Expanded(
              child: ListView(
                children: [
                  Text("Platform Breakdown", style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _buildPlatformRow("WhatsApp", currentData['WhatsApp']!, Colors.greenAccent, Icons.chat),
                  _buildPlatformRow("Instagram", currentData['Instagram']!, Colors.pinkAccent, Icons.camera_alt),
                  _buildPlatformRow("Facebook", currentData['Facebook']!, Colors.blueAccent, Icons.facebook),
                  
                  // మనం యాడ్ చేసిన హిస్టరీ లాగ్స్ ఇక్కడ వస్తాయి
                  if (recentLogs.isNotEmpty) ...[
                    const SizedBox(height: 25),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 10),
                    Text("Recent Logs", style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    ...recentLogs.map((log) => _buildLogItem(log)),
                    const SizedBox(height: 80), // కింద బటన్ కి తగలకుండా స్పేస్
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEntryDialog,
        backgroundColor: Colors.white,
        icon: const Icon(Icons.add, color: Colors.black),
        label: Text("ADD LOG", style: GoogleFonts.ubuntu(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ఫిల్టర్ బటన్స్ డిజైన్
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
        child: Text(
          label,
          style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
        ),
      ),
    );
  }

  // ప్లాట్‌ఫామ్ రో డిజైన్
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

  // ఎడిట్/డిలీట్ చేసుకునే లాగ్ కార్డ్ డిజైన్
  Widget _buildLogItem(Map<String, dynamic> log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(15),
      ),
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
                Text("Total Reached: ${log['total']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 3),
                Text("WA: ${log['wa']} | Insta: ${log['insta']} | FB: ${log['fb']}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          // Edit Button
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent, size: 20),
            onPressed: () => _showEditDialog(log),
          ),
          // Delete Button
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
            onPressed: () => _deleteLog(log),
          ),
        ],
      ),
    );
  }
}
