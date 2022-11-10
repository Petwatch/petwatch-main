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
    this.posts;
  }
  final uid = <String, String>{"uid": FirebaseAuth.instance.currentUser!.uid};
  Map buildingCode = <String, String>{"buildingCode": ""};
  Map name = <String, String>{"name": ""};
  Map pictureUrl = <String, String>{"pictureUrl": ""};
  List<Map<String, dynamic>> petInfo = [];
  bool hasPet = false;
  bool postsLoading = true;
  bool hasPicture = false;

  List<Map<String, dynamic>> posts = [];

  set postsStuff(List<Map<String, dynamic>> posts) {
    posts = this.posts;
  }

  List<Map<String, dynamic>> get postsStuff {
    return posts;
  }

  Future getUserData() async {
    petInfo = [];
    await FirebaseFirestore.instance
        .collectionGroup('users')
        .where('uid', isEqualTo: uid['uid'])
        .get()
        .then((value) {
      // Map test = <String, String>{"Name": ""};
      for (var element in value.docs) {
        debugPrint("name: ${element.data().toString()}");
        name["name"] = element['name'];
        buildingCode["buildingCode"] = element["buildingCode"];
        if (element.data().toString().contains("pictureUrl")) {
          pictureUrl["pictureUrl"] = element["pictureUrl"];
          hasPicture = true;
        }
      }
    }, onError: (e) => {"Name": "Error Getting Name"});

    await FirebaseFirestore.instance
        .collectionGroup('pets')
        .where('uid', isEqualTo: uid['uid'])
        .get()
        .then((value) {
      if (value.docs.length != 0) {
        hasPet = true;
      }
      for (var element in value.docs) {
        petInfo.add(element.data());
        // debugPrint("${petInfo['friendly']}");
      }
    });
    getPosts();
    // notifyListeners();
  }

  Future getPosts() async {
    posts = [];
    // debugPrint("Getting posts");
    postsLoading = true;
    await FirebaseFirestore.instance // #TODO : sort by date created
        .collection('building-codes/${buildingCode['buildingCode']}/posts')
        .get()
        .then((value) => {
              // ignore: avoid_function_literals_in_foreach_calls
              value.docs.forEach((element) {
                // debugPrint(element.id);
                posts.add({...element.data(), "id": element.id});
                // debugPrint(element.data().toString());
              })
            });
    // debugPrint(posts.toString());
    postsLoading = false;
    var post = posts[0];
    // debugPrint(post['comments'].length.toString());
    // debugPrint(posts.length.toString());
    notifyListeners();
  }

  Map<String, dynamic> getPost(id) {
    Map<String, dynamic> myPost = {"TEst": "Test"};
    debugPrint("$posts");
    for (var element in posts) {
      if (element["id"] == id) {
        myPost = element;
      }
      // return element["id"] == id;
    }
    return myPost;
  }

  // Future updatePost(id) async {}

  void DeletePet(int index, Map pet) async {
// await Firestore.instance.runTransaction((Transaction myTransaction) async {
//     await myTransaction.delete(snapshot.data.documents[index].reference);
// });

    // const docRef = await FirebaseFirestore.instance.collection('pets')
    //   .where()

    // await FirebaseFirestore.instance.runTransaction((transaction) async {
    //     await transaction.delete(documentReference)
    // })

    // #TODO: we need to add a unique ID to each pet so that we can get a ref and delete it.
  }

  // final buildingId = <String, String>{"buildingCode": getBuildingID()};

  // final name = <String, String>{
  //   "name": FirebaseFirestore.instance.collection()
  // };

  // UnmodifiableMapView get getName => UnmodifiableMapView(name);
}
