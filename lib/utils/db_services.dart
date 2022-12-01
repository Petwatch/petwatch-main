import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petwatch/components/components.dart';
import 'package:petwatch/screens/chat.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

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
    DocumentReference groupDocumentReference = await groupCollection.add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$userName",
      "members": [],
      "groupId": Uuid().v1(),
      "recentMessage": "",
      "recentMessageSender": "",
    });
    // update the members
    //update 'groups' collections
    await groupDocumentReference.update({
      "members":
          FieldValue.arrayUnion(["${id}_$userName", '${uid}_$getUserName']),
      "groupId": groupDocumentReference.id,
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
    DocumentReference d = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot['admin'];
  }

  // get group members
  Future getGroupMembers(groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  // search
  Future searchByName(String groupName) async {
    return userCollection
        .where('name', isGreaterThanOrEqualTo: groupName)
        .where('name', isLessThan: groupName + 'z')
        .get();
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
    // // doc reference
    // DocumentReference userDocumentReference = userCollection.doc(uid);
    // DocumentReference groupDocumentReference = groupCollection.doc(groupId);

    // DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    // List<dynamic> groups = await documentSnapshot['groups'];

    // // if user has our groups -> then remove then or also in other part re join
    // if (groups.contains("${groupId}_$groupName")) {
    //   await userDocumentReference.update({
    //     "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
    //   });
    //   await groupDocumentReference.update({
    //     "members": FieldValue.arrayRemove(["${uid}_$userName"])
    //   });
    // } else {
    //   await userDocumentReference.update({
    //     "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
    //   });
    //   await groupDocumentReference.update({
    //     "members": FieldValue.arrayUnion(["${uid}_$userName"])
    //   });
    // }
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
}
