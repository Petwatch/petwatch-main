import 'package:flutter/material.dart';
import 'package:petwatch/screens/message_screen.dart';

class TopNavBar extends StatefulWidget implements PreferredSizeWidget {
  const TopNavBar({Key? key}) : super(key: key);

  static final _appBar = AppBar();
  @override
  Size get preferredSize => _appBar.preferredSize;

  @override
  _TopNavBarState createState() => _TopNavBarState();
}

class _TopNavBarState extends State<TopNavBar> {
  Color _color = Colors.red;

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
        icon: const Icon(Icons.filter_alt_rounded),
        onPressed: () => {},
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
      actions: [
        IconButton(
          color: Colors.white,
          icon: const Icon(Icons.message_outlined),
          iconSize: 35,
          onPressed: () => {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => MessageScreen()))
          },
        )
      ],
    );
  }
}
