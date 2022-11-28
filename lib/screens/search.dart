import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:petwatch/screens/profile/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petwatch/components/TopNavigation/message_top_nav.dart';
import 'package:petwatch/screens/message_screen.dart';
import 'auth_gate.dart';
import 'package:petwatch/screens/auth_gate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:petwatch/components/components.dart';
import 'package:petwatch/screens/chat.dart';
import 'package:petwatch/utils/db_services.dart';
import 'package:petwatch/components/bottom_nav_bar.dart';
import 'package:petwatch/components/user_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  QuerySnapshot? searchSnapshot;
  bool hasUserSearched = false;
  String userName = "";
  bool isJoined = false;
  User? user;
  final CollectionReference userCollection = FirebaseFirestore.instance
      .collection('building-codes')
      .doc('123456789')
      .collection('users');
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection('groups');
  @override
  void initState() {
    super.initState();
    getCurrentUserIdandName();
  }

  getCurrentUserIdandName() async {
    await DatabaseService.getUserNameFromSF().then((value) {
      setState(() {
        userName = value!.toString();
      });
    });
    user = FirebaseAuth.instance.currentUser;
  }

  String getName(String name) {
    return name.substring(name.indexOf("_") + 1);
  }

  String getId(String id) {
    return id.substring(0, id.indexOf("_"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "New Message",
          style: TextStyle(
              fontSize: 27, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "To: (search users in your area)",
                        hintStyle:
                            TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    initiateSearchMethod();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40)),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
          isLoading
              ? Center(
                  child: Column(children: [
                  CircularProgressIndicator(
                      color: Theme.of(context).primaryColor),
                ]))
              : groupList(),
        ],
      ),
    );
  }

  initiateSearchMethod() async {
    if (searchController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      await DatabaseService()
          .searchByName(searchController.text)
          .then((snapshot) {
        setState(() {
          searchSnapshot = snapshot;
          isLoading = false;
          hasUserSearched = true;
        });
      });
    }
  }

  groupList() {
    return hasUserSearched
        ? ListView.separated(
            shrinkWrap: true,
            itemCount: searchSnapshot!.docs.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              return UserTile(
                searchSnapshot!.docs[index]['name'].toString(),
                recipientId: searchSnapshot!.docs[index]['uid'],
                recipientName: searchSnapshot!.docs[index]['name'],
                userName: userName,
              );
            },
          )
        : Container();
  }

  joinedOrNot(String userName, String recipientId, String groupname,
      String admin) async {
    await DatabaseService(uid: user!.uid)
        .isUserJoined(groupname, recipientId, userName)
        .then((value) {
      setState(() {
        isJoined = value;
      });
    });
  }
}
