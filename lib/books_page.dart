import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BooksPage extends StatefulWidget {
  const BooksPage({super.key});

  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  // మన యాప్ కి తగ్గ క్యాటగిరీస్
  final List<String> _categories = ["All", "Theology", "Devotional", "Bible Study", "Biographies", "History", "Kids"];
  int _selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    // థీమ్ ని బట్టి కలర్స్ మారుతాయి (Light / Dark)
    bool isLight = Theme.of(context).brightness == Brightness.light;
    Color bgColor = isLight ? Colors.white : const Color(0xFF121212); // డీప్ డార్క్ థీమ్
    Color textColor = isLight ? Colors.black : Colors.white;
    Color subTextColor = isLight ? Colors.black54 : Colors.white54;
    Color searchBoxColor = isLight ? Colors.grey[200]! : const Color(0xFF2A2A2A);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Browse",
          style: GoogleFonts.ubuntu(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------------------------
            // 1. SEARCH BAR (అచ్చం ఇమేజ్ లో లాగా)
            // ------------------------------------
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: searchBoxColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: "Search books, authors, genres...",
                  hintStyle: TextStyle(color: subTextColor, fontSize: 15),
                  prefixIcon: Icon(Icons.search, color: subTextColor),
                  suffixIcon: Icon(Icons.mic, color: subTextColor),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ------------------------------------
            // 2. CATEGORIES (Horizontal Scroll)
            // ------------------------------------
            SizedBox(
              height: 30,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  bool isSelected = index == _selectedCategoryIndex;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategoryIndex = index;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: Text(
                        _categories[index],
                        style: GoogleFonts.ubuntu(
                          color: isSelected ? textColor : subTextColor,
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 25),

            // ------------------------------------
            // 3. BOOKS GRID VIEW
            // ------------------------------------
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, 
                crossAxisSpacing: 15, 
                mainAxisSpacing: 20, 
                childAspectRatio: 0.52 // ఇమేజ్ పెద్దగా, కింద టెక్స్ట్ కి స్పేస్
              ),
              itemCount: _bookData.length,
              itemBuilder: (context, index) {
                var book = _bookData[index];
                return _buildBookCard(book, textColor, subTextColor);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // బుక్ కార్డ్ డిజైన్
  Widget _buildBookCard(Map<String, dynamic> book, Color textColor, Color subTextColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. బుక్ కవర్
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                )
              ]
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                book['cover'],
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[800],
                  child: const Icon(Icons.book, color: Colors.white54, size: 40),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        
        // 2. బుక్ టైటిల్
        Text(
          book['title'],
          style: GoogleFonts.ubuntu(color: textColor, fontSize: 14, fontWeight: FontWeight.bold, height: 1.2),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),
        
        // 3. రచయిత & రేటింగ్ (Stars)
        Row(
          children: [
            Expanded(
              child: Text(
                book['author'],
                style: TextStyle(color: subTextColor, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (book['rating'] > 0) ...[
              const Icon(Icons.star, color: Colors.amber, size: 12),
              const Icon(Icons.star, color: Colors.amber, size: 12),
              const Icon(Icons.star, color: Colors.amber, size: 12),
            ]
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------
  // DUMMY DATA (మన యాప్ కి తగ్గట్టుగా డమ్మీ డేటా)
  // ---------------------------------------------------------
  static const List<Map<String, dynamic>> _bookData = [
    {
      'title': 'The Great Devotion',
      'author': 'Raja Talluri',
      'cover': 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?q=80&w=300',
      'rating': 4
    },
    {
      'title': 'Knowing God',
      'author': 'J.I. Packer',
      'cover': 'https://images.unsplash.com/photo-1512820790803-83ca734da794?q=80&w=300',
      'rating': 0 // రేటింగ్ లేకపోతే స్టార్స్ రావు
    },
    {
      'title': 'Spiritual Leadership',
      'author': 'J. Oswald',
      'cover': 'https://images.unsplash.com/photo-1589998059171-988d887df646?q=80&w=300',
      'rating': 5
    },
    {
      'title': 'Mere Christianity',
      'author': 'C.S. Lewis',
      'cover': 'https://images.unsplash.com/photo-1495446815901-a7297e633e8d?q=80&w=300',
      'rating': 4
    },
    {
      'title': 'The Pursuit of God',
      'author': 'A.W. Tozer',
      'cover': 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?q=80&w=300',
      'rating': 0
    },
    {
      'title': 'Grace Abounding',
      'author': 'John Bunyan',
      'cover': 'https://images.unsplash.com/photo-1521587760476-6c12a4b040da?q=80&w=300',
      'rating': 5
    },
  ];
}
