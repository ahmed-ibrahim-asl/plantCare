//------------------------ third_part_packages -------------------------
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
//----------------------------------------------------------------------

//----------------------------- app_local ------------------------------
import 'services/api_service.dart';
//----------------------------------------------------------------------

class LiveFeedScreen extends StatefulWidget {
  const LiveFeedScreen({super.key});

  @override
  State<LiveFeedScreen> createState() => _LiveFeedScreenState();
}

class _LiveFeedScreenState extends State<LiveFeedScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    final liveFeedUrl = ApiService.getLiveFeedUrl();

    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(Uri.parse(liveFeedUrl));

    debugPrint('Live Feed URL: $liveFeedUrl');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Live Feed',
          style: TextStyle(color: AppColors.primaryDark),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primaryDark),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
