import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:petwatch/components/components.dart';
import 'package:petwatch/screens/chat.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

//keys
  static String userLoggedInKey = "LOGGEDINKEY";
  static String userNameKey = "USERNAMEKEY";
  static String userEmailKey = "USEREMAILKEY";

  // reference for our collections
  final CollectionReference userCollection = FirebaseFirestore.instance
      .collection('building-codes')
      .doc('123456789')
      .collection('users');
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection('groups');

  // saving userData
  Future savingUserData(String fullName) async {
    return await userCollection.doc(uid).set({
      "fullName": fullName,
      "groups": [],
      "profilePic": "",
      "uid": uid,
    });
  }

  static Future<String?> getUserName() async {
    DocumentReference? name = FirebaseFirestore.instance
        .collection('building-codes')
        .doc('123456789')
        .collection('users')
        .doc('uid');
    return name.toString();
  }

  // getting user data
  Future getUserData(String fullNames) async {
    QuerySnapshot snapshot =
        await userCollection.where("name", isEqualTo: fullNames).get();
    return snapshot;
  }

  static Future<bool> saveUserNameSF(String userName) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(userNameKey, userName);
  }

  static Future<String?> getUserNameFromSF() async {
    return getUserName();

    // SharedPreferences sf = await SharedPreferences.getInstance();
    // return sf.getString(userNameKey);
  }

  // get user groups
  getUserGroups() async {
    return userCollection.doc(uid).snapshots();
  }

  // creating a group
  Future createGroup(String userName, String id, String groupName) async {
    String groupId = "";
    DocumentReference groupDocumentReference = await groupCollection.add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$userName",
      "members": [],
      "memberNames": [],
      "groupId": Uuid().v1(),
      "recentMessage": "",
      "recentMessageSender": "",
    });
    // update the members
    //update 'groups' collections
    String name = "";
    await FirebaseFirestore.instance
        .collectionGroup("users")
        .where("uid", isEqualTo: uid)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        name = element.data()["name"];
      });
    });
    await groupDocumentReference.get().then((value) {
      groupId = groupDocumentReference.id;
      value.reference.update({
        "members": FieldValue.arrayUnion(["${id}", '${uid}']),
        "memberNames": FieldValue.arrayUnion(([
          {"uid": '${id}', "name": "$groupName"},
          {"uid": "${uid}", "name": "$name"}
        ])),
        "groupId": groupDocumentReference.id,
      });
    });

    //Update recipient docs
    DocumentReference recipientDocumentReference = FirebaseFirestore.instance
        .collection('building-codes')
        .doc('123456789')
        .collection('users')
        .doc(id);
    await recipientDocumentReference.update({
      "groups":
          FieldValue.arrayUnion(["${groupDocumentReference.id}_$userName"])
    });
    //update sender groups doc
    DocumentReference userDocumentReference = FirebaseFirestore.instance
        .collection('building-codes')
        .doc('123456789')
        .collection('users')
        .doc(uid);
    await userDocumentReference.update({
      "groups":
          FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"])
    });

    return groupId;
  }

  // getting the chats
  getChats(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

//get group owner/administrator
  Future getGroupAdmin(String groupId) async {
    debugPrint("GROUP ID: " + groupId.toString());
    DocumentReference d = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot['admin'];
  }

  // get group members
  Future getGroupMembers(groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  Future searchByName(String groupName) async {
    // Get the query snapshot
    var querySnapshot = await userCollection.get();

    // Get the list of documents from the query snapshot
    var documents = querySnapshot.docs;

    // Use the map method to transform the documents into a new list of User objects
    var users =
        documents.map((doc) => doc.data() as Map<String, dynamic>).toList();

    // Filter the list of users based on the search term
    var result = searchArray(users, groupName);

    // Return the result
    return result;
  }

  List<Map<String, dynamic>> searchArray(
      List<Map<String, dynamic>> array, String searchTerm) {
    searchTerm = searchTerm.toLowerCase();
    return array
        .where((item) => item['name'].toLowerCase().startsWith(searchTerm))
        .toList();
  }

  // function -> bool
  Future<bool> isUserJoined(
      String groupName, String groupId, String userName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();

    List<dynamic> groups = await documentSnapshot['groups'];
    if (groups.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }

  // toggling the group join/exit
  Future toggleGroupJoin(
      String groupId, String userName, String groupName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    List<dynamic> groups = await documentSnapshot['groups'];
    if (groups.contains("${groupId}_$groupName")) {
      return 1;
      //open group maybe return group?
    } else {
      return 0;
    }
  }

  // send message
  sendMessage(String groupId, Map<String, dynamic> chatMessageData) async {
    groupCollection.doc(groupId).collection("messages").add(chatMessageData);
    groupCollection.doc(groupId).update({
      "recentMessage": chatMessageData['message'],
      "recentMessageSender": chatMessageData['sender'],
      "recentMessageTime": chatMessageData['time'].toString(),
    });
  }

//add recent message to placeholder text instead of jus start a conversation of wha
}
