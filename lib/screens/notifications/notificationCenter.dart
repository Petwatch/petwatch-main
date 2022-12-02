import 'package:badges/badges.dart' as badges;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:petwatch/components/TopNavigation/message_top_nav.dart';
import 'package:petwatch/screens/post_page.dart';
import 'package:petwatch/screens/routes.dart';
import 'package:provider/provider.dart';

import '../../state/user_model.dart';

class NotificationsCenter extends StatefulWidget {
  State<StatefulWidget> createState() {
    return NotificationsCenterState();
  }
}

class NotificationsCenterState extends State<NotificationsCenter> {
  Future<List<dynamic>> getNotifications(
      String uid, String buildingCode) async {
    List<dynamic> notifications = [];
    await FirebaseFirestore.instance
        .doc("/building-codes/$buildingCode/users/$uid")
        .get()
        .then((value) {
      Map<String, dynamic> test = value.data()!;
      notifications = test["notifications"];
    });

    return notifications.reversed.toList();
  }

  Widget build(BuildContext context) {
    return Consumer<UserModel>(builder: ((context, value, child) {
      return GestureDetector(
        onTap: () {},
        child: Scaffold(
          appBar: const MessageNavBar(),
          body: FutureBuilder(
            future: getNotifications(
                value.uid['uid']!, value.buildingCode['buildingCode']),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return const Center(child: CircularProgressIndicator());
                default:
                  if (snapshot.hasError) {
                    return Text("");
                  } else {
                    return RefreshIndicator(
                      onRefresh: () {
                        return getNotifications(value.uid['uid']!,
                            value.buildingCode['buildingCode']);
                      },
                      child: ListView.builder(
                        // reverse: true,
                        padding: const EdgeInsets.all(10),
                        itemCount: snapshot.data?.length,
                        itemBuilder: (context, index) {
                          if (snapshot.data![index]['type'] == "comment") {
                            return CommentNotification(snapshot, index, value);
                          } else if (snapshot.data![index]['type'] ==
                              "sitterRequest") {
                            return CommentNotification(snapshot, index, value);
                          } else {
                            return CommentNotification(snapshot, index, value);
                          }
                        },
                      ),
                    );
                  }
              }
            },
          ),
        ),
      );
    }));
  }
}

class CommentNotification extends StatelessWidget {
  final AsyncSnapshot<List<dynamic>> snapshot;
  final int index;
  final UserModel value;

  const CommentNotification(this.snapshot, this.index, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (snapshot.data![index]["read"] == false) {
          await FirebaseFirestore.instance
              .doc(
                  "/building-codes/${value.buildingCode["buildingCode"]}/users/${value.uid["uid"]}")
              .get()
              .then((value) {
            // Map<String, dynamic>? test = value.data();
            snapshot.data![index]['read'] = true;
            value.reference
                .update({"notifications": snapshot.data!.reversed.toList()});
          });
        }

        // if(value.posts[index])
        if (snapshot.data![index]['type'] == "sitterRequest") {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Routes(1)));
        } else {
          bool found = false;
          for (var post in value.posts) {
            if (post['docPath'] == snapshot.data![index]['postPath']) {
              // debugPrint("We have found the post");
              found = true;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PostPage(post: post)));
            }
          }
          if (!found) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Routes(1)));
          }
        }
      },
      child: Card(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CircleAvatar(
                      radius: 21,
                      backgroundColor: Colors.white,
                      backgroundImage: snapshot.data![index]
                                  ['commentAuthorPictureUrl'] !=
                              null
                          ? NetworkImage(
                              snapshot.data![index]['commentAuthorPictureUrl'])
                          : AssetImage('assets/images/petwatch_logo.png')
                              as ImageProvider,
                    ),
                  ),
                  Center(
                      child: Text(
                    "${snapshot.data?[index]['title']}",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  )),
                  Spacer(),
                  if (snapshot.data?[index]['read'] == false)
                    Padding(
                        padding: EdgeInsets.all(15),
                        child: Container(
                          width: 13,
                          height: 13,
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle),
                        )),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                      child: snapshot.data?[index]['type'] == "comment"
                          ? Text(
                              "${snapshot.data?[index]['body']}",
                              overflow: TextOverflow.ellipsis,
                            )
                          : Text("${snapshot.data?[index]['body']}")),
                  // Spacer(),
                  // Spacer(flex: 1)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
