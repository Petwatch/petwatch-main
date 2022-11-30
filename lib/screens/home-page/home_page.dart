import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:petwatch/components/CustomRatingDialog.dart';
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
  Widget singlePost(
      BuildContext context, Map<String, dynamic> post, UserModel user) {
    final infoPostDateFormat = new DateFormat('MMMd');
    final requestPostDateFormat = new DateFormat("MMMd-MMMd");
    final timestamp = post['postedTime'] as Timestamp;

    //TODO: Add the dates correctly for posts.
    var datePosted =
        DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);

    var formattedDate = infoPostDateFormat.format(datePosted);

    var description = post['desc'] as String;
    var pictureUrl = post['postedBy'].containsKey("pictureUrl")
        ? post['postedBy']['pictureUrl'] as String
        : "";

    String completedSitterUid = "";
    if (post.containsKey('requests')) {
      for (var request in post['requests']) {
        if (request['status'] == "approved" &&
            user.uid['uid'] == request['petSitterUid']) {
          completedSitterUid = request['petSitterUid'];
        }
      }
    }

    void _showRatingAppDialog() {
      final _ratingDialog = CustomRatingDialog(
        starColor: Colors.amber,
        starSize: 30,
        title: [Center(child: Text('Reviewing ${post['postedBy']['name']}'))],
        submitButtonText: 'Submit',
        submitButtonTextStyle: TextStyle(color: Colors.white),
        onCancelled: () => print('cancelled'),
        onSubmitted: (response) async {
          await FirebaseFirestore.instance
              .doc(
                  'building-codes/${user.buildingCode['buildingCode']}/users/${post['postedBy']['UID']}')
              .update({
            "reviews": FieldValue.arrayUnion([
              {
                "reviewerName": user.name['name'],
                "reviewerPictureUrl": user.pictureUrl['pictureUrl'],
                "comment": response.comment,
                "stars": response.rating
              }
            ])
          });
        },
        commentHint: "Tell us about your sitter",
      );

      showDialog(
        useSafeArea: false,
        context: context,
        barrierDismissible: false,
        builder: (context) => _ratingDialog,
      );
    }

    return GestureDetector(
        onTap: (() {
          // debugPrint("clicked");
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => PostPage(post: post)));
        }),
        child: Padding(
            padding: const EdgeInsets.only(top: 24, left: 5, right: 5),
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
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(post['postedBy']['name'] + " | "),
                            ),
                          ),
                          if (post['type'] == 'Request')
                            Flexible(
                              child: Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(infoPostDateFormat.format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              post['dateRange']['startTime'])) +
                                      " - " +
                                      infoPostDateFormat.format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              post['dateRange']['endTime'])))),
                            )
                          else
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(formattedDate),
                              ),
                            ),
                          if (post['type'] != "Info" && post['price'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: (Text(" | \$${post["price"]}")),
                            )
                        ]),
                      ),
                      Flexible(
                        child: Padding(
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
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          children: [
                            Chip(
                                backgroundColor: (() {
                                  switch (post["type"]) {
                                    case "Info":
                                      return Colors.blue;
                                    case "Request":
                                      return Colors.green;
                                    default:
                                      return Colors.yellow;
                                  }
                                })(),
                                label: post['status'] == 'complete'
                                    ? Text(
                                        "Complete",
                                        style: TextStyle(color: Colors.white),
                                      )
                                    : Text(
                                        post['type'],
                                        style: TextStyle(color: Colors.white),
                                      )),
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
                      ),
                      if (post['status'] == 'complete' &&
                          completedSitterUid == user.uid['uid'])
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(15.0, 0, 15.0, 15.0),
                          child: (ElevatedButton(
                            onPressed: () {
                              _showRatingAppDialog();
                            },
                            child: Text(
                              "Leave a review",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ButtonStyle(
                                fixedSize:
                                    MaterialStateProperty.all(Size(350, 30)),
                                backgroundColor: MaterialStateProperty.all(
                                    Theme.of(context).colorScheme.primary)),
                          )),
                        )
                    ],
                  ),
                ))));
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
        postList.add(singlePost(context, post, value));
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
