import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';
import 'bible_utils.dart';

class BibleReferencesHelper {
  static void showReferences({
    required BuildContext context,
    required String bookName,
    required String chapterNumber,
    required Map<String, dynamic> verseData,
    required XmlDocument document,
    required Function(String, String, String) onNavigate,
  }) {
    final int globalId = verseData['globalId'] ?? 0;
    final String verseNum = verseData['num'];
    int fileNum = ((globalId - 1) ~/ 1000) + 1;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => FutureBuilder<List<String>>(
        future: _fetchFromJSON(fileNum, globalId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
          final refs = snapshot.data ?? [];
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text("క్రాస్ రిఫరెన్సులు: $bookName $chapterNumber:$verseNum", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                const Divider(color: Colors.white12),
                Expanded(
                  child: refs.isEmpty ? const Center(child: Text("నోట్స్ లేవు బ్రో", style: TextStyle(color: Colors.white30))) : ListView.builder(
                    itemCount: refs.length,
                    itemBuilder: (context, i) {
                      List<String> parts = refs[i].split(' ');
                      String engName = BibleUtils.reverseTskCodes[parts[0]] ?? parts[0];
                      String telName = BibleUtils.teluguBooks[engName] ?? engName;
                      String display = "$telName ${parts[1]}:${parts[2]}";

                      return ListTile(
                        leading: const Icon(Icons.link, color: Colors.blueAccent),
                        title: Text(display, style: const TextStyle(color: Colors.white70)),
                        onTap: () {
                          Navigator.pop(context);
                          onNavigate(engName, parts[1], parts[2]);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static Future<List<String>> _fetchFromJSON(int fileNum, int globalId) async {
    try {
      final String res = await rootBundle.loadString('assets/references/$fileNum.json');
      final data = json.decode(res);
      if (data.containsKey(globalId.toString())) {
        final refMap = data[globalId.toString()]['r'] as Map<String, dynamic>;
        return refMap.values.map((v) => v.toString()).toList();
      }
    } catch (e) { return []; }
    return [];
  }
}
