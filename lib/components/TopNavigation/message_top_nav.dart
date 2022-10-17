import 'package:flutter/material.dart';
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
    return AppBar(
      leading: IconButton(
        color: Colors.white,
        iconSize: 35,
        icon: const Icon(Icons.keyboard_arrow_left),
        onPressed: () => {Navigator.pop(context)},
      ),
      title: Container(
        width: 75,
        height: 75,
        child: Image.asset(
          'assets/images/petwatch_logo_white.png',
        ),
      ),
      centerTitle: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }
}
