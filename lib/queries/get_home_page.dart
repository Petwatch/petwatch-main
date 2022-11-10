import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

import 'package:flutter/widgets.dart';

class GetHomePage {
  static void getPosts({required String uid}) async {
    await FirebaseFirestore.instance
        .collection('building-codes/123456789/posts')
        .get()
        .then((value) => {
              value.docs.forEach((element) {
                // debugPrint(element.data().toString());
              })
            });
  }
}
