import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class DashboardPage extends StatefulWidget {
  final Uri url;
  final String title;

  DashboardPage({required this.url, required this.title});

  @override
  State<DashboardPage> createState() =>
      _DashboardPageState(url: this.url, title: this.title);
}

@override
class _DashboardPageState extends State<DashboardPage> {
  final Uri url;
  final String title;

  _DashboardPageState({required this.url, required this.title});

  InAppWebViewController? webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          color: Colors.white,
          iconSize: 35,
          icon: const Icon(Icons.keyboard_arrow_left),
          onPressed: () => {Navigator.pop(context)},
        ),
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(children: [
        Expanded(
          child: InAppWebView(
            initialUrlRequest: URLRequest(url: widget.url),
          ),
        ),
      ]),
    );
  }
}
