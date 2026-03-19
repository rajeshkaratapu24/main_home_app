// GestureDetector లోని onTap ఫంక్షన్ ని ఇలా మార్చు:
onTap: () {
  if (bookData['content'] != null && bookData['content'].isNotEmpty) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookReaderPage(
          htmlContent: bookData['content'], // ఇక్కడ కోడ్ వెళ్తుంది
          title: bookData['title'] ?? 'Book',
        ),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("కంటెంట్ లేదు!")));
  }
},
