import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BooksPage extends StatelessWidget {
  const BooksPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ఇమేజ్ లో ఉన్న సాఫ్ట్ గ్రే బ్యాక్‌గ్రౌండ్ కలర్
    const Color bgColor = Color(0xFFEDF0F3);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // ------------------------------------
              // 1. NEUMORPHIC HEADER (SEARCH & MENU)
              // ------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // సర్చ్ బార్ (ఇమేజ్ లో 'Backs' అని ఉంది, బహుశా AI typo)
                  Expanded(
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(30),
                        // Neumorphic షాడోస్
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.08), offset: const Offset(4, 4), blurRadius: 10),
                          const BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 10),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Text(
                            "Backs", // EXACT TEXT from image
                            style: GoogleFonts.ubuntu(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          Icon(Icons.search, color: Colors.black.withOpacity(0.5), size: 24),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  // మెనూ బటన్ (రౌండ్ Neumorphic)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.08), offset: const Offset(4, 4), blurRadius: 10),
                        const BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 10),
                      ],
                    ),
                    child: const Icon(Icons.menu, color: Colors.black, size: 28),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),

              // ------------------------------------
              // 2. BOOKS GRID VIEW
              // ------------------------------------
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, 
                  crossAxisSpacing: 15, 
                  mainAxisSpacing: 15, 
                  childAspectRatio: 0.65 // కార్డ్స్ పొడవుగా ఉండటానికి
                ),
                itemCount: _bookData.length,
                itemBuilder: (context, index) {
                  return _buildBookCard(context, _bookData[index], bgColor);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ఒక్క బుక్ కార్డ్ డిజైన్ చేసే ఫంక్షన్
  Widget _buildBookCard(BuildContext context, Map<String, dynamic> book, Color bgColor) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), offset: const Offset(4, 4), blurRadius: 10),
          const BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 10),
        ],
      ),
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // బుక్ కవర్ (ఇమేజ్ లో ఉన్నట్లు క్లీన్ గా)
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                book['cover'],
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300], child: const Icon(Icons.book, color: Colors.grey, size: 30)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // బుక్ పేరు
          Text(
            book['title'],
            style: GoogleFonts.ubuntu(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          // రచయిత పేరు (కొన్ని బుక్స్ కి లేదు)
          if (book['author'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                book['author'],
                style: GoogleFonts.ubuntu(color: Colors.black.withOpacity(0.5), fontSize: 10),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const Spacer(),
          // ఇమేజ్ లో ఉన్నట్లు డిఫరెంట్ ఐకాన్స్ (Stars, Heart etc.)
          _buildIconRow(book),
        ],
      ),
    );
  }

  // ప్రతి బుక్ కి డిఫరెంట్ ఐకాన్స్ పెట్టే లాజిక్ (EXACT replica కోసం)
  Widget _buildIconRow(Map<String, dynamic> book) {
    if (book['type'] == 'home_progress') {
      return Column(
        children: [
          LinearProgressIndicator(value: 0.5, color: Colors.blueAccent, backgroundColor: Colors.black12, minHeight: 2),
          const SizedBox(height: 5),
          const Icon(Icons.home_outlined, color: Colors.black, size: 16),
        ],
      );
    } else if (book['type'] == 'book_progress') {
      return Column(
        children: [
          LinearProgressIndicator(value: 0.7, color: Colors.blueAccent, backgroundColor: Colors.black12, minHeight: 2),
          const SizedBox(height: 5),
          const Icon(Icons.bookmark_outline_rounded, color: Colors.black, size: 16),
        ],
      );
    } else if (book['type'] == 'just_home') {
      return const Icon(Icons.home_outlined, color: Colors.black, size: 16);
    } else if (book['type'] == 'stars') {
      return Row(children: List.generate(4, (index) => const Icon(Icons.star, color: Colors.orangeAccent, size: 12)));
    } else if (book['type'] == 'stars_home') {
      return Row(children: List.generate(4, (index) => const Icon(Icons.star, color: Colors.orangeAccent, size: 12)));
    } else if (book['type'] == 'arrow_up') {
      return const Center(child: Icon(Icons.arrow_drop_up_rounded, color: Colors.black, size: 24));
    } else if (book['type'] == 'heart') {
      return const Center(child: Icon(Icons.favorite_border, color: Colors.black, size: 16));
    } else {
      return const SizedBox(height: 16); // Default empty space
    }
  }

  // ---------------------------------------------------------
  // DUMMY DATA: ఇమేజ్ లో ఉన్న వివరాలతో EXACT గా క్రియేట్ చేశాను
  // ---------------------------------------------------------
  static const List<Map<String, dynamic>> _bookData = [
    {
      'title': 'Greet Gatsby', // Exact typo from image
      'author': 'F. Scott Fitzgerald',
      'cover': 'https://upload.wikimedia.org/wikipedia/commons/7/7a/The_Great_Gatsby_Cover_1925_Retouched.jpg',
      'type': 'none'
    },
    {
      'title': 'The Sartires', // Exact typo from image
      'author': 'Merle Fitzgerald',
      'cover': 'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?q=80&w=300', // Dummy cover resembling image
      'type': 'none'
    },
    {
      'title': 'Cypley', // Exact typo from image
      'author': null,
      'cover': 'https://images.unsplash.com/photo-1532012197267-da84d127e765?q=80&w=300',
      'type': 'home_progress' // Image style logic
    },
    {
      'title': 'To Kill a Mockingbird',
      'author': 'Harpy Lee', // Exact typo from image
      'cover': 'https://upload.wikimedia.org/wikipedia/commons/4/4f/To_Kill_a_Mockingbird_%28first_edition_cover%29.jpg',
      'type': 'book_progress'
    },
    {
      'title': 'Greet Gatsby', // Repeat from image
      'author': 'Eattyera',
      'cover': 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?q=80&w=300',
      'type': 'none'
    },
    {
      'title': 'Syinp Hark', // Exact typo from image
      'author': 'Ouges',
      'cover': 'https://images.unsplash.com/photo-1512820790803-83ca734da794?q=80&w=300',
      'type': 'just_home'
    },
    {
      'title': 'Beit Orovel', // Exact typo from image
      'author': 'Regga',
      'cover': 'https://images.unsplash.com/photo-1589998059171-988d887df646?q=80&w=300',
      'type': 'just_home'
    },
    {
      'title': 'Harpy Lee', // Title logic from image
      'author': null,
      'cover': 'https://images.unsplash.com/photo-1495446815901-a7297e633e8d?q=80&w=300',
      'type': 'stars'
    },
    {
      'title': 'Ceekafilist', // Exact typo from image
      'author': 'Cortsh',
      'cover': 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?q=80&w=300',
      'type': 'heart'
    },
    {
      'title': 'Punering', // Exact typo from image
      'author': 'Soricty',
      'cover': 'https://images.unsplash.com/photo-1521587760476-6c12a4b040da?q=80&w=300',
      'type': 'stars_home'
    },
    {
      'title': 'Margstard', // Exact typo from image
      'author': 'Vhiten',
      'cover': 'https://images.unsplash.com/photo-1516979187457-637abb4f9353?q=80&w=300',
      'type': 'arrow_up'
    },
    {
      'title': 'Rartenupe', // Exact typo from image
      'author': 'Sanize',
      'cover': 'https://images.unsplash.com/photo-1510172951991-859a697113c1?q=80&w=300',
      'type': 'heart'
    },
  ];
}
