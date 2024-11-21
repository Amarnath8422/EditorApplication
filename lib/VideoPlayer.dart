import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VideoApp extends StatefulWidget {
  const VideoApp({Key? key, required this.videoUrl}) : super(key: key);
  final String videoUrl;

  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  late final WebViewController _controller;
  bool _isLoading = true;
  final String videoUrl = 'https://www.youtube.com/embed/xEbRZs1L59E';
  @override
  void initState() {
    print('url is');
    super.initState();
    final String? videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    print('videoId is $videoId');
    if (videoId != null) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              setState(() {
                _isLoading = true;
              });
            },
            onPageFinished: (String url) {
              setState(() {
                _isLoading = false;
              });
            },
            onWebResourceError: (WebResourceError error) {
              // Handle web resource errors.
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Error loading video: ${error.description}')),
              );
            },
          ),
        )
        ..loadRequest(Uri.parse('https://www.youtube.com/embed/$videoId'));
    } else {
      throw Exception('Invalid YouTube URL');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Video Demo',
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Video Player'),
          ),
          body: Stack(
            children: [
              WebViewWidget(controller: _controller),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Container(),
            ],
          ),
        ));
  }
}
