import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class UserCheck {
  static Stream<bool> validateUserHasBuilding({required String uid}) async* {
    int length = -1;
    var test = await FirebaseFirestore.instance
        .collectionGroup('users')
        .where('uid', isEqualTo: uid)
        .get()
        .then((value) => {length = value.docs.length},
            onError: (e) => print("Error completing: $e"));
    if (length > 0) {
      yield true;
    } else {
      yield false;
    }
  }
}
