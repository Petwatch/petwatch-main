import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:petwatch/screens/message_screen.dart';
import 'package:provider/provider.dart';

import '../../screens/notifications/notificationCenter.dart';
import '../../state/user_model.dart';

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

  Future<int> getUnreadNotifications(String uid, String buildingCode) async {
    List<dynamic> notifications = [];
    int unreadNotifications = 0;
    await FirebaseFirestore.instance
        .doc("/building-codes/$buildingCode/users/$uid")
        .get()
        .then((value) {
      Map<String, dynamic> test = value.data()!;
      notifications = test["notifications"];
      for (var noti in notifications) {
        if (noti['read'] == false) {
          unreadNotifications += 1;
        }
      }
    });
    return unreadNotifications;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(builder: (context, value, child) {
      debugPrint("${value.transactions}");
      return AppBar(
        leading: IconButton(
            onPressed: () => {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NotificationsCenter()))
                },
            color: Colors.white,
            iconSize: 35,
            icon: FutureBuilder(
                future: getUnreadNotifications(
                    value.uid['uid']!, value.buildingCode['buildingCode']),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Badge(
                        child: const Icon(Icons.notifications),
                        // badgeContent: Text(""),
                        showBadge: false,
                      );
                    default:
                      if (snapshot.hasError) {
                        return Badge(
                          child: const Icon(Icons.notifications),
                          // badgeContent: Text("3"),
                          showBadge: false,
                        );
                      } else {
                        return Badge(
                          child: const Icon(Icons.notifications),
                          badgeContent: Text(snapshot.data.toString(),
                              style: TextStyle(color: Colors.white)),
                          // showBadge: false,
                        );
                      }
                  }
                })),
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
    });
  }
}
