import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:petwatch/components/TopNavigation/top_nav_bar.dart';
import 'package:petwatch/screens/post-creation/createPost.dart';
import 'package:petwatch/screens/post_page.dart';
import 'package:provider/provider.dart';

import '../../state/user_model.dart';

class HomePage extends StatefulWidget {
  HomePage();

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget singlePost(BuildContext context, Map<String, dynamic> post) {
    final infoPostDateFormat = new DateFormat('MMMd');
    final timestamp = post['postedTime'] as Timestamp;
    var datePosted =
        DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);

    var formattedDate = infoPostDateFormat.format(datePosted);

    var description = post['desc'] as String;
    var pictureUrl = post['postedBy'].containsKey("pictureUrl")
        ? post['postedBy']['pictureUrl'] as String
        : "";

    return GestureDetector(
        onTap: (() {
          // debugPrint("clicked");
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
                            Padding(
                              padding:
                                  const EdgeInsets.only(right: 8.0, top: 8.0),
                              child: CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.white,
                                backgroundImage: pictureUrl != ""
                                    ? NetworkImage(pictureUrl)
                                    : AssetImage(
                                            'assets/images/petwatch_logo.png')
                                        as ImageProvider,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.zero,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(post['postedBy']['name'] + " | "),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(formattedDate),
                            ),
                            if (post.containsKey("price"))
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: (Text(" | \$${post["price"]}")),
                              )
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
                                  backgroundColor: (() {
                                    switch (post["type"]) {
                                      case "Info":
                                        return Colors.yellow;
                                      case "Request":
                                        return Colors.green;
                                      case "Available":
                                        return Colors.blue;
                                      default:
                                        return Colors.yellow;
                                    }
                                  })(),
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

  late FirebaseMessaging messaging;
  UserModel userModel = UserModel();
  void initState() {
    super.initState();
    messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value) {
      debugPrint(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    userModel.addListener(() {
      // debugPrint("New Post has been added");
      // debugPrint("${userModel.posts.length}");
    });
    return Consumer<UserModel>(builder: (context, value, child) {
      List<Widget> postList = [];
      for (var post in value.posts) {
        postList.add(singlePost(context, post));
      }
      // debugPrint("${postList.length}");

      return GestureDetector(
          onTap: () {},
          child: Scaffold(
            appBar: const TopNavBar(),
            body: value.postsLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () {
                      return value.getPosts();
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Center(
                          child: Padding(
                        padding: const EdgeInsets.all(0),
                        child: Column(
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [...postList]),
                      )),
                    ),
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
