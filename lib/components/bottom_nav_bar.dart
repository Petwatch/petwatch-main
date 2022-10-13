import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:petwatch/screens/auth_gate.dart';
import 'package:petwatch/screens/sign-up/personal_info.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      style: optionStyle,
    ),
    Text(
      'Index 1: Business',
      style: optionStyle,
    ),
    Text(
      'Index 2: School',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.business),
          label: 'Business',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school),
          label: 'School',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.amber[800],
      onTap: _onItemTapped,
    );

    //   return BottomAppBar(
    //     color: Theme.of(context).colorScheme.primary,
    //     child: IconTheme(
    //       data: IconThemeData(color: Colors.white),
    //       child: Row(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: <Widget>[
    //           IconButton(
    //             iconSize: 35,
    //             tooltip: 'Open navigation menu',
    //             icon: const Icon(Icons.home),
    //             onPressed: () {},
    //           ),
    //           IconButton(
    //             iconSize: 35,
    //             tooltip: 'Search',
    //             icon: const Icon(Icons.receipt_long_rounded),
    //             onPressed: () {},
    //           ),
    //           IconButton(
    //             iconSize: 35,
    //             tooltip: 'Favorite',
    //             icon: const Icon(Icons.account_circle_rounded),
    //             onPressed: () {},
    //           ),
    //         ],
    //       ),
    //     ),
    //   );
    // }
  }
}
