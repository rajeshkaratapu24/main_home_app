import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'book_reader_page.dart'; // Direct import, folder ledu kabatti

class BooksPage extends StatefulWidget {
  const BooksPage({super.key});

  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  @override
  Widget build(BuildContext context) {
    bool isLight = Theme.of(context).brightness == Brightness.light;
    Color bgColor = isLight ? Colors.white : const Color(0xFF121212);
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
        title: Text("Browse", style: GoogleFonts.ubuntu(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Container(
              height: 50,
              decoration: BoxDecoration(color: searchBoxColor, borderRadius: BorderRadius.circular(10)),
              child: TextField(
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: "Search books...",
                  hintStyle: TextStyle(color: subTextColor),
                  prefixIcon: Icon(Icons.search, color: subTextColor),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('books').orderBy('timestamp', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.purpleAccent));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("Books available lo levu", style: TextStyle(color: subTextColor)));
                  }

                  var books = snapshot.data!.docs;

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, 
                      crossAxisSpacing: 15, 
                      mainAxisSpacing: 20, 
                      childAspectRatio: 0.52
                    ),
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      var bookData = books[index].data() as Map<String, dynamic>;
                      
                      return GestureDetector(
                        onTap: () {
                          if (bookData['bookUrl'] != null && bookData['bookUrl'].isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookReaderPage(
                                  url: bookData['bookUrl'], 
                                  title: bookData['title'] ?? 'Book',
                                ),
                              ),
                            );
                          }
                        },
                        child: _buildBookCard(
                          title: bookData['title'] ?? 'No Title',
                          author: bookData['author'] ?? 'Unknown',
                          cover: bookData['coverUrl'] ?? '',
                          rating: bookData['rating'] ?? 5,
                          textColor: textColor,
                          subTextColor: subTextColor,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookCard({required String title, required String author, required String cover, required int rating, required Color textColor, required Color subTextColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5, offset: const Offset(0, 3))]
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                cover,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[800], 
                  child: const Icon(Icons.book, color: Colors.white54)
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(title, style: GoogleFonts.ubuntu(color: textColor, fontSize: 13, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 2),
        Row(
          children: [
            Expanded(child: Text(author, style: TextStyle(color: subTextColor, fontSize: 11), maxLines: 1)),
            Icon(Icons.star, color: Colors.amber, size: 10),
            Text(rating.toString(), style: TextStyle(color: subTextColor, fontSize: 10)),
          ],
        ),
      ],
    );
  }
}
