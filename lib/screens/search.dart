import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:petwatch/screens/profile/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petwatch/components/TopNavigation/message_top_nav.dart';
import 'package:petwatch/screens/message_screen.dart';
import 'package:petwatch/state/user_model.dart';
import 'package:provider/provider.dart';
import 'auth_gate.dart';
import 'package:petwatch/screens/auth_gate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:petwatch/components/components.dart';
import 'package:petwatch/screens/chat.dart';
import 'package:petwatch/utils/db_services.dart';
import 'package:petwatch/components/bottom_nav_bar.dart';
import 'package:petwatch/components/components.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  late List<Map<String, dynamic>> searchSnapshot;
  bool hasUserSearched = false;
  String userName = "";
  bool isJoined = false;
  Timer? _debounce;

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
                    onChanged: (value) {
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(const Duration(milliseconds: 500), () {
                        // do something with query
                        initiateSearchMethod();
                        debugPrint("Running");
                      });
                    },
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
                    // initiateSearchMethod();
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
          .searchByName(searchController.text.toLowerCase())
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
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchSnapshot!.length,
            itemBuilder: (context, index) {
              return userTile(
                searchSnapshot![index]['name'].toString(),
                searchSnapshot![index]['uid'],
                searchSnapshot![index]['name'],
                searchSnapshot![index]['name'],
              );
            },
          )
        : Container(
            // color: Colors.black,

            );
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

  ///USER TILE
  Widget userTile(
      String userName, String recipientId, String groupName, String admin) {
    // function to check whether user already exists in group
    joinedOrNot(userName, admin, groupName, groupName);
    return Consumer<UserModel>(builder: (context, value, child) {
      return ListTile(
        onTap: () async {
          if (isJoined) {
            setState(() {
              isJoined = !isJoined;
            });
            showSnackbar(
                context, Colors.green, "Successfully joined the group");
            // Future.delayed(const Duration(seconds: 2), () {

            // });
          } else {
            // setState(() {
            //   // _isLoading = true;
            // });
            await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                .createGroup(userName, recipientId, groupName)
                .then((val) {
              //_isLoading = false;
              isJoined = !isJoined;
              debugPrint("USERNAME: ${userName}");
              debugPrint("RECIPIENT ID: ${recipientId}");
              debugPrint("GROUPNAME: ${groupName}");

              nextScreen(
                  context,
                  ChatPage(
                    groupId: val,
                    groupName: groupName,
                    userName: value.name['name'],
                  ));
              //showSnackbar(context, Colors.red, "Left the group $groupName");
            });

            // nextScreen(
            //     context,
            //     ChatPage(
            //         groupId: recipientId,
            //         groupName: groupName,
            //         userName: userName));
            // Navigator.of(context).pop();
            showSnackbar(context, Colors.green, "chat created successfully.");
          }
        },
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            userName.substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title:
            Text(userName, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text("Admin: ${getName(admin)}"),
        trailing: InkWell(
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
                  ),
                  child: Icon(Icons.arrow_forward_ios)),
        ),
      );
    });
  }
}
