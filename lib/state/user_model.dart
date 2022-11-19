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
  String stripeExpressId = "";
  List<Map<String, dynamic>> petInfo = [];
  String subTitle = "";
  String bio = "";
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
        // debugPrint("name: ${element.data().toString()}");
        name["name"] = element['name'];
        subTitle = element['subTitle'];
        bio = element['bio'];
        buildingCode["buildingCode"] = element["buildingCode"];
        if (element.data().toString().contains("pictureUrl")) {
          pictureUrl["pictureUrl"] = element["pictureUrl"];
          hasPicture = true;
        }
        if (element.data().containsKey("stripeExpressId")) {
          stripeExpressId = element["stripeExpressId"];
          debugPrint("$stripeExpressId");
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
      }
    });
    getPosts();
  }

  Future getPosts() async {
    posts = [];
    postsLoading = true;
    await FirebaseFirestore.instance
        .collection('building-codes/${buildingCode['buildingCode']}/posts')
        .orderBy("postedTime", descending: true)
        .get()
        .then((value) => {
              debugPrint("${value.size}"),
              value.docs.forEach((element) {
                posts.add({...element.data(), "id": element.id});
              })
            })
        .then((value) => {
              postsLoading = false,
              notifyListeners(),
            });
  }

  Future getPost(id, String buildingCode) async {
    await FirebaseFirestore.instance
        .doc("/building-codes/${buildingCode}/posts/${id}")
        .get()
        .then((value) {
      for (var i = 0; i < posts.length; i++) {
        // debugPrint("Is this for loop printing?");
        if (posts[i]["documentID"] == id) {
          posts[i] = value.data()!;
        }
      }
      notifyListeners();
    });
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
