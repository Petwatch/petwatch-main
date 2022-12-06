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
import 'package:flutter_slidable/flutter_slidable.dart';

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
      debugPrint(snapshot.toString());
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
    );
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
  }

  groupList() {
    return StreamBuilder(
        stream: groups,
        builder: (context, AsyncSnapshot snapshot) {
          // make some checks
          if ((snapshot.hasData) && (snapshot.data.exists)) {
            if (snapshot.data['groups'] != null) {
              if (snapshot.data['groups'].length != 0) {
                return ListView.separated(
                  itemCount: snapshot.data['groups'].length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.arrow_forward_ios),
                    );
                    int reverseIndex =
                        snapshot.data['groups'].length - index - 1;
                    // debugPrint(
                    //     " ${snapshot.data["groups"][reverseIndex].toString()}");

                    return GroupTile(
                      groupId: getId(snapshot.data['groups'][reverseIndex]),
                      groupName: getName(snapshot.data['groups'][reverseIndex]),
                      // getName(snapshot.data['groups'][reverseIndex]),
                      userName: snapshot.data['name'],
                    );
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
                      Icon(Icons.arrow_forward_ios),
                      Text("No messages :("),
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
