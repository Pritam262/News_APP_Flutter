import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NewsView extends StatefulWidget {
  late String url;
  late String finalUrl;
  NewsView(this.url,{super.key});

  @override
  State<NewsView> createState() => _NewsViewState();
}

class _NewsViewState extends State<NewsView> {
  late WebViewController controller;
  @override
  void initState() {
    var finalUrl = widget.url;
    // TODO: implement initState
    super.initState();
    if(widget.url.toString().contains('http://')){
      finalUrl = widget.url.toString().replaceAll('http://', 'https://');
    }else{
      finalUrl = widget.url;
    }
    controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted);
    controller.loadRequest(Uri.parse(finalUrl));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: WebViewWidget(controller: controller)),
    );
  }
}

