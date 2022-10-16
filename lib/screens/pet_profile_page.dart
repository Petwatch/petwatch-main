import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:petwatch/screens/pet-profile/pet_setup_info.dart';

class PetProfilePage extends StatelessWidget {
  // void getPetData() async {
  //   var docRef = await FirebaseFirestore.instance
  //       .collectionGroup('users')
  //       .where('uid',
  //           isEqualTo: FirebaseAuth.instance.currentUser!.uid.toString())
  //       .get();
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
              Container(
                height: MediaQuery.of(context).size.height - 120,
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  children: [
                    Positioned(
                        child: IgnorePointer(
                            child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 175,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ))),
                    Positioned(
                        left: 0,
                        right: 0,
                        bottom: 155,
                        child: IgnorePointer(
                            child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Card(
                                    elevation: 15,
                                    child: Container(
                                      width: 300,
                                      height: 300,
                                      color: Colors.grey[200],
                                    ))))),
                    Positioned(
                        right: 0,
                        left: 0,
                        bottom: 450,
                        child: IgnorePointer(
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
                        )),
                    Positioned(
                      right: 0,
                      left: 0,
                      bottom: 305,
                      child: Column(
                        children: [
                          ElevatedButton(
                              onPressed: () => {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PetSetupInfo()))
                                  },
                              child: const Text(
                                "Setup a pet profile!",
                                style: TextStyle(color: Colors.white),
                              ))
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ]),
          ),
        ));
  }
}
