import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:petwatch/components/TopNavigation/top_nav_bar.dart';
import 'package:petwatch/screens/post-creation/createPost.dart';
import 'package:petwatch/screens/post_page.dart';
import 'package:provider/provider.dart';

import '../../state/user_model.dart';

class HomePage extends StatelessWidget {
  HomePage();

  // final BuildContext context;

  Widget singlePost(BuildContext context, Map<String, dynamic> post) {
    // debugPrint(post.toString());
    // This dat stuff is only for a info post for now.
    final infoPostDateFormat = new DateFormat('MMMd');
    final timestamp = post['postedTime'] as Timestamp;
    var datePosted =
        DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);

    var formattedDate = infoPostDateFormat.format(datePosted);

    var description = post['desc'] as String;

    return GestureDetector(
        onTap: (() {
          debugPrint("clicked");
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => PostPage(post: post)));
        }),
        child: Padding(
            padding: const EdgeInsets.only(top: 24),
            child: FractionallySizedBox(
              widthFactor: .95,
              child: Card(
                  elevation: 2,
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15),
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
                              child: const VerticalDivider(
                                width: 20,
                                thickness: 1,
                                indent: 20,
                                endIndent: 0,
                                color: Colors.grey,
                              ),
                            ),
                            Text(formattedDate),
                          ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text(
                                description,
                                softWrap: false,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            children: [
                              Chip(
                                  backgroundColor: Colors.yellow,
                                  label: Text(post['type'])),
                              const Spacer(),
                              Text("${post['comments'].length} comments"),
                              const Icon(Icons.comment, color: Colors.black),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.black,
                              )

                              //Make text color white
                            ],
                          ),
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
            appBar: const TopNavBar(),
            body: value.postsLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.all(0),
                      child: Column(
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [...postList]),
                    )),
                  ),
            floatingActionButton: FloatingActionButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => CreatePost()));
                },
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: const Icon(Icons.add_circle_outline)),
          ));
    });
  }
}
