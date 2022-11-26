import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:petwatch/components/TopNavigation/message_top_nav.dart';
import 'package:petwatch/screens/post_page.dart';
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
      debugPrint("${test["notifications"]}");
    });
    return notifications;
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
                    return Text("There has been an error: ${snapshot.error}");
                  } else {
                    return ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: snapshot.data?.length,
                      itemBuilder: (context, index) {
                        return Container(
                          height: 100,
                          child: GestureDetector(
                            onTap: () {
                              if (snapshot.data![index]['type'] == "comment") {
                                for (var post in value.posts) {
                                  if (post['docPath'] ==
                                      snapshot.data![index]['postPath']) {
                                    debugPrint("We have found the post");
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PostPage(post: post)));
                                  }
                                }
                              }
                            },
                            child: Card(
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 25,
                                        backgroundColor: Colors.white,
                                        backgroundImage: snapshot.data![index][
                                                    'commentAuthorPictureUrl'] !=
                                                ""
                                            ? NetworkImage(snapshot.data![index]
                                                ['commentAuthorPictureUrl'])
                                            : AssetImage(
                                                    'assets/images/petwatch_logo.png')
                                                as ImageProvider,
                                      ),
                                      Center(
                                          child: Text(
                                              "${snapshot.data?[index]['title']}")),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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
