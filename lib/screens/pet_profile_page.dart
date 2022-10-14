import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:petwatch/screens/auth_gate.dart';
import 'package:petwatch/screens/sign-up/personal_info.dart';
import 'package:petwatch/components/TopNavigation/top_nav_bar.dart';
import 'package:petwatch/components/bottom_nav_bar.dart';

class PetProfilePage extends StatelessWidget {
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
          appBar: AppBar(
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
          ),
          body: Center(
            child: Column(children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 150,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  )),
                  Positioned(
                      left: 0,
                      right: 0,
                      bottom: -330,
                      child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Card(
                              elevation: 15,
                              child: Container(
                                width: 300,
                                height: 300,
                                color: Colors.grey[200],
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 110),
                                  child: Column(
                                    children: [
                                      ElevatedButton(
                                          onPressed: () => {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            PetProfilePage()))
                                              },
                                          child: Text(
                                            "Set up a pet profile!",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ))
                                    ],
                                  ),
                                ),
                              )))),
                  Positioned(
                    right: 0,
                    left: 0,
                    bottom: -40,
                    child: Card(
                      elevation: 5,
                      shape: CircleBorder(),
                      child: CircleAvatar(
                        radius: 75,
                        backgroundColor: Colors.white,
                        child: ClipRRect(
                          borderRadius: BorderRadius.zero,
                          child: Image.asset(
                            'assets/images/petwatch_logo.png',
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ]),
          ),
        ));
  }
}
