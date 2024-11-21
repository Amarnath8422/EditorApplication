// import 'package:app/BirdNotes.dart';

// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// // Make sure this import matches your package in pubspec.yaml
// import 'package:flutter_gemini/flutter_gemini.dart';

// // final gemini = Gemini.instance;
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   Gemini.init(apiKey: 'AIzaSyBchHBI04NQZdNN0fcAEHWqKvnyU7eMKlE');
//   try {
//     // Initialize FlutterGemini if available
//     // await gemini.;
//     // gemini.initialize();
//     // Firebase initialization
//     await Firebase.initializeApp(
//       options: const FirebaseOptions(
//           // apiKey: "AIzaSyDCbeMfxt3x1nkLh03pxqwr_ytV-sgCPz8",
//           // authDomain: "editapp-e3f62.firebaseapp.com",
//           // databaseURL: "https://editapp-e3f62-default-rtdb.firebaseio.com",
//           // projectId: "editapp-e3f62",
//           // storageBucket: "editapp-e3f62.appspot.com",
//           // messagingSenderId: "572593966714",
//           // appId: "1:572593966714:web:d4d3470c5075e10f71f5c3",

//           apiKey: "AIzaSyCDTY33nf7CZ0ZxWGC8LSbO0jHfnT6eGKg",
//           authDomain: "appedit-b15c2.firebaseapp.com",
//           databaseURL: "https://appedit-b15c2-default-rtdb.firebaseio.com",
//           projectId: "appedit-b15c2",
//           storageBucket: "appedit-b15c2.firebasestorage.app",
//           messagingSenderId: "779642596729",
//           appId: "1:779642596729:web:31495faa772d862dad53a8"),
//     );
//     print("Firebase initialized successfully");
//   } catch (e) {
//     print("Error initializing Firebase or FlutterGemini: $e");
//   }

//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: BirdNotes(),
//       // VideoApp(videoUrl: 'https://www.youtube.com/embed/xEbRZs1L59E')
//       //  BirdNotes(),
//     );
//   }
// }

// import 'package:ch/screens/chat.dart';
import 'package:app/Splash.dart';
import 'package:app/BirdNotes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app/AuthScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Gemini.init(apiKey: 'AIzaSyBchHBI04NQZdNN0fcAEHWqKvnyU7eMKlE');
  try {
    // Initialize FlutterGemini if available
    // await gemini.;
    // gemini.initialize();
    // Firebase initialization
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          // apiKey: "AIzaSyDCbeMfxt3x1nkLh03pxqwr_ytV-sgCPz8",
          // authDomain: "editapp-e3f62.firebaseapp.com",
          // databaseURL: "https://editapp-e3f62-default-rtdb.firebaseio.com",
          // projectId: "editapp-e3f62",
          // storageBucket: "editapp-e3f62.appspot.com",
          // messagingSenderId: "572593966714",
          // appId: "1:572593966714:web:d4d3470c5075e10f71f5c3",

          apiKey: "AIzaSyCDTY33nf7CZ0ZxWGC8LSbO0jHfnT6eGKg",
          authDomain: "appedit-b15c2.firebaseapp.com",
          databaseURL: "https://appedit-b15c2-default-rtdb.firebaseio.com",
          projectId: "appedit-b15c2",
          storageBucket: "appedit-b15c2.firebasestorage.app",
          messagingSenderId: "779642596729",
          appId: "1:779642596729:web:31495faa772d862dad53a8"),
    );
    print("Firebase initialized successfully");
  } catch (e) {
    print("Error initializing Firebase or FlutterGemini: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat',
      theme: ThemeData().copyWith(
        // useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(84, 50, 2, 2),
        ),
      ),
      home: StreamBuilder(
          //producing multiple things over time
          stream: FirebaseAuth.instance
              .authStateChanges(), //like if token remove or make it notify me
          builder: (ctx, snapshot) {
            //snapshot is data
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }
            if (snapshot.hasData) {
              return BirdNotes();
            }
            return const AuthScreen();
          }),
    );
  }
}














// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:socket_io_client/socket_io_client.dart' as IO;

// class Teleprompter extends StatefulWidget {
//   @override
//   _TeleprompterState createState() => _TeleprompterState();
// }

// class _TeleprompterState extends State<Teleprompter> {
//   final List<String> _lines = [];
//   int _currentLine = 0;
//   late IO.Socket socket;

//   @override
//   void initState() {
//     super.initState();
//     _readFile();
//     _initializeSocket();
//   }

//   Future<void> _readFile() async {
//     final file = File('scripts.txt'); // Make sure this path is correct
//     final lines = await file.readAsLines();
//     setState(() {
//       _lines.addAll(lines);
//     });
//     _startTeleprompter();
//   }

//   void _initializeSocket() {
//     socket = IO.io('http://your-backend-url.com', <String, dynamic>{
//       'transports': ['websocket'],
//       'autoConnect': false,
//     });
//     socket.connect();
//   }

//   void _startTeleprompter() {
//     Timer.periodic(Duration(seconds: 3), (timer) {
//       if (_currentLine < _lines.length) {
//         _detectLinks(_lines[_currentLine]);
//         setState(() {
//           _currentLine++;
//         });
//       } else {
//         timer.cancel(); // Stop when all lines are read
//       }
//     });
//   }

//   void _detectLinks(String line) {
//     final urlPattern = RegExp(r'(https?://[^\s]+)', caseSensitive: false);
//     final matches = urlPattern.allMatches(line);
//     for (final match in matches) {
//       final url = match.group(0);
//       if (url != null) {
//         _sendLinkToServer(url);
//       }
//     }
//   }

//   Future<void> _sendLinkToServer(String link) async {
//     final response = await http.post(
//       Uri.parse('http://your-backend-url.com/media'),
//       headers: {'Content-Type': 'application/json'},
//       body: '{"url": "$link"}',
//     );

//     if (response.statusCode == 200) {
//       print('Link sent successfully.');
//     } else {
//       print('Failed to send link.');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Teleprompter')),
//       body: Center(
//         child: Text(
//           _currentLine < _lines.length ? _lines[_currentLine] : '',
//           style: TextStyle(fontSize: 24),
//         ),
//       ),
//     );
//   }
// }






/// The Video Player Page that displays the video within a WebView.






// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// class VideoPlayerPage extends StatefulWidget {
//   final String videoUrl;

//   const VideoPlayerPage({Key? key, required this.videoUrl}) : super(key: key);

//   @override
//   _VideoPlayerPageState createState() => _VideoPlayerPageState();
// }

// class _VideoPlayerPageState extends State<VideoPlayerPage> {
//   late InAppWebViewController _webViewController;
//   late InAppWebView _webView;

//   @override
//   void initState() {
//     super.initState();
//     _webView = InAppWebView(
//       initialUrlRequest: URLRequest(url: Uri.parse(widget.videoUrl)),
//       initialOptions: InAppWebViewGroupOptions(
//         crossPlatform: InAppWebViewOptions(
//           javaScriptEnabled: true, // Enable JavaScript
//         ),
//       ),
//       onWebViewCreated: (InAppWebViewController controller) {
//         _webViewController = controller;
//       },
//       onLoadStart: (InAppWebViewController controller, Uri? url) {
//         print("Started loading: $url");
//       },
//       onLoadStop: (InAppWebViewController controller, Uri? url) async {
//         print("Stopped loading: $url");
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Video Player"),
//       ),
//       body: Center(
//         child: _webView,
//       ),
//     );
//   }
// }

// void main() {
//   runApp(MaterialApp(
//     home: VideoPlayerPage(
//       videoUrl:
//           'https://www.youtube.com/embed/xEbRZs1L59E', // Example YouTube URL
//     ),
//   ));
// }
