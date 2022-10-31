import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petwatch/screens/profile/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_gate.dart';
import 'package:petwatch/screens/auth_gate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:petwatch/components/TopNavigation/message_top_nav.dart';
import 'package:petwatch/components/group_chat_tile.dart';
import 'package:petwatch/utils/db_services.dart';
import 'package:petwatch/components/bottom_nav_bar.dart';
import 'package:petwatch/components/components.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({Key? key}) : super(key: key);
  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final uid = <String, String>{"uid": FirebaseAuth.instance.currentUser!.uid};
  Map buildingCode = <String, String>{"buildingCode": ""};
  Map name = <String, String>{"Name": ""};
  Map petInfo = <String, String>{};
  bool hasPet = false;

  String groupName = "";
  String userName = "";
  AuthGate authGate = AuthGate();
  Stream? groups;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  String getName(String name) {
    return name.substring(name.indexOf("_") + 1);
  }

  String getId(String id) {
    return id.substring(0, id.indexOf("_"));
  }

  getUserData() async {
    await DatabaseService.getUserName().then((val) {
      setState(() {
        userName = val!;
      });
    });
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserGroups()
        .then((snapshot) {
      setState(() {
        groups = snapshot;
      });
    });
    // await DatabaseService.getUserNameFromSF().then((val) {
    //   setState(() {
    //     userName = val!;
    //   });
    // });
  }

  // @override
  // Widget build(BuildContext context) {
  //   //listens for actions
  //   return GestureDetector(
  //       onTap: () {},
  //       child: Scaffold(
  //         appBar: MessageNavBar(),
  //         body: Center(
  //           child: Padding(
  //             padding: EdgeInsets.all(24),
  //             child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.center,
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: const [
  //                   Text("Tap the '+' icon to start a new chat"),
  //                 ]),
  //           ),
  //         ),
  //         body: groupList(),
  //         floatingActionButton: FloatingActionButton(
  //           onPressed: () {
  //             popupDialogue(context);
  //           },
  //           elevation: 0,
  //           child: const Icon(
  //             Icons.add,
  //             color: Colors.white,
  //             size: 30,
  //           ),
  //         ),
  //       ));
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "Messages",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 27),
        ),
      ),
      body: groupList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          popupDialogue(context);
        },
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

  popupDialogue(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: ((context, setState) {
            return AlertDialog(
              title: const Text(
                "Start a new chat!",
                textAlign: TextAlign.left,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _isLoading == true
                      ? Center(
                          child: CircularProgressIndicator(
                              color: Theme.of(context).primaryColor),
                        )
                      : TextField(
                          onChanged: (val) {
                            setState(() {
                              groupName = val;
                            });
                          },
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                  borderRadius: BorderRadius.circular(20)),
                              errorBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(20)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                  borderRadius: BorderRadius.circular(20))),
                        ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                    onPressed: () async {
                      if (groupName != "") {
                        setState(() {
                          _isLoading = true;
                        });
                        DatabaseService(
                                uid: FirebaseAuth.instance.currentUser!.uid)
                            .createGroup(
                                name.toString(),
                                FirebaseAuth.instance.currentUser!.uid,
                                groupName)
                            .whenComplete(() {
                          _isLoading = false;
                        });
                        Navigator.of(context).pop();
                        showSnackbar(context, Colors.green,
                            "chat created successfully.");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).primaryColor),
                    child: const Text(
                      "Create chat",
                      style: TextStyle(color: Colors.white),
                    ))
              ],
            );
          }));
        });
  }

  groupList() {
    return StreamBuilder(
        stream: groups,
        builder: (context, AsyncSnapshot snapshot) {
          // make some checks
          if ((snapshot.hasData) && (snapshot.data.exists)) {
            if (snapshot.data['groups'] != null) {
              if (snapshot.data['groups'].length != 0) {
                return ListView.builder(
                  itemCount: snapshot.data['groups'].length,
                  itemBuilder: (context, index) {
                    int reverseIndex =
                        snapshot.data['groups'].length - index - 1;
                    return GroupTile(
                        groupId: getId(snapshot.data['groups'][reverseIndex]),
                        groupName:
                            getName(snapshot.data['groups'][reverseIndex]),
                        userName: snapshot.data['name']);
                  },
                );
              } else {
                return noGroupWidget();
              }
            } else {
              return noGroupWidget();
            }
          } else {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text("Tap the '+' icon to start a new chat"),
                    ]),
              ),
            );
          }
        });
  }

  noGroupWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              popupDialogue(context);
            },
            child: Icon(
              Icons.add_circle,
              color: Colors.grey[700],
              size: 75,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "Tap the '+' icon to start a new chat!",
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
