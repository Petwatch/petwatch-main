import 'dart:async';

import 'package:flutter/material.dart';
import 'package:petwatch/components/TopNavigation/top_nav_bar.dart';
import 'package:petwatch/screens/message_screen.dart';

class MessageNavBar extends StatefulWidget implements PreferredSizeWidget {
  const MessageNavBar({Key? key}) : super(key: key);

  static final _appBar = AppBar();
  @override
  Size get preferredSize => _appBar.preferredSize;

  @override
  _MessageNavBarState createState() => _MessageNavBarState();
}

class _MessageNavBarState extends State<MessageNavBar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {},
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              color: Colors.white,
              iconSize: 35,
              icon: const Icon(Icons.keyboard_arrow_left),
              onPressed: () => {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MessageScreen()))
              },
            ),
            centerTitle: true,
            title: const Text(
              "Messages",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 27),
            ),
          ),
        ));
  }
}
