import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:petwatch/screens/auth_gate.dart';
import 'package:petwatch/screens/sign-up/personal_info.dart';
import 'package:petwatch/components/TopNavigation/top_nav_bar.dart';
import 'package:petwatch/components/bottom_nav_bar.dart';
import 'package:petwatch/screens/pet_profile_page.dart';

class HomePage extends StatelessWidget {
  // @override
  // State<StatefulWidget> createState() {
  //   // TODO: implement createState
  //   throw UnimplementedError();
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {},
        child: Scaffold(
          appBar: TopNavBar(),
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(FirebaseAuth.instance.currentUser!.uid.toString()),
                    SignOutButton(),
                    ElevatedButton(
                        onPressed: () => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PetProfilePage()))
                            },
                        child: Text("Pet"))
                  ]),
            ),
          ),
        ));
  }
}
