import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({super.key});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  // The URL of the video to be played. You can change this to any video URL.
  final String videoUrl =
      'https://www.youtube.com/embed/xEbRZs1L59E'; // Example: Rickroll

  @override
  void initState() {
    super.initState();
    // Initialize the WebViewController.
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
      ..loadRequest(Uri.parse(videoUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
      ),
      body: Stack(
        children: [
          // The WebView widget displaying the video.
          WebViewWidget(controller: _controller),
          // Display a loading indicator while the video is loading.
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Container(),
        ],
      ),
    );
  }
}
