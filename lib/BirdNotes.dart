import 'package:app/LinkTest.dart';
import 'package:app/webView.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class NoteItem {
  String key;
  String value;

  NoteItem({required this.key, required this.value});

  // Convert a NoteItem into a Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'value': value,
    };
  }

  // Create a NoteItem from a Map (from Firebase)
  factory NoteItem.fromMap(Map<String, dynamic> map) {
    return NoteItem(
      key: map['key'],
      value: map['value'],
    );
  }
}

class BirdNotes extends StatefulWidget {
  @override
  _BirdNotesState createState() => _BirdNotesState();
}

class _BirdNotesState extends State<BirdNotes> {
  String notes = '''
/heading: Animals: Birds
/teacher: Good morning, everyone! Today, we are going to embark on a fascinating journey into the world of birds!
/instruction: Pause for a moment to capture students' attention.

/heading: Introduction: [5 Minutes]
/teacher: Birds are all around us, filling the air with their beautiful songs and captivating us with their ability to soar through the sky. But have you ever stopped to wonder what makes these feathered creatures so unique?

/heading: Engage with Students: [5 Minutes]
/teacher: Can anyone tell me what they already know about birds? What are some different types of birds you've seen before?
/instruction: Encourage students to share their prior knowledge and observations, acknowledging their responses.

/teacher: That's fantastic! You already know so much! Now, let's delve deeper into the world of birds. Imagine you're an explorer venturing into a lush forest. What are some of the first things you notice about the birds you encounter?

/heading: Main Body: [20 Minutes]
/teacher: Today, we will be focusing on three key features of birds: their beaks, their feet and claws, and their fascinating feathers.

/heading: Bird Beaks: A Guide to Eating Habits
/teacher: Just like we use our mouths and teeth to eat, birds rely on their beaks. However, unlike us, birds don't have teeth! Their beaks have evolved in remarkable ways to suit their diet.

/teacher: To see just how different bird beaks can be, let's take a look at this image.
/instruction: Show image: [Bird Beaks Image](https://www.allaboutbirds.org/news/wp-content/uploads/2020/09/BirdBills.jpg)

/teacher: What differences do you see in these beaks? How do you think the shape of their beak helps them eat different types of food?

/teacher: Now, let's see these beaks in action!
/instruction: Play video: [Bird Beaks Video](https://www.youtube.com/watch?v=xEbRZs1L59E)

/heading: Bird Feet and Claws: Adapting to Different Lifestyles
/teacher: Just as our legs help us walk, birds rely on their feet and claws for various activities.
/instruction: Show image: [Bird Feet Image](https://www.sciencebuddies.org/cdn/Files/3491/5/Zoo_img037.jpg)

/teacher: Look closely at these bird feet. What differences do you notice? Can anyone guess what these birds might use their feet for?

/heading: Feathers: A Bird’s Protective Covering
/teacher: What do we wear to keep ourselves warm? That’s right, clothes! But birds have a different way of staying cozy – feathers!
/instruction: Show pictures of different types of feathers.

/teacher: There are three main types of feathers: body feathers, flight feathers, and down feathers. Can you guess what each type of feather does?

/heading: Class Work: [5 Minutes]
/teacher: Now, let's see how well you've grasped today’s lesson. Please take out a sheet of paper and answer these questions.
/instruction: Write the following questions on the board.

1. Why do you think a woodpecker's beak is different from a hummingbird's beak?
2. What type of feet would be best for a bird that swims in water?
3. Why are a bird's feathers so important?

/instruction: Allow students a few minutes to answer the questions, then review the answers together as a class.

/heading: Homework: [0 Minutes]
/teacher: For today, there is no homework!

/heading: Conclusion: [0 Minutes]
/teacher: Today, we’ve explored the fascinating world of birds, focusing on their unique beaks, feet, and feathers. Remember, observing the natural world around us helps us understand and appreciate its wonders. See you all tomorrow!
''';

  List<NoteItem> noteItems = [];
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final gemini = Gemini.instance;
  OverlayEntry? _overlayEntry;
  int? selectedStart;
  int? selectedEnd;
  int? selectedIndex;
  TextEditingController _textController = TextEditingController();
  TextEditingController newentry = new TextEditingController();
  String? imageUrl; // Store the selected image URL for preview
  bool _isOverlayShown = false;

  final List<TapGestureRecognizer> _gestureRecognizers = [];
  List<GlobalKey> textKeys = [];

  @override
  void initState() {
    super.initState();
    _parseNotes();
    _initializeNotesInDatabase();
  }

  @override
  void dispose() {
    // Dispose all gesture recognizers
    _overlayEntry?.dispose();

    for (final recognizer in _gestureRecognizers) {
      recognizer.dispose();
    }
    _removeOverlay();
    super.dispose();
  }

  // Parse the notes into NoteItem list
  void _parseNotes() {
    List<String> lines = notes.split('\n');
    noteItems.clear();

    RegExp keyValueRegExp = RegExp(r'^(/[^:]+):\s*(.*)$');

    for (String line in lines) {
      if (line.trim().isEmpty) continue; // Skip empty lines

      Match? match = keyValueRegExp.firstMatch(line);
      if (match != null) {
        String key = match.group(1)!;
        String value = match.group(2)!;
        noteItems.add(NoteItem(key: key, value: value));
      } else {
        // Handle lines that don't start with a key
        noteItems.add(NoteItem(key: '/text', value: line));
      }
    }
  }

  // Initialize notes in Firebase
  void _initializeNotesInDatabase() async {
    try {
      await _databaseRef.child('notes').set(
            noteItems.map((noteItem) => noteItem.toMap()).toList(),
          );
      await _loadNotesFromDatabase();
    } catch (error) {
      print("Failed to initialize notes in the database: $error");
    }
  }

  // Load notes from Firebase
  Future<void> _loadNotesFromDatabase() async {
    try {
      final snapshot = await _databaseRef.child('notes').get();
      if (snapshot.value != null) {
        List<dynamic> data = snapshot.value as List<dynamic>;
        setState(() {
          noteItems = data
              .map((item) => NoteItem.fromMap(Map<String, dynamic>.from(item)))
              .toList();
        });
      } else {
        print("No data found for 'notes'");
      }
    } catch (error) {
      print("Failed to read from database: $error");
    }
  }

  Future<String> fetchGeminiText(String textType) async {
    try {
      String originalText = noteItems[selectedIndex!].value;
      originalText = originalText.substring(selectedStart!, selectedEnd!);
      String prompt =
          'This is the original content: $originalText, Please change '
          'the above information according to the following instruction: '
          '$textType';
      final value = await gemini.text(prompt);
      return value?.output ?? "No output generated.";
    } catch (e) {
      return "Error generating text: $e";
    }
  }

  Future<String?> _showTextTypeDialog(BuildContext context) async {
    String? textType;
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Specify the Text Type'),
          content: TextField(
            decoration: InputDecoration(
              hintText: 'Enter text type, e.g., "Formal" or "Summary"',
            ),
            onChanged: (value) {
              textType = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(textType);
              },
            ),
          ],
        );
      },
    );
  }

  final RegExp markdownLinkRegEx = RegExp(
    r'\[([^\]]+)\]\((https?://[^\s\)]+)\)',
    caseSensitive: false,
  );

  // Update notes in Firebase
  void _updateNotesInDatabase() {
    _databaseRef
        .child('notes')
        .set(
          noteItems.map((noteItem) => noteItem.toMap()).toList(),
        )
        .then((_) {
      print("Data successfully written to database");
    }).catchError((error) {
      print("Failed to write data to database: $error");
    });
  }

  bool isEditMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Birds Notes'),
      ),
      body: Row(
        children: [
          // Text section (left 60%)
          Expanded(
            flex: 6,
            child: ListView.builder(
              itemCount: noteItems.length,
              itemBuilder: (context, index) {
                NoteItem item = noteItems[index];
                TextStyle textStyle;

                if (item.key == '/heading') {
                  textStyle = const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: Color.fromARGB(255, 55, 53, 47),
                  );
                } else if (item.key == '/teacher') {
                  textStyle = const TextStyle(
                      fontSize: 16, color: Color.fromARGB(255, 68, 42, 42));
                } else if (item.key == '/instruction') {
                  textStyle = const TextStyle(fontSize: 14);
                } else {
                  textStyle = const TextStyle(fontSize: 14);
                }

                return ListTile(
                  title: _buildSelectableText(
                    item.value,
                    index,
                    textStyle,
                  ),
                  onTap: null,
                );
              },
            ),
          ),

          // Link preview section (right 40%)
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.all(10),
              color: Colors.white,
              child: imageUrl != null
                  ? LinkPreviewPage(url: imageUrl!)
                  : const Center(
                      child: Text(
                        'Click on a link to display the preview',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _buildSelectableTextSpanParts(
    String partText,
    int index,
    int partStartIndex,
    TextStyle textStyle, {
    GestureRecognizer? recognizer,
  }) {
    List<TextSpan> spans = [];
    int partLength = partText.length;

    int? selectionStart = (selectedIndex == index) ? selectedStart : null;
    int? selectionEnd = (selectedIndex == index) ? selectedEnd : null;

    int currentIndex = 0;

    while (currentIndex < partLength) {
      int globalIndex = partStartIndex + currentIndex;

      TextStyle spanStyle = textStyle;

      if (selectionStart != null &&
          selectionEnd != null &&
          globalIndex >= selectionStart &&
          globalIndex < selectionEnd) {
        // This character is within the selection
        spanStyle = spanStyle.copyWith(backgroundColor: Colors.blue[100]);
      }

      spans.add(TextSpan(
        text: partText[currentIndex],
        style: spanStyle,
        recognizer: recognizer,
      ));

      currentIndex++;
    }

    return spans;
  }

  void _launchLinkTest(String url) {
    // When a link is clicked, show the LinkPreviewPage on the right 40%
    setState(() {
      imageUrl = url; // URL to be previewed
    });
  }

  List<TextSpan> _buildInstructionTextWithLinks(
      String text, TextStyle textStyle) {
    List<TextSpan> spans = [];

    text.splitMapJoin(
      markdownLinkRegEx,
      onMatch: (Match match) {
        String linkText = match.group(1) ?? '';
        String linkUrl = match.group(2) ?? '';

        // Create and store the recognizer
        TapGestureRecognizer recognizer = TapGestureRecognizer()
          ..onTap = () {
            _launchLinkTest(linkUrl);
          };
        _gestureRecognizers.add(recognizer);

        // Add the link text as tappable text
        spans.add(
          TextSpan(
            text: linkText,
            style: textStyle.copyWith(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
            recognizer: recognizer,
          ),
        );
        return ''; // We've manually added the matched link
      },
      onNonMatch: (String nonMatch) {
        // Add non-link text with the default style
        spans.add(
          TextSpan(
            text: nonMatch,
            style: textStyle,
          ),
        );
        return '';
      },
    );

    return spans;
  }

  Widget _buildSelectableText(String text, int index, TextStyle textStyle) {
    return SelectableText.rich(
      TextSpan(children: _buildTextSpans(text, index, textStyle)),
      onSelectionChanged: (selection, cause) {
        setState(() {
          selectedStart = selection.start;
          selectedEnd = selection.end;
          selectedIndex = index;
        });
        if (selectedStart != null && selectedEnd != null) {
          String selectedText = text.substring(selectedStart!, selectedEnd!);
          int wordCount = _countWords(selectedText);
          if (wordCount >= 5) {
            _showOverlay(context, selectedText);
          } else {
            _removeOverlay();
          }
        }
      },
    );
  }

  List<TextSpan> _buildTextSpans(String text, int index, TextStyle textStyle) {
    List<TextSpan> spans = [];
    int textLength = text.length;

    // Regular expression to detect Markdown-style links
    final RegExp markdownLinkRegEx = RegExp(
      r'\[([^\]]+)\]\((https?://[^\s\)]+)\)',
      caseSensitive: false,
    );

    int currentIndex = 0;

    text.splitMapJoin(
      markdownLinkRegEx,
      onMatch: (Match match) {
        String linkText = match.group(1) ?? '';
        String linkUrl = match.group(2) ?? '';
        int start = match.start;
        int end = match.end;

        // Add text before the link
        if (start > currentIndex) {
          String beforeLinkText = text.substring(currentIndex, start);
          spans.addAll(_buildSelectableTextSpanParts(
            beforeLinkText,
            index,
            currentIndex,
            textStyle,
          ));
        }

        // Create and store the recognizer
        TapGestureRecognizer recognizer = TapGestureRecognizer()
          ..onTap = () {
            _launchLinkTest(linkUrl);
          };
        _gestureRecognizers.add(recognizer);

        // Add the link text as tappable text
        spans.addAll(_buildSelectableTextSpanParts(
          linkText,
          index,
          start,
          textStyle.copyWith(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
          recognizer: recognizer,
        ));

        currentIndex = end;
        return ''; // We've manually added the matched link
      },
      onNonMatch: (String nonMatch) {
        if (nonMatch.isNotEmpty) {
          spans.addAll(_buildSelectableTextSpanParts(
            nonMatch,
            index,
            currentIndex,
            textStyle,
          ));
          currentIndex += nonMatch.length;
        }
        return '';
      },
    );

    return spans;
  }

  bool selectoccur = false;

  int _countWords(String text) {
    return text.trim().split(RegExp(r'\s+')).length;
  }

  String containertext = "";

  Future<void> _func() async {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    String? textType = "Make longer";
    if (textType != null) {
      try {
        String newText = await fetchGeminiText(textType);
        String processedText = newText.replaceAll('**', '').replaceAll('*', '');
        containertext = processedText;
        _replaceSelectedText(processedText);
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  void _showOverlay(BuildContext context, String selectedText) {
    _textController.text = selectedText;
    if (_isOverlayShown) return;
    _removeOverlay();

    _overlayEntry = OverlayEntry(builder: (context) {
      double screenWidth = MediaQuery.of(context).size.width;
      double overlayWidth = screenWidth * 1; // 95% of screen width
      double overlayHeight = 87; // Adjusted height to accommodate content

      return Positioned(
        bottom: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              // borderRadius: BorderRadius.circular(24.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(2),
            width: overlayWidth,
            height: overlayHeight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Row containing four text prompts
                selectoccur
                    ? SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // First Text Prompt
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: TextButton(
                                onPressed: () async {
                                  if (_overlayEntry != null) {
                                    _overlayEntry!.remove();
                                    _overlayEntry = null;
                                  }
                                  String? textType = "Make funny";
                                  if (textType != null) {
                                    try {
                                      String newText =
                                          await fetchGeminiText(textType);
                                      String processedText = newText
                                          .replaceAll('**', '')
                                          .replaceAll('*', '');
                                      _replaceSelectedText(processedText);
                                    } catch (e) {
                                      print('Error: $e');
                                    }
                                  }
                                },
                                child: Text(
                                  "Make funny",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 12),
                                ),
                              ),
                            ),

                            SizedBox(width: 4), // Space between prompts

                            // Second Text Prompt
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: TextButton(
                                onPressed: () async {
                                  if (_overlayEntry != null) {
                                    _overlayEntry!.remove();
                                    _overlayEntry = null;
                                  }
                                  String? textType = "Make concise";
                                  if (textType != null) {
                                    try {
                                      String newText =
                                          await fetchGeminiText(textType);
                                      String processedText = newText
                                          .replaceAll('**', '')
                                          .replaceAll('*', '');
                                      _replaceSelectedText(processedText);
                                    } catch (e) {
                                      print('Error: $e');
                                    }
                                  }
                                },
                                child: Text(
                                  "Make concise",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 12),
                                ),
                              ),
                            ),

                            const SizedBox(width: 4),

                            // Third Text Prompt
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: TextButton(
                                onPressed: () async {
                                  if (_overlayEntry != null) {
                                    _overlayEntry!.remove();
                                    _overlayEntry = null;
                                  }
                                  String? textType = "Make shorter";
                                  if (textType != null) {
                                    try {
                                      String newText =
                                          await fetchGeminiText(textType);
                                      String processedText = newText
                                          .replaceAll('**', '')
                                          .replaceAll('*', '');
                                      _replaceSelectedText(processedText);
                                    } catch (e) {
                                      print('Error: $e');
                                    }
                                  }
                                },
                                child: Text(
                                  "Make shorter",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 12),
                                ),
                              ),
                            ),

                            const SizedBox(width: 4),

                            // Third Text Prompt
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: TextButton(
                                onPressed: () async {
                                  if (_overlayEntry != null) {
                                    _overlayEntry!.remove();
                                    _overlayEntry = null;
                                  }
                                  String? textType = "Make shorter";
                                  if (textType != null) {
                                    try {
                                      String newText =
                                          await fetchGeminiText(textType);
                                      String processedText = newText
                                          .replaceAll('**', '')
                                          .replaceAll('*', '');
                                      _replaceSelectedText(processedText);
                                    } catch (e) {
                                      print('Error: $e');
                                    }
                                  }
                                },
                                child: Text(
                                  "Make shorter",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 12),
                                ),
                              ),
                            ),

                            const SizedBox(width: 4),

                            // Third Text Prompt
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: TextButton(
                                onPressed: () async {
                                  if (_overlayEntry != null) {
                                    _overlayEntry!.remove();
                                    _overlayEntry = null;
                                  }
                                  String? textType = "Make shorter";
                                  if (textType != null) {
                                    try {
                                      String newText =
                                          await fetchGeminiText(textType);
                                      String processedText = newText
                                          .replaceAll('**', '')
                                          .replaceAll('*', '');
                                      _replaceSelectedText(processedText);
                                    } catch (e) {
                                      print('Error: $e');
                                    }
                                  }
                                },
                                child: Text(
                                  "Make shorter",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 12),
                                ),
                              ),
                            ),

                            const SizedBox(width: 4),

                            // Third Text Prompt
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: TextButton(
                                onPressed: () async {
                                  if (_overlayEntry != null) {
                                    _overlayEntry!.remove();
                                    _overlayEntry = null;
                                  }
                                  String? textType = "Make shorter";
                                  if (textType != null) {
                                    try {
                                      String newText =
                                          await fetchGeminiText(textType);
                                      String processedText = newText
                                          .replaceAll('**', '')
                                          .replaceAll('*', '');
                                      _replaceSelectedText(processedText);
                                    } catch (e) {
                                      print('Error: $e');
                                    }
                                  }
                                },
                                child: Text(
                                  "Make shorter",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 12),
                                ),
                              ),
                            ),

                            SizedBox(width: 4),

                            // Fourth Text Prompt
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: TextButton(
                                // onPressed: () {
                                //   // Navigate to the VideoPlayerPage when pressed.
                                //   Navigator.of(context).push(
                                //     MaterialPageRoute(
                                //       builder: (context) => const VideoPlayerPage(),
                                //     ),
                                //   );
                                // },
                                // child: const Text(
                                //   'Make longer',
                                //   style: TextStyle(color: Colors.black, fontSize: 12),
                                // ),
                                onPressed: () async {
                                  if (_overlayEntry != null) {
                                    _overlayEntry!.remove();
                                    _overlayEntry = null;
                                  }
                                  String? textType = "Make longer";
                                  if (textType != null) {
                                    try {
                                      String newText =
                                          await fetchGeminiText(textType);
                                      String processedText = newText
                                          .replaceAll('**', '')
                                          .replaceAll('*', '');
                                      _replaceSelectedText(processedText);
                                    } catch (e) {
                                      print('Error: $e');
                                    }
                                  }
                                },
                                child: const Text(
                                  "Make longer",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // First Text Prompt
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: TextButton(
                                onPressed: () {
                                  _removeOverlay();
                                  _showActionOverlay(context);
                                },
                                child: Text(
                                  "Make funny",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 12),
                                ),
                              ),
                            ),

                            SizedBox(width: 4), // Space between prompts

                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: TextButton(
                                onPressed: () async {
                                  if (_overlayEntry != null) {
                                    _overlayEntry!.remove();
                                    _overlayEntry = null;
                                  }
                                  String? textType = "Make longer";
                                  if (textType != null) {
                                    try {
                                      String newText =
                                          await fetchGeminiText(textType);
                                      String processedText = newText
                                          .replaceAll('**', '')
                                          .replaceAll('*', '');
                                      containertext = processedText;
                                      _replaceSelectedText(processedText);
                                    } catch (e) {
                                      print('Error: $e');
                                    }
                                  }
                                },
                                child: const Text(
                                  "Make longer",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                SizedBox(height: 1), // Space between prompts and buttons

                // Row containing Edit Button and Image Button
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Edit Button
                    const SizedBox(width: 2),
                    // Image Button
                    IconButton(
                      onPressed: () async {
                        if (_overlayEntry != null) {
                          _overlayEntry!.remove();
                          _overlayEntry = null;
                        }
                        String? textType = await _showTextTypeDialog(context);
                        if (textType != null) {
                          try {
                            String newText = await fetchGeminiText(textType);
                            String processedText = newText
                                .replaceAll('**', '')
                                .replaceAll('*', '');
                            _replaceSelectedText(processedText);
                          } catch (e) {
                            print('Error: $e');
                          }
                        }
                      },
                      icon: Image.asset(
                        "assest/images/myimage.png", // Corrected path
                        width: 44,
                        height: 44,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.error, color: Colors.red, size: 24);
                        },
                      ),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),

                    const SizedBox(width: 5),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 1.0, horizontal: 20.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(60.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8.0,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: newentry,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Type editing text",
                            hintStyle: TextStyle(
                                color: Color(0xFFb2b7bf), fontSize: 18.0),
                          ),
                          onSubmitted: (newText) {
                            setState(() {
                              // Replace selected text with the new text entered in the TextField
                              _replaceSelectedText(newText);
                            });
                            _overlayEntry
                                ?.remove(); // Close the overlay after submission
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                // ),
              ],
            ),
          ),
        ),
      );
    });
    Overlay.of(context)?.insert(_overlayEntry!);
    _isOverlayShown = true;
  }

  void _removeOverlay() {
    if (!_isOverlayShown) return; // Prevent removing if not shown

    if (_overlayEntry != null && _overlayEntry!.mounted) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    _isOverlayShown = false;
  }

  void _showActionOverlay(BuildContext context) {
    if (_isOverlayShown) return;
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) {
        double screenWidth = MediaQuery.of(context).size.width;

        return Positioned(
          bottom: 20,
          left: (screenWidth - 300) / 2, // Adjust width as needed
          child: Material(
            color: Colors.transparent,
            child: buildActionContainer(onAccept: () {
              print("Accepted!");
              _removeOverlay();
            }),
          ),
        );
      },
    );

    Overlay.of(context)?.insert(_overlayEntry!);
    _isOverlayShown = true;
  }

  Widget buildActionContainer({required VoidCallback onAccept}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 200,
            height: 200,
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.grey[300], // Adjust color as needed
              borderRadius: BorderRadius.circular(10.0),
            ), // Adjust color as needed
            child: SingleChildScrollView(
              child: Center(child: Text(containertext)),
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.check, color: Colors.green),
                onPressed: _func, // Trigger the accept action
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.red),
                onPressed: () {
                  _overlayEntry?.remove(); // Close the overlay
                  _overlayEntry = null;
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _replaceSelectedText(String newText) {
    if (selectedIndex != null && selectedStart != null && selectedEnd != null) {
      setState(() {
        String originalText = noteItems[selectedIndex!].value;
        String updatedText = originalText.replaceRange(
          selectedStart!,
          selectedEnd!,
          newText,
        );
        noteItems[selectedIndex!].value = updatedText;
        _updateNotesInDatabase();
        // Reset selection
        selectedStart = null;
        selectedEnd = null;
        selectedIndex = null;
      });
    }
  }
}
