import 'dart:convert';
import 'package:app/VideoPlayer.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

class LinkPreviewPage extends StatefulWidget {
  final String url;

  LinkPreviewPage({required this.url});

  @override
  _LinkPreviewPageState createState() => _LinkPreviewPageState();
}

class _LinkPreviewPageState extends State<LinkPreviewPage> {
  VideoPlayerController? _videoController;
  bool isImage = false;
  bool isVideo = true;
  bool isLoading = true;
  bool isError = false;
  String currentUrl = '';
  final TextEditingController _searchController = TextEditingController();

  // Google Custom Search API constants
  final String apiKey = 'AIzaSyCLSvQ_IEDbFrhuotSrUX_AoUhNVxjJ6cQ';
  final String cseId = 'a6bd476e35ea14adc';
  String VideoUrl = 'https://www.youtube.com/embed/xEbRZs1L59E';
  // String newurl = widget.url;

  @override
  void initState() {
    super.initState();
    currentUrl = widget.url;
    // func();
    _checkContentType(currentUrl);
  }

  // String newurllink = url;
  // Function to check content type of URL
  Future<void> _checkContentType(String url) async {
    try {
      setState(() {
        isLoading = true;
        isError = false;
        VideoUrl = url;
      });
      print('hello');
      print('url is $VideoUrl');
      print('Hi');

      url = url.replaceAll(')', ''); // Ensure the URL is cleaned up
      final response = await http.head(Uri.parse(url));
      // print('Header is $response');
      final contentType = response.headers['content-type'];
      // print('contentType is $contentType');
      if (contentType != null) {
        if (contentType.startsWith('image')) {
          setState(() {
            isImage = true;
            // isVideo = false;
            isLoading = false;
          });
        } else if (contentType.startsWith('video')) {
        } else {
          setState(() {
            // VideoUrl =
            isError = true; // Unsupported content type
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isError = true; // No content type found
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isError = true;
        isLoading = false;
      });
      print("Error loading content: $e");
    }
  }

  // Function to search for an image using Google Custom Search API
  Future<String?> searchImage(String query) async {
    final url = Uri.parse(
      'https://www.googleapis.com/customsearch/v1?q=$query+site:commons.wikimedia.org&cx=$cseId&key=$apiKey&searchType=image',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final results = json.decode(response.body);
        final items = results['items'] as List<dynamic>?;

        if (items != null && items.isNotEmpty) {
          // print('clean url is $items[0]['link']');
          return items[0]['link'] as String; // Return the first image link
        }
      } else {
        print('Failed to fetch image: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching image for query '$query': $e");
    }
    return null; // Return null if no image found or in case of an error
  }

  // Function to search and replace the image based on query
  Future<void> _searchAndReplaceImage(String query) async {
    try {
      setState(() {
        isLoading = true;
        isError = false;
      });

      final newUrl = await searchImage(query);

      if (newUrl != null && newUrl.isNotEmpty) {
        setState(() {
          currentUrl = newUrl; //   "https://cors-anywhere.herokuapp.com/" +
          isLoading = false;
          isImage = true;
          // isVideo = false;
        });
      } else {
        setState(() {
          isError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isError = true;
        isLoading = false;
      });
      print("Error during search and replace: $e");
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Link Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search for a new image (e.g., "lion photo")',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    String query = _searchController.text.trim();
                    if (query.isNotEmpty) {
                      _searchAndReplaceImage(query);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: Center(
          child: isLoading
              ? const CircularProgressIndicator() // Show loading indicator
              // : isError
              //     ? const Padding(
              //         padding: EdgeInsets.all(16.0),
              //         // print('hello bro how r ru');
              //         child: Text(
              //           'Error loading content. Please check the URL.',
              //           style: TextStyle(fontSize: 16),
              //           textAlign: TextAlign.center,
              //         ),
              //       )
              : VideoUrl.contains('https://www.youtube.com')
                  ? VideoApp(videoUrl: VideoUrl) // Display the image
                  : Image.network(currentUrl)),
    );
  }
}

// lib/link_preview_page.dart

// import 'dart:convert';
// import 'package:app/VideoPlayer.dart';
// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:http/http.dart' as http;

// class LinkPreviewPage extends StatefulWidget {
//   final String url;

//   const LinkPreviewPage({Key? key, required this.url}) : super(key: key);

//   @override
//   _LinkPreviewPageState createState() => _LinkPreviewPageState();
// }

// class _LinkPreviewPageState extends State<LinkPreviewPage> {
//   bool isImage = false;
//   bool isVideo = false;
//   bool isLoading = true;
//   bool isError = false;
//   String currentImageUrl = '';
//   String videoUrl =
//       'https://www.youtube.com/embed/xEbRZs1L59E'; // Default video URL
//   final TextEditingController _searchController = TextEditingController();

//   // Google Custom Search API constants
//   final String apiKey = 'YOUR_API_KEY'; // Replace with your API key
//   final String cseId =
//       'YOUR_CSE_ID'; // Replace with your Custom Search Engine ID

//   @override
//   void initState() {
//     super.initState();
//     _determineContentType(widget.url);
//   }

//   // Function to check content type of URL
//   Future<void> _determineContentType(String url) async {
//     try {
//       setState(() {
//         isLoading = true;
//         isError = false;
//       });

//       final response = await http.head(Uri.parse(url));
//       final contentType = response.headers['content-type'];

//       if (contentType != null) {
//         if (contentType.startsWith('image')) {
//           setState(() {
//             isImage = true;
//             isVideo = false;
//             currentImageUrl = url;
//             isLoading = false;
//           });
//         } else if (contentType.startsWith('video') ||
//             url.contains('youtube.com') ||
//             url.contains('youtu.be')) {
//           setState(() {
//             isVideo = true;
//             isImage = false;
//             videoUrl = _convertToEmbedUrl(url);
//             isLoading = false;
//           });
//         } else {
//           setState(() {
//             isError = true;
//             isLoading = false;
//           });
//         }
//       } else {
//         setState(() {
//           isError = true;
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         isError = true;
//         isLoading = false;
//       });
//       print("Error determining content type: $e");
//     }
//   }

//   // Function to convert YouTube URLs to embed URLs
//   String _convertToEmbedUrl(String url) {
//     if (url.contains('youtube.com/watch?v=')) {
//       final videoId = url.split('v=').last.split('&').first;
//       return 'https://www.youtube.com/embed/$videoId';
//     } else if (url.contains('youtu.be/')) {
//       final videoId = url.split('youtu.be/').last.split('?').first;
//       return 'https://www.youtube.com/embed/$videoId';
//     }
//     return url; // Return original URL if it's not a YouTube URL
//   }

//   // Function to search for an image using Google Custom Search API
//   Future<String?> _searchImage(String query) async {
//     final url = Uri.parse(
//       'https://www.googleapis.com/customsearch/v1?q=$query+site:commons.wikimedia.org&cx=$cseId&key=$apiKey&searchType=image',
//     );

//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final results = json.decode(response.body);
//         final items = results['items'] as List<dynamic>?;

//         if (items != null && items.isNotEmpty) {
//           return items[0]['link'] as String; // Return the first image link
//         }
//       } else {
//         print('Failed to fetch image: ${response.statusCode}');
//       }
//     } catch (e) {
//       print("Error fetching image for query '$query': $e");
//     }
//     return null; // Return null if no image found or in case of an error
//   }

//   // Function to search and replace the image based on query
//   Future<void> _searchAndReplaceImage(String query) async {
//     try {
//       setState(() {
//         isLoading = true;
//         isError = false;
//       });

//       final newUrl = await _searchImage(query);

//       if (newUrl != null && newUrl.isNotEmpty) {
//         setState(() {
//           currentImageUrl = newUrl;
//           isImage = true;
//           isVideo = false;
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           isError = true;
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         isError = true;
//         isLoading = false;
//       });
//       print("Error during search and replace: $e");
//     }
//   }

//   // Function to toggle between image and video
//   void _toggleMedia() {
//     if (isImage) {
//       setState(() {
//         isImage = false;
//         isVideo = true;
//         isLoading = false;
//       });
//     } else if (isVideo) {
//       setState(() {
//         isVideo = false;
//         isImage = true;
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Link Preview'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.close),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           ),
//         ],
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(60.0),
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 // Search TextField
//                 Expanded(
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: const InputDecoration(
//                       hintText: 'Search for a new image (e.g., "lion photo")',
//                       border: OutlineInputBorder(),
//                       contentPadding: EdgeInsets.symmetric(horizontal: 10),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 // Search Button
//                 ElevatedButton(
//                   onPressed: () {
//                     String query = _searchController.text.trim();
//                     if (query.isNotEmpty) {
//                       _searchAndReplaceImage(query);
//                     }
//                   },
//                   child: const Icon(Icons.search),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       body: Center(
//         child: isLoading
//             ? const CircularProgressIndicator() // Show loading indicator
//             : isError
//                 ? const Padding(
//                     padding: EdgeInsets.all(16.0),
//                     child: Text(
//                       'Error loading content. Please check the URL.',
//                       style: TextStyle(fontSize: 16),
//                       textAlign: TextAlign.center,
//                     ),
//                   )
//                 : GestureDetector(
//                     onTap: _toggleMedia, // Toggle media on tap
//                     child: isImage
//                         ? Image.network(
//                             currentImageUrl,
//                             fit: BoxFit.contain,
//                             errorBuilder: (context, error, stackTrace) {
//                               return const Icon(Icons.error,
//                                   color: Colors.red, size: 24);
//                             },
//                           )
//                         : VideoApp(videoUrl: videoUrl)
//                     // : WebView(
//                     //     initialUrl: videoUrl,
//                     //     javascriptMode: JavascriptMode.unrestricted,
//                     //     onWebViewCreated: (WebViewController webViewController) {
//                     //       // Optional: Store controller if needed
//                     //     },
//                     //     onPageStarted: (String url) {
//                     //       setState(() {
//                     //         isLoading = true;
//                     //       });
//                     //     },
//                     //     onPageFinished: (String url) {
//                     //       setState(() {
//                     //         isLoading = false;
//                     //       });
//                     //     },
//                     //     onWebResourceError: (error) {
//                     //       setState(() {
//                     //         isError = true;
//                     //         isLoading = false;
//                     //       });
//                     //       print('WebView Error: $error');
//                     //     },
//                     //   ),
//                     ),
//       ),
//     );
//   }
// }
