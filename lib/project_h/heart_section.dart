import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeartSection extends StatefulWidget {
  const HeartSection({super.key});

  @override
  State<HeartSection> createState() => _HeartSectionState();
}

class _HeartSectionState extends State<HeartSection> {
  // డమ్మీ డేటా: Devotionals (ఆత్మీయ ఆహారం)
  final List<Map<String, String>> devotionals = [
    {
      "title": "దేవుని వాగ్దానం పై నమ్మకం",
      "date": "Today",
      "content": "యెషయా 41:10 లో దేవుడు 'భయపడకుము నేను నీకు తోడైయున్నాను' అని చెప్తున్నాడు. ఈ రోజు నీ పరిస్థితులు ఎలా ఉన్నా, ఆయన నీ చేయి పట్టుకుని నడిపిస్తాడు. నీ భారాన్ని ఆయన మీద వేసి ప్రశాంతంగా ఉండు.",
    },
    {
      "title": "ప్రార్థనలో శక్తి",
      "date": "Yesterday",
      "content": "మనం మోకరించి చేసే ప్రార్థన, పరలోకాన్ని కదిలిస్తుంది. రోజులో కనీసం 15 నిమిషాలు దేవునితో గడపడం మన ఆత్మీయ ఎదుగుదలకు ఎంతో ముఖ్యం. ఆయన స్వరాన్ని వినడానికి సమయం కేటాయించండి.",
    }
  ];

  // డమ్మీ డేటా: Apologetics (Q & A)
  final List<Map<String, String>> apologetics = [
    {
      "question": "బైబిల్ చారిత్రాత్మకంగా నిజమేనా?",
      "answer": "అవును. బైబిల్ లో చెప్పబడిన ఎన్నో స్థలాలు, వ్యక్తులను పురావస్తు శాస్త్రం (Archaeology) ధృవీకరించింది. అంతేకాకుండా జోసిఫస్ (Josephus), టాసిటస్ (Tacitus) లాంటి చరిత్రకారులు కూడా క్రీస్తు గురించి తమ గ్రంథాలలో రాశారు.",
    },
    {
      "question": "త్రిత్వం (Trinity) అనగానేమి?",
      "answer": "దేవుడు ఒక్కడే, కానీ ఆయన మూడు స్వభావాలలో (తండ్రి, కుమారుడు, పరిశుద్ధాత్మ) వ్యక్తమయ్యాడు. ఆదికాండము 1:26 లో 'మన స్వరూపమందు...' అని బహువచనం వాడబడటం దీనికి ఒక ఉదాహరణ.",
    },
    {
      "question": "దేవుడు ఉంటే లోకంలో ఇంత బాధ ఎందుకు ఉంది?",
      "answer": "దేవుడు మనుషులకు 'స్వేచ్ఛా సంకల్పం' (Free will) ఇచ్చాడు. మనుషులు చేసిన తప్పుల వల్లే పాపం, బాధ లోకంలోకి వచ్చాయి. కానీ దేవుడు ఆ బాధలో కూడా మనకు తోడుగా ఉండి, మనల్ని బలపరుస్తాడు (రోమా 8:28).",
    }
  ];

  @override
  Widget build(BuildContext context) {
    bool isLight = Theme.of(context).brightness == Brightness.light;
    Color bgColor = isLight ? Colors.white : Colors.black;
    Color textColor = isLight ? Colors.black : Colors.white;
    Color cardColor = isLight ? Colors.grey[100]! : const Color(0xFF1A1A1A);
    Color subTextColor = isLight ? Colors.black54 : Colors.white70;

    return DefaultTabController(
      length: 2, // 2 ట్యాబ్స్
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          title: Text("H E A R T", style: GoogleFonts.ubuntu(color: textColor, letterSpacing: 4, fontSize: 18, fontWeight: FontWeight.bold)),
          centerTitle: true,
          iconTheme: IconThemeData(color: textColor),
          elevation: 0,
          bottom: TabBar(
            indicatorColor: Colors.pinkAccent,
            labelColor: Colors.pinkAccent,
            unselectedLabelColor: subTextColor,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: "DEVOTIONS"),
              Tab(text: "DEFENSE (Q&A)"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ---------------------------------
            // TAB 1: DEVOTIONS (ఆత్మీయ ఆహారం)
            // ---------------------------------
            ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: devotionals.length,
              itemBuilder: (context, index) {
                var item = devotionals[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: isLight ? Colors.grey[300]! : Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.pinkAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(5)),
                            child: const Text("Daily Bread", style: TextStyle(color: Colors.pinkAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          Text(item['date']!, style: TextStyle(color: subTextColor, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(item['title']!, style: GoogleFonts.ubuntu(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text(item['content']!, style: GoogleFonts.balooTammudu2(color: subTextColor, fontSize: 15, height: 1.5)),
                      const SizedBox(height: 15),
                      Divider(color: isLight ? Colors.black12 : Colors.white24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.favorite_border, color: subTextColor, size: 20),
                          const SizedBox(width: 5),
                          Text("Amen", style: TextStyle(color: subTextColor, fontWeight: FontWeight.bold)),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),

            // ---------------------------------
            // TAB 2: DEFENSE (అపోలొజెటిక్స్ Q&A)
            // ---------------------------------
            ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: apologetics.length,
              itemBuilder: (context, index) {
                var item = apologetics[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: isLight ? Colors.grey[300]! : Colors.white12),
                  ),
                  // ExpansionTile వాడటం వల్ల ప్రశ్న క్లిక్ చేయగానే జవాబు ఓపెన్ అవుతుంది
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      iconColor: Colors.pinkAccent,
                      collapsedIconColor: subTextColor,
                      title: Text(item['question']!, style: GoogleFonts.balooTammudu2(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                          child: Text(
                            item['answer']!,
                            style: GoogleFonts.balooTammudu2(color: subTextColor, fontSize: 15, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
