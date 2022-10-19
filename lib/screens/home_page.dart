import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:petwatch/screens/auth_gate.dart';
import 'package:petwatch/screens/sign-up/personal_info.dart';
import 'package:petwatch/components/TopNavigation/top_nav_bar.dart';
import 'package:petwatch/components/bottom_nav_bar.dart';
import 'package:petwatch/screens/pet-profile/pet_profile_page.dart';
import 'package:provider/provider.dart';

import '../state/user_model.dart';

class HomePage extends StatelessWidget {
  HomePage();

  // final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(builder: (context, value, child) {
      return GestureDetector(
          onTap: () {},
          child: Scaffold(
            appBar: TopNavBar(),
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(value.petInfo['name']),
                      SignOutButton(),
                    ]),
              ),
            ),
          ));
    });
  }
}
