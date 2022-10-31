import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:intl/intl.dart';
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
    // debugPrint(post.toString());
    // var datePosted =
    //     new DateTime.fromMicrosecondsSinceEpoch(post['postedTime']);
    final infoPostDateFormat = new DateFormat('MMMd');
    final timestamp = post['postedTime'] as Timestamp;
    var datePosted =
        DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
    // debugPrint(post['postedTime'].toString());
    // debugPrint(DateFormat.ABBR_MONTH_DAY(timestamp));
    // debugPrint(infoPostDateFormat.format(datePosted));

    var formattedDate = infoPostDateFormat.format(datePosted);

    return GestureDetector(
        onTap: (() {}),
        child: Padding(
            padding: EdgeInsets.only(top: 24),
            child: FractionallySizedBox(
              widthFactor: .95,
              child: Card(
                  elevation: 2,
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(15),
                          child: Row(children: [
                            CircleAvatar(
                              // radius: 75,
                              backgroundColor: Colors.white,
                              child: ClipRRect(
                                borderRadius: BorderRadius.zero,
                                child: Image.asset(
                                  'assets/images/petwatch_logo.png',
                                ),
                              ),
                            ),
                            Text(post['postedBy']['name']),
                            Container(
                              child: VerticalDivider(
                                width: 20,
                                thickness: 1,
                                indent: 20,
                                endIndent: 0,
                                color: Colors.grey,
                              ),
                            ),
                            Text(formattedDate),
                          ]),
                        )
                      ],
                    ),
                  )),
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(builder: (context, value, child) {
      List<Widget> postList = [];
      for (var post in value.posts) {
        postList.add(singlePost(context, post));
      }

      return GestureDetector(
          onTap: () {},
          child: Scaffold(
            appBar: TopNavBar(),
            body: value.postsLoading
                ? Center(child: CircularProgressIndicator())
                : Center(
                    child: Padding(
                    padding: EdgeInsets.all(0),
                    child: Column(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [...postList]),
                  )),
          ));
    });
  }
}
