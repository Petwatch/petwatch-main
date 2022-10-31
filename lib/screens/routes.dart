import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:petwatch/screens/auth_gate.dart';
import 'package:petwatch/screens/profile/profile_page.dart';
import 'package:petwatch/screens/sign-up/personal_info.dart';
import 'package:petwatch/components/TopNavigation/top_nav_bar.dart';
import 'package:petwatch/components/bottom_nav_bar.dart';
import 'package:petwatch/screens/home-page/home_page.dart';
import 'package:petwatch/state/user_model.dart';
import 'package:provider/provider.dart';

class Routes extends StatefulWidget {
  const Routes();
  // final BuildContext context;
  @override
  State<Routes> createState() => _RoutesState();
}

class _RoutesState extends State<Routes> {
  int _selectedIndex = 0;

  static final List<String> _widgetOptions = <String>[
    'HomePage',
    "Receipts",
    'ProfilePage',
  ];
  Widget gotoPage(int index) {
    if (index == 0) {
      return HomePage();
    } else if (index == 2) {
      return ProfilePage();
    }
    return Text("data");
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // context = widget.context;
    return ChangeNotifierProvider(
      create: ((context) => UserModel()),
      builder: (context, child) {
        return GestureDetector(
            onTap: () {},
            child: Scaffold(
              body: Center(
                child: gotoPage(_selectedIndex),
              ),
              bottomNavigationBar: BottomNavBar(
                onItemTapped: _onItemTapped,
                selectedIndex: _selectedIndex,
              ),
            ));
      },
    );
  }
}
