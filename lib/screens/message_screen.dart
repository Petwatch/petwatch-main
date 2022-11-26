import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:petwatch/screens/profile/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petwatch/components/user_tile.dart';
import 'package:petwatch/screens/search.dart';
import 'auth_gate.dart';
import 'package:petwatch/screens/auth_gate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:petwatch/screens/chat.dart';
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
  final Map uid = <String, String>{
    "uid": FirebaseAuth.instance.currentUser!.uid
  };

  Map buildingCode = <String, String>{"buildingCode": ""};
  Map name = <String, String>{"Name": ""};
  Map petInfo = <String, String>{};
  bool hasPet = false;
  Map messageGroups = <String, dynamic>{"groups": ""};
  String groupName = "";
  String userName = "";
  AuthGate authGate = AuthGate();
  Stream? groups;
  bool _isLoading = false;

  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  QuerySnapshot? searchSnapshot;
  bool hasUserSearched = false;
  bool isJoined = false;
  User? user;
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection('groups');

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
    await DatabaseService.getUserNameFromSF().then((val) {
      setState(() {
        userName = val!;
      });
    });
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
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
              color: Colors.white,
              onPressed: () {
                nextScreen(context, SearchPage());
              },
              icon: const Icon(Icons.create))
        ],
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

  searchGroupList() {
    return hasUserSearched
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchSnapshot!.docs.length,
            itemBuilder: (context, index) {
              return groupTile(
                userName,
                searchSnapshot!.docs[index]['groupId'],
                searchSnapshot!.docs[index]['groupName'],
                searchSnapshot!.docs[index]['admin'],
              );
            },
          )
        : Container();
  }

  joinedOrNot(
      String userName, String groupId, String groupname, String admin) async {
    await DatabaseService(uid: user!.uid)
        .isUserJoined(groupname, groupId, userName)
        .then((value) {
      setState(() {
        isJoined = value;
      });
    });
  }

  Widget groupTile(
      String userName, String groupId, String groupName, String admin) {
    // function to check whether user already exists in group
    joinedOrNot(userName, groupId, groupName, admin);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(
          groupName.substring(0, 1).toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title:
          Text(groupName, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text("Admin: ${getName(admin)}"),
      trailing: InkWell(
        onTap: () async {
          await DatabaseService(uid: user!.uid)
              .toggleGroupJoin(groupId, userName, groupName);
          if (isJoined) {
            setState(() {
              isJoined = !isJoined;
            });
            showSnackbar(
                context, Colors.green, "Successfully joined the group");
            Future.delayed(const Duration(seconds: 2), () {
              nextScreen(
                  context,
                  ChatPage(
                      groupId: groupId,
                      groupName: groupName,
                      userName: userName));
            });
          } else {
            setState(() {
              isJoined = !isJoined;
              showSnackbar(context, Colors.red, "Left the group $groupName");
            });
          }
        },
        child: isJoined
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black,
                  border: Border.all(color: Colors.white, width: 1),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Text(
                  "Joined",
                  style: TextStyle(color: Colors.white),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).primaryColor,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Text("Send Message",
                    style: TextStyle(color: Colors.white)),
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
                "search for a user",
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
                            dynamic tempName = initiateSearchMethod(val);
                            // groupName = tempName.toString();
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
                      "Search",
                      style: TextStyle(color: Colors.white),
                    ))
              ],
            );
          }));
        });
  }

  Stream<DocumentSnapshot> provideDocumentFieldStream() {
    return FirebaseFirestore.instance
        .collection('building-codes')
        .doc('123456789')
        .snapshots();
  }

  initiateSearchMethod(value) async {
    if ((value != null) && (value.length > 0)) {
      setState(() {
        isLoading = true;
      });

      final Stream searchedName = FirebaseFirestore.instance
          .collection('building-codes')
          .doc('123456789')
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: value)
          .where('name', isLessThan: value + 'z')
          .snapshots();
      (context, snapshot) {
        if ((snapshot.hasData) && (snapshot.data['name'].exists)) {
          if (snapshot.data['name'] != null) {
            if (snapshot.data['name'].length != 0) {
              Text(searchedName.toString());
              print(searchedName.toString());
              groupName = searchedName.toString();
            }
          }
        }
      };
    }
    // print(searchSnapshot!.docs[].data().toString());
    // print(userSnapshotReference.snapshots());
    // return userSnapshotReference;

    // if (searchController.text.isNotEmpty) {
    //   setState(() {
    //     isLoading = true;
    //   });
    //   await DatabaseService()
    //       .searchByName(searchController.text)
    //       .then((snapshot) {
    //     setState(() {
    //       searchSnapshot = snapshot;
    //       isLoading = false;
    //       hasUserSearched = true;
    //     });
    //   });
    //   print('hello from initiateSearch!! <3');
    // }
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
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          const Text(
            "Tap the icon to start a new chat!",
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
