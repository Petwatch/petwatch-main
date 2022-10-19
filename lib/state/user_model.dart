import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel extends ChangeNotifier {
  // UserModel._create({required String uid}) {
  //   final String uid = this.uid;
  //   final String buildingCode;
  //   final String name;
  // }

  UserModel() {
    getUserData();
    // getPetData();
  }
  // static Future<UserModel> create() async {

  // }
  final uid = <String, String>{"uid": FirebaseAuth.instance.currentUser!.uid};
  Map buildingCode = <String, String>{"buildingCode": ""};
  Map name = <String, String>{"Name": ""};
  List<Map<String, dynamic>> petInfo = [];
  bool hasPet = false;

  Future getUserData() async {
    petInfo = [];
    await FirebaseFirestore.instance
        .collectionGroup('users')
        .where('uid', isEqualTo: uid['uid'])
        .get()
        .then((value) {
      // Map test = <String, String>{"Name": ""};
      value.docs.forEach((element) {
        debugPrint("name: ${element.data().toString()}");
        name["Name"] = element['name'];
        buildingCode["buildingCode"] = element["buildingCode"];
      });
    }, onError: (e) => {"Name": "Error Getting Name"});

    // await FirebaseFirestore.instance.collectionGroup("users")
    // .where(uid, isEqualTo: uid['uid']).colelction

    await FirebaseFirestore.instance
        .collectionGroup('pets')
        .where('uid', isEqualTo: uid['uid'])
        .get()
        .then((value) {
      if (value.docs.length != 0) {
        hasPet = true;
      }
      value.docs.forEach((element) {
        // debugPrint(element.data())
        // debugPrint("${element.data().toString()}");
        petInfo.add(element.data());
        debugPrint(petInfo[0]["name"]);
        // debugPrint("${petInfo['friendly']}");
      });
    });

    notifyListeners();
  }

  // final buildingId = <String, String>{"buildingCode": getBuildingID()};

  // final name = <String, String>{
  //   "name": FirebaseFirestore.instance.collection()
  // };

  // UnmodifiableMapView get getName => UnmodifiableMapView(name);
}
