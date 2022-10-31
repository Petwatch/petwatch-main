import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:petwatch/queries/get_home_page.dart';
import 'package:petwatch/screens/auth_gate.dart';
import 'package:petwatch/screens/sign-up/personal_info.dart';
import 'package:petwatch/components/TopNavigation/top_nav_bar.dart';
import 'package:petwatch/components/bottom_nav_bar.dart';
import 'package:petwatch/screens/pet-profile/pet_profile_page.dart';
import 'package:provider/provider.dart';

import '../../state/user_model.dart';

class HomePage extends StatelessWidget {
  HomePage();

  // final BuildContext context;

  Widget singlePost(BuildContext context, Map<String, dynamic> post) {
    return GestureDetector(
        onTap: (() {}),
        child: Padding(
            padding: EdgeInsets.all(24),
            child: Card(
              elevation: 5,
              child: Column(children: [Text(post['title'])]),
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(builder: (context, value, child) {
      List<Widget> postList = [];
      value.posts.forEach((post) {
        postList.add(singlePost(context, post));
      });

      return GestureDetector(
          onTap: () {},
          child: Scaffold(
            appBar: TopNavBar(),
            body: value.postsLoading
                ? Center(child: CircularProgressIndicator())
                : Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [...postList]),
                  ),
          ));
    });
  }
}
